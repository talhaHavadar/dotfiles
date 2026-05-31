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
#   CONTAINED_CONTAINER_NAME      default: ghcr.io/talhahavadar/contained-debdev:ubuntu-resolute
#   CONTAINED_RUN_ARGS            default: --privileged --security-opt seccomp=unconfined
#                                 (these are needed by the contained-debdev
#                                 image on macOS runtimes; set to empty string
#                                 to disable, override to replace entirely)
#
# Auto-passthrough (forwarded to the container only when set on the host):
#   DEBFULLNAME, DEBEMAIL, DEBSIGN_KEYID
#
# Auto-mount (only when the host file exists, mounted read-only):
#   ~/.config/sbuild/config.pl  -> /root/.config/sbuild/config.pl
#   ~/.sbuildrc                 -> /root/.sbuildrc          (legacy fallback)
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

# Auto-mount the host's sbuild config (XDG path first, then legacy ~/.sbuildrc)
# so it overrides /etc/sbuild/sbuild.conf inside the image. Read-only because
# sbuild never writes back to its config.
SBUILD_CONFIG_MOUNTS=()
if [ -f "${HOME}/.config/sbuild/config.pl" ]; then
    SBUILD_CONFIG_MOUNTS+=(-v "${HOME}/.config/sbuild/config.pl:/root/.config/sbuild/config.pl:ro")
elif [ -f "${HOME}/.sbuildrc" ]; then
    SBUILD_CONFIG_MOUNTS+=(-v "${HOME}/.sbuildrc:/root/.sbuildrc:ro")
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

${CONTAINER_RUNTIME} run "${INTERACTIVE_ARGS[@]}" --rm "${VOLUME_ARGS[@]}" "${SBUILD_CONFIG_MOUNTS[@]}" "${ENV_ARGS[@]}" "${DEFAULT_RUN_ARGS[@]}" "${DOCKER_EXTRA_ARGS[@]}" -w "${CONTAINER_WORK_DIR}" "$CONTAINER" "${CONTAINER_CMD[@]}"
