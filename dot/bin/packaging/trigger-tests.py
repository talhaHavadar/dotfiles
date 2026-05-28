#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.13"
# dependencies = [
#     "launchpadlib",
#     "keyring",
#     "requests",
# ]
# ///
import argparse
import http.cookiejar
import logging
import sys
import os

import requests
from launchpadlib.launchpad import Launchpad


def parse_args():
    parser = argparse.ArgumentParser(
        description="Request autopkgtests for a package in a PPA"
    )
    parser.add_argument(
        "package",
        help="The source package name to test",
    )
    parser.add_argument(
        "ppa",
        help="The PPA in format owner/ppa-name",
    )
    parser.add_argument(
        "-r",
        "--release",
        default="resolute",
        help="Ubuntu release codename (default: resolute)",
    )
    parser.add_argument(
        "-a",
        "--arch",
        help="Target architecture (e.g., amd64, arm64). If not specified, triggers for all available architectures.",
    )
    args = parser.parse_args()

    # Split ppa into owner and ppa name
    if "/" not in args.ppa:
        parser.error("PPA must be in format owner/ppa-name")
    args.owner, args.ppa_name = args.ppa.split("/", 1)

    return args


# Configure logging
logging.basicConfig(
    level=logging.DEBUG, format="%(asctime)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)


SUCCESSFUL_BUILD_STATE = "Successfully built"


def main():
    args = parse_args()

    # Enable HTTP request logging
    # logging.getLogger("urllib3").setLevel(logging.DEBUG)

    # Load cookies from a Netscape-format cookie file
    # Export from browser using an extension like "cookies.txt"
    cookie_jar = http.cookiejar.MozillaCookieJar(
        f"{os.getenv('HOME')}/cookies.autopkgtest.txt"
    )
    cookie_jar.load()

    session = requests.Session()
    session.cookies = cookie_jar

    # Log in anonymously
    # lp = Launchpad.login_anonymously("ppa-checker", "production", version="devel")
    lp = Launchpad.login_with(
        "ppa-checker",
        "production",
        version="devel",
    )

    release = args.release
    package = args.package
    owner = args.owner
    ppa = args.ppa_name

    # Find the PPA
    logger.info(f"Looking up PPA: {owner}/{ppa}")
    lp_owner = lp.people[owner]
    lp_ppa = lp_owner.getPPAByName(name=ppa)
    logger.info(f"Found PPA: {lp_ppa.web_link}")

    distro_series = lp.distributions["ubuntu"].getSeries(name_or_version=release)

    # A newer source sitting in Pending means the currently-Published source
    # is about to be superseded. Triggering anything in that window would
    # test the soon-to-be-stale binaries against a soon-to-be-stale trigger
    # string, so defer the whole task for a later tq-worker retry.
    pending_sources = list(
        lp_ppa.getPublishedSources(
            source_name=package,
            status="Pending",
            distro_series=distro_series,
        )
    )
    if pending_sources:
        logger.info(
            "Pending source(s) for %s in %s: %s — full retry",
            package,
            release,
            [s.source_package_version for s in pending_sources],
        )
        sys.exit(255)

    # The single Published source row is the target version.
    published_sources = list(
        lp_ppa.getPublishedSources(
            source_name=package,
            status="Published",
            distro_series=distro_series,
        )
    )
    if not published_sources:
        # Exit 255 signals "no source published yet, retry later"
        sys.exit(255)
    target_source = published_sources[0]
    target_version = target_source.source_package_version
    logger.info(f"Target source: {package}/{target_version}")

    targeted_archs = set()
    unbuilt_archs = {}
    for build in target_source.getBuilds():
        targeted_archs.add(build.arch_tag)
        if build.buildstate != SUCCESSFUL_BUILD_STATE:
            unbuilt_archs[build.arch_tag] = build.buildstate

    if not targeted_archs:
        sys.exit(255)

    logger.info(f"Targeted architectures: {targeted_archs}")

    # Filter by user-specified arch if provided
    if args.arch:
        targeted_archs = {args.arch} & targeted_archs
        if not targeted_archs:
            logger.warning(
                f"Specified arch {args.arch} is not a build target for this package"
            )

    # Per-arch binary counts restricted to the target source version.
    # Publisher can leave binaries in Pending for hours after a build
    # finishes; until every binary on an arch is Published, the autopkgtest
    # runner would install the previous version's still-Published binaries.
    logger.info(f"Fetching published binaries for package: {package}")
    binaries_at_target = {
        arch: {"published": 0, "pending": 0} for arch in targeted_archs
    }
    for b in lp_ppa.getPublishedBinaries():
        if b.source_package_name != package:
            continue
        if b.binary_package_version != target_version:
            continue
        arch = b.distro_arch_series_link.rsplit("/", 1)[-1]
        if arch not in binaries_at_target:
            continue
        if b.status == "Published":
            binaries_at_target[arch]["published"] += 1
        elif b.status == "Pending":
            binaries_at_target[arch]["pending"] += 1

    logger.info(f"Binaries at {target_version} by arch: {binaries_at_target}")

    # Track remaining archs that haven't been triggered
    remaining_archs = set(targeted_archs)

    for arch in sorted(targeted_archs):
        if arch in unbuilt_archs:
            logger.info(f"Skipping {arch}: build state is {unbuilt_archs[arch]!r}")
            continue
        counts = binaries_at_target[arch]
        if counts["pending"] > 0 or counts["published"] == 0:
            logger.info(
                f"Skipping {arch}: binaries at {target_version} not fully "
                f"published (pending={counts['pending']} "
                f"published={counts['published']})"
            )
            continue
        params = {
            "release": release,
            "package": package,
            "arch": arch,
            "trigger": f"{package}/{target_version}",
            "ppa": f"{owner}/{ppa}",
            "all-proposed": "1",
        }
        url = "https://autopkgtest.ubuntu.com/request.cgi"
        logger.info(f"Requesting autopkgtest for {package} on {arch}")
        logger.debug(f"Request params: {params}")
        session.get(url, params=params)
        remaining_archs.discard(arch)

    if remaining_archs:
        logger.warning(
            f"Remaining architectures not yet ready: {sorted(remaining_archs)}"
        )
        print(*sorted(remaining_archs))

    sys.exit(len(remaining_archs))


if __name__ == "__main__":
    main()
