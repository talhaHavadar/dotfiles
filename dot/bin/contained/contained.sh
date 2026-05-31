#!/usr/bin/env bash
#
# Run a tool inside a Debian-packaging container. cwd is bind-mounted so
# `../foo.changes`, `../foo.dsc`, etc. resolve the same way as on the host.
#
# Layout: contained [opts] -- [docker-opts...] -- [container-cmd...]
#   getopts opts:  -c <image>   override the container image
#                  -v <mount>   extra bind mount (passed straight to docker -v)
#                  -i           interactive (docker -it)
#   Anything between the first '--' and the second '--' is forwarded to
#   `docker run` verbatim (e.g. extra --cap-add, --label, ...).
#   Anything after the second '--' (or after the first one if there's no
#   second) is the command to run inside the container.
#
# Environment overrides:
#   CONTAINED_CONTAINER_RUNTIME   default: docker          (e.g. podman)
#   CONTAINED_CONTAINER_NAME      default: ghcr.io/talhahavadar/contained-debdev:ubuntu-devel
#   CONTAINED_RUN_ARGS            default: --privileged --security-opt seccomp=unconfined
#                                 (these are needed by the contained-debdev
#                                 image on macOS runtimes; set to empty string
#                                 to disable, override to replace entirely)
#
# Auto-passthrough (forwarded to the container only when set on the host):
#   DEBFULLNAME, DEBEMAIL, DEBSIGN_KEYID
#   SSH_AUTH_SOCK -- mounted to /run/host-ssh-agent.sock and re-exported, so
#     git-over-ssh and ssh-format commit signing both route to the host agent
#     (incl. YubiKey via gpg-agent's enable-ssh-support socket).
#
# Auto-mount (only when the host file exists, mounted read-only):
#   ~/.config/sbuild/config.pl  -> /root/.config/sbuild/config.pl
#   ~/.sbuildrc                 -> /root/.sbuildrc          (legacy fallback)
#   ~/.config/git/config        -> /root/.config/git/config (XDG)
#   ~/.gitconfig                -> /root/.gitconfig         (legacy fallback)
#   ~/.gnupg                    -> /root/.gnupg             (pubring, key stubs
#                                                            -- gives the
#                                                            container's gpg
#                                                            read access to
#                                                            your keys; signing
#                                                            inside the
#                                                            container does NOT
#                                                            work on macOS
#                                                            Docker Desktop --
#                                                            do `git commit -S`
#                                                            and `debsign` on
#                                                            the host)
#
# Examples:
#
#   # uscan a watch file using the default image
#   contained uscan -v --no-download
#
#   # lintian against an already-built .changes
#   contained lintian -EviL -pedantic ../some_package.changes
#
#   # interactive shell inside a specific image
#   contained -i -c ghcr.io/talhahavadar/contained-debdev:debian-unstable -- bash
#
#   # full sbuild run -- CONTAINED_RUN_ARGS supplies the macOS-required flags
#   # (--privileged + --security-opt seccomp=unconfined) so no extra '--' needed
#   contained -c ghcr.io/talhahavadar/contained-debdev:debian-unstable \
#       -- sbuild -d unstable --no-clean-source
#
#   # same image with an extra bind mount for a local apt cache
#   contained -c ghcr.io/talhahavadar/contained-debdev:debian-unstable \
#       -v "$HOME/.cache/apt:/var/cache/apt" \
#       -- sbuild -d unstable
#
#   # add an extra docker flag on top of the defaults (e.g. extra capability)
#   contained -- --cap-add SYS_PTRACE -- bash

set -eo pipefail

CONTAINER_RUNTIME=${CONTAINED_CONTAINER_RUNTIME:-docker}
CONTAINER="${CONTAINED_CONTAINER_NAME:-ghcr.io/talhahavadar/contained-debdev:ubuntu-devel}"
VOLUMES=(
    "$PWD/..:/work"
)
CONTAINER_WORK_DIR="/work/$(basename "$PWD")"
INTERACTIVE=0

