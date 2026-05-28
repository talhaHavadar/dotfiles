#!/usr/bin/env bash
#
# Run a tool inside a Debian-packaging container. cwd is bind-mounted so
# `../foo.changes`, `../foo.dsc`, etc. resolve the same way as on the host.
#
# Layout: contained [opts] -- [docker-opts...] -- [container-cmd...]
#   -c <image>   override the container image
#   -v <mount>   extra bind mount (passed straight to docker -v)
#   -i           interactive (docker -it)
#   Args between the first '--' and second '--' go to `docker run`.
#   Args after the second '--' (or after the first, if there's no second)
#   are the command to run inside the container.
#
# Environment overrides:
#   CONTAINED_CONTAINER_RUNTIME   docker (default) | podman
#   CONTAINED_CONTAINER_NAME      ghcr.io/talhahavadar/contained-debdev:ubuntu-devel
#   CONTAINED_RUN_ARGS            "--privileged --security-opt seccomp=unconfined"
#                                 -- needed by sbuild's unshare backend on
#                                 macOS runtimes; override to replace, set
#                                 empty to disable
#   CONTAINED_HOST_GATEWAY_ALIAS  host.docker.internal (default) -- hostname
#                                 the in-container side of the GPG bridge
#                                 connects to (macOS only)
#
# Auto-passthrough (forwarded only when set on the host):
#   DEBFULLNAME, DEBEMAIL, DEBSIGN_KEYID
#   SSH_AUTH_SOCK -> /run/host-ssh-agent.sock
#     For YubiKey-via-gpg-agent setups this is the ssh wrapper socket, so
#     git-over-ssh and ssh-format commit signing both reach the YubiKey.
#
# Auto-mount (read-only when host file exists):
#   ~/.config/sbuild/config.pl  -> /root/.config/sbuild/config.pl
#   ~/.sbuildrc                 -> /root/.sbuildrc          (legacy fallback)
#   ~/.config/git/config        -> /root/.config/git/config (XDG)
#   ~/.gitconfig                -> /root/.gitconfig         (legacy fallback)
#
# GPG / YubiKey signing inside the container
# ------------------------------------------
# The host's gpg-agent owns the actual key material (via the YubiKey). One
# strategy per OS makes the in-container gpg talk to it.
#
# Linux: bind-mount the host gpg-agent extra socket directly at
# /root/.gnupg/S.gpg-agent on top of a ~/.gnupg dir mount, with a staged
# gpg.conf carrying `no-autostart` so a missing socket can't autospawn an
# in-container agent that would scribble fresh sockets into the host's
# .gnupg. If no gpg-agent socket is discoverable, ~/.gnupg is still mounted
# but no socket overlay is added -- the container can read pubring but not
# sign.
#
# macOS: direct bind doesn't work because Docker Desktop / OrbStack / Apple
# `container` / Podman all share files through virtiofs, which (a) strips
# socket type from any Unix socket inside a dir bind (`stat` -> EOPNOTSUPP)
# and (b) refuses an overlaid single-file socket bind on top of a dir mount
# at runc level. Instead we run a TCP loopback bridge: a host-side socat
# forwards Assuan from 127.0.0.1:<random-port> to the gpg-agent extra
# socket; an entrypoint wrapper in the container materializes
# /run/gnupg/S.gpg-agent via another socat that connects back to that
# loopback port. GNUPGHOME is set to /run/gnupg (a fresh in-container dir)
# and seeded with host pubkeys exported via `gpg --export` -- copying the
# keyboxd SQLite db instead inherits WAL/SHM lock state through virtiofs
# and hangs the container keyboxd on a ghost reader. Requires `socat` on
# the host (brew install socat) and a reachable gpg-agent -- both are hard
# requirements; the script errors out if either is missing.
#
# The "extra" socket is upstream-sanctioned for forwarding: Assuan with the
# `restrict` filter, so a forwarded client can sign but can't
# UPDATESTARTUPTTY against the host user's tty. Cost of that filter: gpg's
# fast-path key-listing call hits "Forbidden - ignored" and falls back to
# the slow path -- benign, signing still works.
#
# Security note: while the macOS bridge is up, anything that reaches the
# loopback port can request signatures from the YubiKey. Acceptable on a
# single-user dev machine; do not use on a multi-user host.
#
# Examples:
#
#   # uscan a watch file using the default image
#   contained uscan -v --no-download
#
#   # interactive shell inside a specific image
#   contained -i -c ghcr.io/talhahavadar/contained-debdev:debian-unstable -- bash
#
#   # full sbuild run -- CONTAINED_RUN_ARGS supplies the macOS-required flags
#   contained -c ghcr.io/talhahavadar/contained-debdev:debian-unstable \
#       -- sbuild -d unstable --no-clean-source
#
#   # extra bind mount for a local apt cache
#   contained -c ghcr.io/talhahavadar/contained-debdev:debian-unstable \
#       -v "$HOME/.cache/apt:/var/cache/apt" \
#       -- sbuild -d unstable
#
#   # add an extra docker flag on top of the defaults
#   contained -- --cap-add SYS_PTRACE -- bash

