#!/bin/sh
# Common setup for the contained-debdev images. Invoked from
# Containerfile.debian and Containerfile.ubuntu so the shared apt package list,
# sbuild config, and subuid wiring live in exactly one place.
#
# Optional env var:
#   EXTRA_PACKAGES   space-separated list of additional apt packages to install
#                    (Containerfile.ubuntu uses this for ubuntu-keyring)
set -eu

apt-get update
# shellcheck disable=SC2086  # intentional word-split of EXTRA_PACKAGES
apt-get install -y --no-install-recommends \
    ca-certificates \
    devscripts \
    eatmydata \
    equivs \
    fakeroot \
    git \
    git-buildpackage \
    lintian \
    mmdebstrap \
    pristine-tar \
    quilt \
    sbuild \
    uidmap \
    zstd \
    ${EXTRA_PACKAGES:-}
rm -rf /var/lib/apt/lists/*

install -d /etc/sbuild
printf '%s\n' \
    "\$chroot_mode = 'unshare';" \
    "1;" \
    > /etc/sbuild/sbuild.conf

# Subid range for root: unshare(1) reads /etc/sub{u,g}id for the invoking user
# to decide what range to map into the new namespace. Without this entry root
# would get "uid range not allowed" from the kernel.
echo 'root:100000:65536' >> /etc/subuid
echo 'root:100000:65536' >> /etc/subgid