# Default docker run flags. The contained-debdev image needs --privileged
# (CAP_SYS_ADMIN for the chroot's /proc mount inside sbuild) and
# --security-opt seccomp=unconfined (lets unshare(CLONE_NEWUSER) through) on
# macOS container runtimes. Override via CONTAINED_RUN_ARGS env var.
default_run_args="--privileged --security-opt seccomp=unconfined"
# shellcheck disable=SC2206  # intentional word-split into array elements
DEFAULT_RUN_ARGS=(${CONTAINED_RUN_ARGS:-$default_run_args})

# Forward selected Debian packaging env vars from host into the container when
# they're set. `-e VAR` (without =VALUE) tells docker to copy the value from
# the current environment.
ENV_ARGS=()
for v in DEBFULLNAME DEBEMAIL DEBSIGN_KEYID; do
    if [ -n "${!v-}" ]; then
        ENV_ARGS+=(-e "$v")
    fi
done

# Helper: stage a host file into /tmp before bind-mounting it. On Nix-managed
# setups, host dotfiles are symlinks into /nix/store, and Docker Desktop /
# Apple `container` don't share /nix with the VM by default -- the symlink
# follow then fails with "mkdir source: file exists". Copying the file content
# into a tmp under /tmp (which is always in the runtime's shared paths)
# sidesteps this without requiring per-runtime sharing configuration. Files
# are cleaned up on script exit via the EXIT trap below.
STAGED_FILES=()
trap '[ ${#STAGED_FILES[@]} -gt 0 ] && rm -f "${STAGED_FILES[@]}"' EXIT
stage_for_mount() {
    local src="$1"
    local tmp
    tmp=$(mktemp -t contained-stage.XXXXXX)
    cat "$src" > "$tmp"
    STAGED_FILES+=("$tmp")
    printf '%s' "$tmp"
}

# Auto-mount the host's sbuild config (XDG path first, then legacy ~/.sbuildrc)
# so it overrides /etc/sbuild/sbuild.conf inside the image. Read-only because
# sbuild never writes back to its config.
SBUILD_CONFIG_MOUNTS=()
if [ -f "${HOME}/.config/sbuild/config.pl" ]; then
    SBUILD_CONFIG_MOUNTS+=(-v "$(stage_for_mount "${HOME}/.config/sbuild/config.pl"):/root/.config/sbuild/config.pl:ro")
elif [ -f "${HOME}/.sbuildrc" ]; then
    SBUILD_CONFIG_MOUNTS+=(-v "$(stage_for_mount "${HOME}/.sbuildrc"):/root/.sbuildrc:ro")
fi

# Forward host git config (XDG path first, then legacy ~/.gitconfig) so
# commits made inside the container pick up user.name, user.email, signing
# settings, URL rewrites, etc. Read-only -- a stray `git config --global` in
# the container should not corrupt host config.
GIT_CONFIG_MOUNTS=()
if [ -f "${HOME}/.config/git/config" ]; then
    GIT_CONFIG_MOUNTS+=(-v "$(stage_for_mount "${HOME}/.config/git/config"):/root/.config/git/config:ro")
elif [ -f "${HOME}/.gitconfig" ]; then
    GIT_CONFIG_MOUNTS+=(-v "$(stage_for_mount "${HOME}/.gitconfig"):/root/.gitconfig:ro")
fi