set -eo pipefail

# ---------------------------------------------------------------------------
# Defaults & state
# ---------------------------------------------------------------------------

HOST_OS=$(uname -s)
CONTAINER_RUNTIME=${CONTAINED_CONTAINER_RUNTIME:-docker}
CONTAINER=${CONTAINED_CONTAINER_NAME:-ghcr.io/talhahavadar/contained-debdev:ubuntu-devel}
CONTAINER_WORK_DIR="/work/$(basename "$PWD")"
INTERACTIVE=0
VOLUMES=("$PWD/..:/work")

# --privileged (CAP_SYS_ADMIN for the chroot's /proc mount inside sbuild) and
# --security-opt seccomp=unconfined (lets unshare(CLONE_NEWUSER) through) are
# needed on macOS container runtimes. Override via CONTAINED_RUN_ARGS.
_default_run_args="--privileged --security-opt seccomp=unconfined"
# shellcheck disable=SC2206  # intentional word-split into array
DEFAULT_RUN_ARGS=(${CONTAINED_RUN_ARGS:-$_default_run_args})

# Accumulators populated by the setup_ helpers below.
ENV_ARGS=()
SBUILD_CONFIG_MOUNTS=()
GIT_CONFIG_MOUNTS=()
GPG_MOUNTS=()

# Cleanup state.
STAGED_FILES=()
GPG_BRIDGE_PID=

cleanup() {
    if [ "${#STAGED_FILES[@]}" -gt 0 ]; then
        rm -f "${STAGED_FILES[@]}" 2>/dev/null || true
    fi
    if [ -n "$GPG_BRIDGE_PID" ]; then
        kill "$GPG_BRIDGE_PID" 2>/dev/null || true
    fi
    return 0
}
trap cleanup EXIT

# ---------------------------------------------------------------------------
# Staging helpers
# ---------------------------------------------------------------------------

# stage_file <src> -- copy <src> to a tmp file and echo the tmp path. Used
# instead of bind-mounting <src> directly because Nix-managed dotfiles are
# symlinks into /nix/store, which Docker Desktop / Apple `container` don't
# share with the VM by default. Tmp files are cleaned up on script exit.
stage_file() {
    local tmp
    tmp=$(mktemp -t contained-stage.XXXXXX)
    cat "$1" > "$tmp"
    STAGED_FILES+=("$tmp")
    printf '%s' "$tmp"
}

