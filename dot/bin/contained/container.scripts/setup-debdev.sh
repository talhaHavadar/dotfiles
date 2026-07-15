#!/bin/sh
# Common setup for the contained-debdev images. Invoked from
# Containerfile.debian and Containerfile.ubuntu so the shared apt package list,
# sbuild config, subuid wiring, default ~/.bashrc bits, and quiltrc-dpkg all
# live in exactly one place.
#
# Optional env var:
#   EXTRA_PACKAGES   space-separated list of additional apt packages to install
#                    (Containerfile.ubuntu uses this for ubuntu-keyring)
set -eu

apt-get update
# shellcheck disable=SC2086  # intentional word-split of EXTRA_PACKAGES
apt-get install -y --no-install-recommends \
	python3 \
	gawk \
	curl \
	ssh \
	debhelper \
	dh-python \
	debian-archive-keyring \
	wget \
	aptitude \
	bash-completion \
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
	socat \
	uidmap \
	zstd \
	dput-ng \
	reportbug \
	licenserecon \
	autopkgtest \
	${EXTRA_PACKAGES:-}
rm -rf /var/lib/apt/lists/*

# Default sbuild config. Loaded as /etc/sbuild/sbuild.conf -- gets overridden
# by ~/.config/sbuild/config.pl when the host mounts one in via contained.sh.
install -d /etc/sbuild
cat >/etc/sbuild/sbuild.conf <<'PERL'
# Chroot backend: unshare is what we set the image up for; see Containerfile
# headers for the deep dive on why this is the right choice on macOS runtimes.
$chroot_mode = 'unshare';
# Keep the cached mmdebstrap chroot tarball between builds so we don't pay the
# bootstrap cost on every invocation.
$unshare_mmdebstrap_keep_tarball = 1;

# Build arch:all by default.
$build_arch_all = 1;
# Drop build artifacts in a sibling directory rather than the source tree.
$build_dir = '../build-area';

# Use ~90% of available CPUs for parallel builds.
$build_environment = {
    'DEB_BUILD_OPTIONS' => 'parallel=' . (int(`nproc` * 0.8) || 1),
};

# Clean up on success but leave failed builds around for inspection.
$purge_build_directory = 'successful';
$purge_session = 'successful';
$purge_build_deps = 'successful';

# Disable apt's privilege-drop sandbox inside the build chroot. sbuild's
# unshare backend (sbuild-usernsexec) only maps a single subuid into the
# nested user namespace -- one for the build user, mapped from outer UID 1
# to inner UID 1 (see ChrootUnshare.pm: --map-users "$idmap[0][2],1,1").
# The chroot's _apt user (UID 65534) is NOT mappable in that namespace, so
# apt's http method failing with "setgroups (22: Invalid argument)" /
# "setegid 65534 failed" is the symptom of apt trying to drop privileges
# to a UID that doesn't exist. Telling apt to stay as root for downloads
# avoids the privilege drop entirely. This only affects the build chroot;
# apt sandboxing on the host / in the container image itself is unchanged.
# Matters most under rootless podman, but the workaround is harmless
# everywhere so we apply it unconditionally.
#
# Quoting note: sbuild's ChrootUnshare::get_command_internal always wraps
# this command in /bin/sh -c, so we pass a STRING (one shell command line)
# rather than an argv arrayref. The arrayref form would get joined with
# spaces into a single string via Build.pm: '$args{COMMAND_STR} =
# "@{$command}"', losing the shell-arg structure and producing the wrong
# script after the /bin/sh -c wrap.
$external_commands->{"chroot-setup-commands"} = [
    "echo 'APT::Sandbox::User \"root\";' > /etc/apt/apt.conf.d/00sbuild-no-apt-sandbox",
];

# Run lintian after every build.
$run_lintian = 1;
$lintian_opts = ['-EvIL', 'pedantic'];

# experimental and rc-buggy need the Debian archive keyring explicitly because
# mmdebstrap's auto-detection of the keyring doesn't cover those suites.
push @$unshare_mmdebstrap_extra_args,
    qr/^(experimental|rc-buggy)$/ => [
        '--keyring=/usr/share/keyrings/debian-archive-keyring.gpg',
    ];

# Debian experimental: apt's default resolver won't pull priority-1 packages
# even when they satisfy a versioned build-dep. Aptitude does. Detect the
# target distribution from the sbuild command line so we can override only
# for that one suite without affecting normal builds.
use Getopt::Long qw(GetOptionsFromArray);
my $cli_dist;
{
    my @argv_copy = @ARGV;
    Getopt::Long::Configure(qw(pass_through no_auto_abbrev));
    GetOptionsFromArray(\@argv_copy, 'd|dist|distribution=s' => \$cli_dist);
}
if (($cli_dist // '') eq 'experimental') {
    $build_dep_resolver = 'aptitude';
}

1;
PERL

# Subid range for root: unshare(1) reads /etc/sub{u,g}id for the invoking user
# to decide what range to map into the new namespace. Without this entry root
# would get "uid range not allowed" from the kernel.
echo 'root:100000:65536' >>/etc/subuid
echo 'root:100000:65536' >>/etc/subgid

# Standard Debian-recommended quiltrc for working with debian/patches.
cat >/root/.quiltrc-dpkg <<'EOF'
QUILT_PATCHES=debian/patches
QUILT_NO_DIFF_INDEX=1
QUILT_NO_DIFF_TIMESTAMPS=1
QUILT_REFRESH_ARGS="-p ab"
QUILT_DIFF_OPTS="--show-c-function"
QUILT_COLORS="diff_hdr=1;32:diff_add=1;34:diff_rem=1;31:diff_hunk=1;33:diff_ctx=35:diff_cctx=33"
EOF

# dquilt alias + completion wiring for interactive shells.
cat >>/root/.bashrc <<'EOF'

# Debian quilt helper: use the .quiltrc-dpkg above and wire the same bash
# completion as the upstream quilt command.
alias dquilt='quilt --quiltrc=${HOME}/.quiltrc-dpkg'
if [ -f /usr/share/bash-completion/completions/quilt ]; then
    . /usr/share/bash-completion/completions/quilt
    complete -F _quilt_completion $_quilt_complete_opt dquilt
fi
EOF

cat >>/root/.dput.cf <<'EOF'
[mentors]
fqdn = mentors.debian.net
incoming = /upload
method = https
allow_unsigned_uploads = 0
progress_indicator = 2
# Allow uploads for UNRELEASED packages
allowed_distributions = .*
EOF