# YubiKey / GPG signing: bind-mount the host's ~/.gnupg into the container so
# its gpg can see pubring, key stubs, and gpg.conf. RW (not :ro) because gpg
# writes lockfiles into the homedir even for pure read operations and rejects
# the homedir otherwise. The YubiKey is the source of truth for any actual
# key material, so the worst a container-side gpg can do is scribble on the
# host's trustdb / pubring -- annoying but no cryptographic loss.
#
# Signing inside the container: does NOT work on macOS Docker Desktop today.
# The gpg-agent socket would need to be reachable through the bind-mount, but
# (a) sockets carried inside a directory bind-mount lose their socket type
# through virtiofs ("ls" reports "Operation not supported"), and (b) overlaying
# a single-file socket bind-mount on top of the dir mount fails at runc with
# "openat2 ... operation not supported" because virtiofs doesn't support
# mountpoint creation. Workflow: do `git commit -S` / `debsign foo.changes`
# on the host before/after the container session. Inside the container, run
# sbuild with --no-arch-any-sign-changes / --no-arch-all-sign-changes (or set
# $sign_changes = 0 in your sbuild config) and sign post-build on the host.
#
# This limitation does NOT apply on a Linux host -- gpg-agent socket
# forwarding works fine there, and the .gnupg mount alone is enough.
GPG_MOUNTS=()
if [ -d "${HOME}/.gnupg" ]; then
    GPG_MOUNTS+=(-v "${HOME}/.gnupg:/root/.gnupg")
fi

# Forward the SSH agent socket if one is set on the host. Mounted as a
# standalone single-file bind so it retains socket type (which a passenger
# of a virtiofs dir mount would not). On a YubiKey-via-gpg-agent host setup
# this socket is gpg-agent's ssh wrapper, so it routes ssh auth through the
# YubiKey too. Useful for git-over-ssh and ssh-format commit signing.
if [ -n "${SSH_AUTH_SOCK-}" ] && [ -S "${SSH_AUTH_SOCK}" ]; then
    GPG_MOUNTS+=(-v "${SSH_AUTH_SOCK}:/run/host-ssh-agent.sock")
    ENV_ARGS+=(-e "SSH_AUTH_SOCK=/run/host-ssh-agent.sock")
fi

while getopts ":c:v:i" opt; do
    case $opt in
    c) CONTAINER="$OPTARG" ;;
    v) VOLUMES+=("$OPTARG") ;;
    i) INTERACTIVE=1 ;;
    :)
        echo "Option -$OPTARG requires an argument" >&2
        exit 2
        ;;
    \?)
        echo "Unknown option: -$OPTARG" >&2
        exit 2
        ;;
    esac
done
shift $((OPTIND - 1))

VOLUME_ARGS=()
for v in "${VOLUMES[@]}"; do
    VOLUME_ARGS+=(-v "$v")
done

INTERACTIVE_ARGS=()
if [ "$INTERACTIVE" -eq 1 ]; then
    INTERACTIVE_ARGS=(-it)
fi

# Layout: contained [opts] -- [docker-opts...] -- [container-cmd...]
# getopts consumed the first "--"; split the remainder at the next "--".
# If no further "--", everything left is treated as the container command.
DOCKER_EXTRA_ARGS=()
CONTAINER_CMD=()
separator_seen=0
for arg in "$@"; do
    if [ "$separator_seen" -eq 0 ] && [ "$arg" = "--" ]; then
        separator_seen=1
        continue
    fi
    if [ "$separator_seen" -eq 1 ]; then
        CONTAINER_CMD+=("$arg")
    else
        DOCKER_EXTRA_ARGS+=("$arg")
    fi
done
if [ "$separator_seen" -eq 0 ]; then
    CONTAINER_CMD=("${DOCKER_EXTRA_ARGS[@]}")
    DOCKER_EXTRA_ARGS=()
fi

${CONTAINER_RUNTIME} run "${INTERACTIVE_ARGS[@]}" --rm "${VOLUME_ARGS[@]}" "${SBUILD_CONFIG_MOUNTS[@]}" "${GIT_CONFIG_MOUNTS[@]}" "${GPG_MOUNTS[@]}" "${ENV_ARGS[@]}" "${DEFAULT_RUN_ARGS[@]}" "${DOCKER_EXTRA_ARGS[@]}" -w "${CONTAINER_WORK_DIR}" "$CONTAINER" "${CONTAINER_CMD[@]}"