# stage_git_config <src> -- like stage_file, but strips `program = ...`
# lines from any [gpg*] section. On Nix-managed hosts those point at
# /nix/store/... paths that don't exist in the container (e.g.
# `[gpg "openpgp"] program = /nix/store/.../bin/gpg`), and git would fail
# to sign with "cannot exec ... No such file or directory". Letting git
# fall back to PATH-resolved gpg / ssh-keygen / gpgsm is right anyway.
stage_git_config() {
    local tmp
    tmp=$(mktemp -t contained-gitconfig.XXXXXX)
    awk '
        /^[[:space:]]*\[gpg(\]|[[:space:]])/ { in_gpg=1; print; next }
        /^[[:space:]]*\[/ { in_gpg=0 }
        in_gpg && /^[[:space:]]*program[[:space:]]*=/ { next }
        { print }
    ' "$1" > "$tmp"
    STAGED_FILES+=("$tmp")
    printf '%s' "$tmp"
}

# ---------------------------------------------------------------------------
# Host -> container plumbing
# ---------------------------------------------------------------------------

# `-e VAR` (without =VALUE) tells docker to copy the live host value.
forward_packaging_env() {
    local v
    for v in DEBFULLNAME DEBEMAIL DEBSIGN_KEYID; do
        if [ -n "${!v-}" ]; then
            ENV_ARGS+=(-e "$v")
        fi
    done
}

# sbuild config (XDG path preferred). Overrides image's /etc/sbuild/sbuild.conf.
mount_sbuild_config() {
    if [ -f "${HOME}/.config/sbuild/config.pl" ]; then
        SBUILD_CONFIG_MOUNTS+=(-v "$(stage_file "${HOME}/.config/sbuild/config.pl"):/root/.config/sbuild/config.pl:ro")
    elif [ -f "${HOME}/.sbuildrc" ]; then
        SBUILD_CONFIG_MOUNTS+=(-v "$(stage_file "${HOME}/.sbuildrc"):/root/.sbuildrc:ro")
    fi
}

# git config so commits inside the container pick up user.name, signing
# settings, URL rewrites, etc. Read-only -- a stray `git config --global`
# in the container should not corrupt host config.
mount_git_config() {
    if [ -f "${HOME}/.config/git/config" ]; then
        GIT_CONFIG_MOUNTS+=(-v "$(stage_git_config "${HOME}/.config/git/config"):/root/.config/git/config:ro")
    elif [ -f "${HOME}/.gitconfig" ]; then
        GIT_CONFIG_MOUNTS+=(-v "$(stage_git_config "${HOME}/.gitconfig"):/root/.gitconfig:ro")
    fi
}

# SSH agent socket: top-level single-file bind so it retains socket type
# (a passenger of a virtiofs dir mount would not). For YubiKey-via-gpg-agent
# this routes ssh auth through the YubiKey too.
forward_ssh_agent() {
    if [ -n "${SSH_AUTH_SOCK-}" ] && [ -S "${SSH_AUTH_SOCK}" ]; then
        GPG_MOUNTS+=(-v "${SSH_AUTH_SOCK}:/run/host-ssh-agent.sock")
        ENV_ARGS+=(-e "SSH_AUTH_SOCK=/run/host-ssh-agent.sock")
    fi
}

# ---------------------------------------------------------------------------
# GPG agent forwarding
# ---------------------------------------------------------------------------

# Echo the host gpg-agent socket path -- extra-socket preferred, fallback
# to main. Launches the agent first so a fresh shell (or one after
# `gpgconf --kill all`) doesn't leave us with no socket to bind. Empty
# echo if no socket available.
discover_gpg_socket() {
    command -v gpgconf >/dev/null 2>&1 || return 0
    gpgconf --launch gpg-agent >/dev/null 2>&1 || true
    local extra main
    extra=$(gpgconf --list-dirs agent-extra-socket 2>/dev/null || true)
    main=$(gpgconf --list-dirs agent-socket 2>/dev/null || true)
    if [ -n "$extra" ] && [ -S "$extra" ]; then
        printf '%s' "$extra"
    elif [ -n "$main" ] && [ -S "$main" ]; then
        printf '%s' "$main"
    fi
}

# Linux direct bind: host extra-socket -> /root/.gnupg/S.gpg-agent on top
# of a ~/.gnupg dir mount, plus a staged gpg.conf with `no-autostart`. If
# no host socket is discoverable, the socket overlay and gpg.conf are
# skipped -- the container can read pubring but not sign.
setup_gpg_linux() {
    local sock=$1 conf
    if [ -d "${HOME}/.gnupg" ]; then
        GPG_MOUNTS+=(-v "${HOME}/.gnupg:/root/.gnupg")
    fi
    if [ -z "$sock" ]; then
        return 0
    fi
    GPG_MOUNTS+=(-v "${sock}:/root/.gnupg/S.gpg-agent")
    conf=$(mktemp -t contained-gpgconf.XXXXXX)
    if [ -f "${HOME}/.gnupg/gpg.conf" ]; then
        cat "${HOME}/.gnupg/gpg.conf" > "$conf"
    fi
    printf '\nno-autostart\n' >> "$conf"
    STAGED_FILES+=("$conf")
    GPG_MOUNTS+=(-v "${conf}:/root/.gnupg/gpg.conf:ro")
}

# macOS bridge:
#   - Expose ~/.gnupg read-only at /host-gnupg (the in-container wrapper
#     copies plain-file bits into a fresh /run/gnupg).
#   - Spawn host-side socat translating extra-socket -> 127.0.0.1:<port>.
#   - Export host pubkeys to a portable blob and stage it at
#     /run/host-pubkeys.gpg; the wrapper imports it into a fresh keybox,
#     avoiding the keyboxd SQLite WAL/SHM virtiofs trap.
#   - Set env vars the wrapper needs to find host + port + GNUPGHOME.
setup_gpg_macos() {
    local sock=$1 port pubkeys host_alias

    if [ -d "${HOME}/.gnupg" ]; then
        GPG_MOUNTS+=(-v "${HOME}/.gnupg:/host-gnupg:ro")
    fi

    port=$(python3 -c 'import socket; s=socket.socket(); s.bind(("127.0.0.1",0)); print(s.getsockname()[1]); s.close()' 2>/dev/null || true)
    if [ -z "$port" ]; then
        port=$((20000 + RANDOM % 40000))
    fi
    socat "TCP-LISTEN:${port},bind=127.0.0.1,reuseaddr,fork" "UNIX-CONNECT:${sock}" >/dev/null 2>&1 &
    GPG_BRIDGE_PID=$!

    gpgconf --launch keyboxd >/dev/null 2>&1 || true
    pubkeys=$(mktemp -t contained-pubkeys.XXXXXX)
    if gpg --batch --no-tty --export > "$pubkeys" 2>/dev/null && [ -s "$pubkeys" ]; then
        STAGED_FILES+=("$pubkeys")
        GPG_MOUNTS+=(-v "${pubkeys}:/run/host-pubkeys.gpg:ro")
    else
        rm -f "$pubkeys"
    fi

    host_alias=${CONTAINED_HOST_GATEWAY_ALIAS:-host.docker.internal}
    # --add-host is a no-op on Docker Desktop / OrbStack (the alias is
    # built in) but lets the same code work on Podman and non-default
    # Docker.
    DEFAULT_RUN_ARGS+=(--add-host "${host_alias}:host-gateway")
    ENV_ARGS+=(
        -e "GNUPGHOME=/run/gnupg"
        -e "CONTAINED_GPG_BRIDGE_HOST=${host_alias}"
        -e "CONTAINED_GPG_BRIDGE_PORT=${port}"
    )
}

# Top-level GPG dispatcher: one strategy per OS. macOS hard-fails if its
# bridge prerequisites are missing (socat + reachable gpg-agent); Linux
# gracefully degrades to pubring-only when no agent is available.
setup_gpg() {
    local sock
    sock=$(discover_gpg_socket)

    case "$HOST_OS" in
    Darwin)
        if ! command -v socat >/dev/null 2>&1; then
            echo "contained: macOS gpg bridge requires socat on the host (brew install socat)" >&2
            exit 2
        fi
        if ! command -v gpg >/dev/null 2>&1; then
            echo "contained: macOS gpg bridge requires gpg on the host" >&2
            exit 2
        fi
        if [ -z "$sock" ]; then
            echo "contained: no gpg-agent socket on host (gpgconf --launch gpg-agent failed)" >&2
            exit 2
        fi
        setup_gpg_macos "$sock"
        ;;
    Linux)
        setup_gpg_linux "$sock"
        ;;
    *)
        if [ -d "${HOME}/.gnupg" ]; then
            GPG_MOUNTS+=(-v "${HOME}/.gnupg:/root/.gnupg")
        fi
        ;;
    esac
}

