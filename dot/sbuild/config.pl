# Name to use as override in .changes files for the Maintainer: field
# (mandatory, no default!).
$maintainer_name='Talha Can Havadar <talha.can.havadar@canonical.com>';

# Default distribution to build.
$distribution = "resolute";
# Build arch-all by default.
$build_arch_all = 1;

# When to purge the build directory afterwards; possible values are "never",
# "successful", and "always".  "always" is the default. It can be helpful
# to preserve failing builds for debugging purposes.  Switch these comments
# if you want to preserve even successful builds, and then use
# "schroot -e --all-sessions" to clean them up manually.
$purge_build_directory = 'successful';
$purge_session = 'successful';
$purge_build_deps = 'successful';
# $purge_build_directory = 'never';
# $purge_session = 'never';
# $purge_build_deps = 'never';
$chroot_mode="unshare";
$unshare_mmdebstrap_keep_tarball = 1;
push @$unshare_mmdebstrap_extra_args,
    qr/^(experimental|rc-buggy)$/ => [
        '--keyring=/usr/share/keyrings/debian-archive-keyring.gpg',
    ];

# Detect target distribution from the command line so we can apply
# per-distribution overrides for scalars that sbuild doesn't expose
# a native per-dist mechanism for (e.g. $build_dep_resolver).
use Getopt::Long qw(GetOptionsFromArray);
my $cli_dist;
{
    my @argv_copy = @ARGV;
    Getopt::Long::Configure(qw(pass_through no_auto_abbrev));
    GetOptionsFromArray(\@argv_copy, 'd|dist|distribution=s' => \$cli_dist);
}
my $target_dist = $cli_dist // $distribution;

# Debian experimental: apt's default resolver won't pull priority-1
# packages even when they satisfy a versioned build-dep. Aptitude does.
# Keep the apt resolver everywhere else so local Ubuntu builds match
# what Launchpad's buildds do.
if ($target_dist eq 'experimental') {
    $build_dep_resolver = 'aptitude';
}

# Use 90% of available CPUs for parallel builds
$build_environment = {
    'DEB_BUILD_OPTIONS' => 'parallel=' . (int(`nproc` * 0.9) || 1),
};

$dpkg_source_opts = [
    '--extend-diff-ignore=(^|/)\.jj/',
    '-I.jj',
];

# Directory for writing build logs to
$log_dir=$ENV{HOME}."/sbuild/logs";
$build_dir="../build-area";

##############################################################################
# POST-BUILD RELATED (turn off functionality by setting variables to 0)
##############################################################################
$run_lintian = 1;
$lintian_opts = ['-EvIL', 'pedantic'];
# $run_piuparts = 1;
# $piuparts_opts = ['--schroot', '%r-%a-sbuild', '--no-eatmydata'];
$run_autopkgtest = 1;
$autopkgtest_root_args = '';
$autopkgtest_opts = [ '--', 'lxd', "ubuntu:$distribution" ];

# don't remove this, Perl needs it:
1;
