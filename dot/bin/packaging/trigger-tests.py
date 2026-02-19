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
    package_version = None
    owner = args.owner
    ppa = args.ppa_name

    # Find the PPA
    logger.info(f"Looking up PPA: {owner}/{ppa}")
    lp_owner = lp.people[owner]
    lp_ppa = lp_owner.getPPAByName(name=ppa)
    logger.info(f"Found PPA: {lp_ppa.web_link}")

    # Get the source package and its targeted architectures from builds
    logger.info(f"Fetching source package builds for: {package}")
    sources = lp_ppa.getPublishedSources(source_name=package, status="Published")
    targeted_archs = set()
    for source in sources:
        package_version = source.source_package_version
        builds = source.getBuilds()
        for build in builds:
            targeted_archs.add(build.arch_tag)
    logger.info(f"Targeted architectures: {targeted_archs}")

    # Filter by user-specified arch if provided
    if args.arch:
        targeted_archs = {args.arch} & targeted_archs
        if not targeted_archs:
            logger.warning(
                f"Specified arch {args.arch} is not a build target for this package"
            )

    # Get published binaries for your package
    logger.info(f"Fetching published binaries for package: {package}")
    binaries = lp_ppa.getPublishedBinaries()
    # map of arch => [binary_name]
    published_binaries = {}
    for b in binaries:
        if b.status == "Published" and b.source_package_name == package:
            arch = b.distro_arch_series_link.split("/")[-1]
            bins = published_binaries.get(arch, [])
            bins.append(b.binary_package_name)
            published_binaries[arch] = bins

    logger.info(f"Published binaries by arch: {published_binaries}")

    # Track remaining archs that haven't been triggered
    remaining_archs = targeted_archs.copy()

    for arch in targeted_archs:
        if arch in published_binaries and len(published_binaries[arch]) > 0:
            params = {
                "release": release,
                "package": package,
                "arch": arch,
                "trigger": f"{package}/{package_version}",
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
            f"Remaining architectures not yet published: {sorted(remaining_archs)}"
        )
        print(*sorted(remaining_archs))

    sys.exit(len(remaining_archs))


if __name__ == "__main__":
    main()