# Wrap CONTAINER_CMD with the in-container bootstrap for bridge mode:
# build GNUPGHOME=/run/gnupg, start the container-side socat, import the
# staged host pubkeys, then exec the user's command. Default to `bash` if
# the user passed no command so the wrapper has something to exec.
wrap_cmd_with_gpg_bridge() {
    local bootstrap='set -e
mkdir -p /run/gnupg
chmod 700 /run/gnupg
if [ -d /host-gnupg ]; then
    # Pubring stores are seeded via `gpg --import` from /run/host-pubkeys.gpg
    # below; copying the host keyboxd SQLite db drags WAL/SHM lock state
    # through virtiofs and hangs the container keyboxd. private-keys-v1.d
    # is omitted because the forwarded agent owns the YubiKey-shadow stubs.
    for entry in common.conf gpg.conf trustdb.gpg openpgp-revocs.d sshcontrol; do
        [ -e "/host-gnupg/$entry" ] && cp -RLp "/host-gnupg/$entry" "/run/gnupg/" 2>/dev/null || true
    done
fi
if ! command -v socat >/dev/null 2>&1; then
    echo "contained: gpg-agent bridge requires socat in the container image" >&2
    exit 2
fi
socat "UNIX-LISTEN:/run/gnupg/S.gpg-agent,fork,mode=0600,unlink-early" \
      "TCP:${CONTAINED_GPG_BRIDGE_HOST}:${CONTAINED_GPG_BRIDGE_PORT}" >/dev/null 2>&1 &
for _ in 1 2 3 4 5 6 7 8 9 10; do
    [ -S /run/gnupg/S.gpg-agent ] && break
    sleep 0.1
done
[ -f /run/host-pubkeys.gpg ] && gpg --batch --no-tty --import /run/host-pubkeys.gpg >/dev/null 2>&1 || true
exec "$@"'
    if [ "${#CONTAINER_CMD[@]}" -eq 0 ]; then
        CONTAINER_CMD=(bash)
    fi
    CONTAINER_CMD=(bash -c "$bootstrap" _contained-bridge "${CONTAINER_CMD[@]}")
}

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------

