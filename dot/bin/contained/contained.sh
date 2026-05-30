#!/usr/bin/env bash
#
# Run a tool inside a Debian-packaging container. cwd is bind-mounted so
# `../foo.changes`, `../foo.dsc`, etc. resolve the same way as on the host.
#
# Layout: contained [opts] -- [docker-opts...] -- [container-cmd...]
#   getopts opts:  -c <image>   override the container image (default: salsa-ci build:unstable)
#                  -v <mount>   extra bind mount (passed straight to docker -v)
#                  -i           interactive (docker -it)
#   Anything between the first '--' and the second '--' is forwarded to
#   `docker run` verbatim (e.g. --privileged, --security-opt ...).
#   Anything after the second '--' (or after the first one if there's no
#   second) is the command to run inside the container.
#
# Examples:
#
#   # uscan a watch file with the default salsa-ci image
#   contained uscan -v --no-download
#
#   # lintian against an already-built .changes
#   contained lintian -EviL -pedantic ../some_package.changes
#
#   # interactive shell inside a specific image
#   contained -i -c ghcr.io/talhahavadar/contained-debdev:debian-unstable -- bash
#
#   # full sbuild run -- the docker flags after the first '--' are required on
#   # macOS container runtimes (Docker Desktop, Apple `container`, OrbStack,
#   # Colima); they're harmless on Linux Docker
#   contained -c ghcr.io/talhahavadar/contained-debdev:debian-unstable \
#       -- --privileged --security-opt seccomp=unconfined \
#       -- sbuild -d unstable --no-clean-source
#
#   # same image with an extra bind mount for a local apt cache
#   contained -c ghcr.io/talhahavadar/contained-debdev:debian-unstable \
#       -v "$HOME/.cache/apt:/var/cache/apt" \
#       -- --privileged --security-opt seccomp=unconfined \
#       -- sbuild -d unstable
#
# Override the runtime (default: docker) with CONTAINED_CONTAINER_RUNTIME=podman.

set -eo pipefail

CONTAINER_RUNTIME=${CONTAINED_CONTAINER_RUNTIME:-docker}
CONTAINER="registry.salsa.debian.org/salsa-ci-team/pipeline/build:unstable"
VOLUMES=(
    "$PWD/..:/work"
)
CONTAINER_WORK_DIR="/work/$(basename "$PWD")"
INTERACTIVE=0

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

${CONTAINER_RUNTIME} run "${INTERACTIVE_ARGS[@]}" --rm "${VOLUME_ARGS[@]}" "${DOCKER_EXTRA_ARGS[@]}" -w "${CONTAINER_WORK_DIR}" "$CONTAINER" "${CONTAINER_CMD[@]}"