usage() {
    cat <<'EOF'
Usage: contained [opts] -- [docker-opts...] -- [container-cmd...]

Run a tool inside a Debian-packaging container. cwd is bind-mounted so
`../foo.changes`, `../foo.dsc`, etc. resolve the same way as on the host.

Options:
  -c <image>       override the container image
  -v <mount>       extra bind mount (passed straight to docker -v)
  -i               interactive (docker -it)
  -h, -?, --help   show this help and exit

Args between the first '--' and second '--' go to `docker run`.
Args after the second '--' (or after the first, if there's no second)
are the command to run inside the container.

Environment overrides:
  CONTAINED_CONTAINER_RUNTIME   docker (default) | podman
  CONTAINED_CONTAINER_NAME      default container image
                                (default: ghcr.io/talhahavadar/contained-debdev:ubuntu-devel)
  CONTAINED_RUN_ARGS            extra flags for `docker run`
                                (default: --privileged --security-opt seccomp=unconfined;
                                 needed by sbuild's unshare backend on macOS runtimes)
  CONTAINED_HOST_GATEWAY_ALIAS  host.docker.internal (default) -- alias the
                                in-container side of the GPG bridge connects
                                to (macOS only)

Auto-passthrough (forwarded only when set on the host):
  DEBFULLNAME, DEBEMAIL, DEBSIGN_KEYID
  SSH_AUTH_SOCK -> /run/host-ssh-agent.sock

Auto-mount (read-only when host file exists):
  ~/.config/sbuild/config.pl -> /root/.config/sbuild/config.pl
  ~/.sbuildrc                -> /root/.sbuildrc          (legacy fallback)
  ~/.config/git/config       -> /root/.config/git/config (XDG)
  ~/.gitconfig               -> /root/.gitconfig         (legacy fallback)
  ~/.gnupg                   bridged for gpg-agent / YubiKey signing

Examples:
  # uscan a watch file using the default image
  contained uscan -v --no-download

  # interactive shell inside a specific image
  contained -i -c ghcr.io/talhahavadar/contained-debdev:debian-unstable -- bash

  # full sbuild run
  contained -c ghcr.io/talhahavadar/contained-debdev:debian-unstable \
      -- sbuild -d unstable --no-clean-source

  # extra bind mount for a local apt cache
  contained -c ghcr.io/talhahavadar/contained-debdev:debian-unstable \
      -v "$HOME/.cache/apt:/var/cache/apt" \
      -- sbuild -d unstable

  # add an extra docker flag on top of the defaults
  contained -- --cap-add SYS_PTRACE -- bash
EOF
}

# --help is a long option getopts can't parse; catch it before getopts. Stop
# at the first `--` so it doesn't pick up a `--help` aimed at the inner cmd.
for _arg in "$@"; do
    case $_arg in
    --help) usage; exit 0 ;;
    --) break ;;
    esac
done
unset _arg

while getopts ":c:v:ih" opt; do
    case $opt in
    c) CONTAINER="$OPTARG" ;;
    v) VOLUMES+=("$OPTARG") ;;
    i) INTERACTIVE=1 ;;
    h) usage; exit 0 ;;
    :)
        echo "Option -$OPTARG requires an argument" >&2
        exit 2
        ;;
    \?)
        # `-?` lands here because getopts treats `?` as the unknown-option
        # sentinel; detect it via OPTARG and treat it as help.
        if [ "$OPTARG" = "?" ]; then
            usage
            exit 0
        fi
        echo "Unknown option: -$OPTARG" >&2
        exit 2
        ;;
    esac
done
shift $((OPTIND - 1))

# getopts consumed the first "--"; split the remainder at the next "--".
# No further "--" => everything left is the container command.
DOCKER_EXTRA_ARGS=()
CONTAINER_CMD=()
_sep_seen=0
for arg in "$@"; do
    if [ "$_sep_seen" -eq 0 ] && [ "$arg" = "--" ]; then
        _sep_seen=1
        continue
    fi
    if [ "$_sep_seen" -eq 1 ]; then
        CONTAINER_CMD+=("$arg")
    else
        DOCKER_EXTRA_ARGS+=("$arg")
    fi
done
if [ "$_sep_seen" -eq 0 ]; then
    CONTAINER_CMD=("${DOCKER_EXTRA_ARGS[@]}")
    DOCKER_EXTRA_ARGS=()
fi

# ---------------------------------------------------------------------------
# Run
# ---------------------------------------------------------------------------

forward_packaging_env
mount_sbuild_config
mount_git_config
setup_gpg
forward_ssh_agent
if [ "$HOST_OS" = "Darwin" ]; then
    wrap_cmd_with_gpg_bridge
fi

VOLUME_ARGS=()
for v in "${VOLUMES[@]}"; do
    VOLUME_ARGS+=(-v "$v")
done

INTERACTIVE_ARGS=()
if [ "$INTERACTIVE" -eq 1 ]; then
    INTERACTIVE_ARGS=(-it)
fi

"${CONTAINER_RUNTIME}" run \
    "${INTERACTIVE_ARGS[@]}" --rm \
    "${VOLUME_ARGS[@]}" \
    "${SBUILD_CONFIG_MOUNTS[@]}" \
    "${GIT_CONFIG_MOUNTS[@]}" \
    "${GPG_MOUNTS[@]}" \
    "${ENV_ARGS[@]}" \
    "${DEFAULT_RUN_ARGS[@]}" \
    "${DOCKER_EXTRA_ARGS[@]}" \
    -w "${CONTAINER_WORK_DIR}" \
    "$CONTAINER" \
    "${CONTAINER_CMD[@]}"
