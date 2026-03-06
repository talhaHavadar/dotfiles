#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.8"
# dependencies = [
#     "launchpadlib",
#     "keyring",
# ]
# ///
import argparse
import json
import os
import subprocess
import sys
import tempfile
from typing import Optional, Tuple

from launchpadlib.launchpad import Launchpad


EDITOR_TEMPLATE = """{title}

{description}
# ──────────────────────────────────────────────────────────────────────
# Create a new bug report for: {target}
#
# Line 1: Bug title (required, single line)
# Line 3+: Bug description (required, can be multiple lines)
#
# Lines starting with # are comments and will be ignored.
# Save and close the editor to submit, or leave empty to abort.
# ──────────────────────────────────────────────────────────────────────
"""


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Create a bug on Launchpad",
        epilog="Examples:\n"
        "  %(prog)s ubuntu                    # File bug against Ubuntu distribution\n"
        "  %(prog)s launchpad                 # File bug against Launchpad project\n"
        "  %(prog)s ubuntu/bash               # File bug against bash source package\n"
        "  %(prog)s ubuntu -t 'Bug title' -d 'Description'  # Non-interactive mode\n",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument(
        "target",
        help="Bug target: project name, distribution, or distribution/source-package",
    )
    parser.add_argument(
        "-t",
        "--title",
        help="Bug title (if not provided, opens editor)",
    )
    parser.add_argument(
        "-d",
        "--description",
        help="Bug description (if not provided, opens editor)",
    )
    parser.add_argument(
        "--tags",
        help="Space-separated tags for the bug",
    )
    parser.add_argument(
        "--private",
        action="store_true",
        help="Make the bug private",
    )
    parser.add_argument(
        "--security",
        action="store_true",
        help="Mark as security-related",
    )
    parser.add_argument(
        "--json",
        action="store_true",
        dest="json_output",
        help="Output result as JSON",
    )
    return parser.parse_args()


def get_editor() -> str:
    """Get the user's preferred editor."""
    return os.environ.get("EDITOR") or os.environ.get("VISUAL") or "vi"


def get_input_from_editor(
    target: str,
    title: Optional[str] = None,
    description: Optional[str] = None,
) -> Tuple[str, str]:
    """Open editor for user to enter title and description."""
    editor = get_editor()

    content = EDITOR_TEMPLATE.format(
        title=title or "",
        description=description or "",
        target=target,
    )

    with tempfile.NamedTemporaryFile(mode="w", suffix=".txt", delete=False) as f:
        f.write(content)
        temp_path = f.name

    try:
        result = subprocess.run([editor, temp_path])
        if result.returncode != 0:
            print("Editor exited with non-zero status", file=sys.stderr)
            sys.exit(1)

        with open(temp_path, "r") as f:
            lines = f.readlines()
    finally:
        os.unlink(temp_path)

    # Parse: remove comment lines, first non-empty line is title, rest is description
    non_comment_lines = [
        line.rstrip("\n") for line in lines if not line.startswith("#")
    ]

    # Find title (first non-empty line)
    title_line = ""
    desc_start = 0
    for i, line in enumerate(non_comment_lines):
        if line.strip():
            title_line = line.strip()
            desc_start = i + 1
            break

    # Description is everything after title (skip one blank line if present)
    desc_lines = non_comment_lines[desc_start:]
    if desc_lines and not desc_lines[0].strip():
        desc_lines = desc_lines[1:]

    description_text = "\n".join(desc_lines).strip()

    return title_line, description_text


def resolve_target(lp: Launchpad, target: str) -> str:
    """
    Resolve target string to a Launchpad bug target self_link.

    Formats:
    - "project-name" -> project
    - "distribution" -> distribution (e.g., "ubuntu")
    - "distribution/source-package" -> source package
    """
    if "/" in target:
        # distribution/source-package format
        distro_name, pkg_name = target.split("/", 1)
        try:
            distro = lp.distributions[distro_name]
            source_pkg = distro.getSourcePackage(name=pkg_name)
            return source_pkg.self_link
        except Exception as e:
            print(
                f"Error: Could not find source package '{pkg_name}' "
                f"in distribution '{distro_name}': {e}",
                file=sys.stderr,
            )
            sys.exit(1)

    # Try as project first, then distribution
    try:
        project = lp.projects[target]
        return project.self_link
    except Exception:
        pass

    try:
        distro = lp.distributions[target]
        return distro.self_link
    except Exception:
        pass

    print(
        f"Error: '{target}' is not a valid project or distribution",
        file=sys.stderr,
    )
    sys.exit(1)


def main():
    args = parse_args()

    # Get title and description
    if args.title and args.description:
        title = args.title
        description = args.description
    else:
        title, description = get_input_from_editor(
            target=args.target,
            title=args.title,
            description=args.description,
        )

    # Validate input
    if not title:
        print("Error: Bug title is required", file=sys.stderr)
        sys.exit(1)
    if not description:
        print("Error: Bug description is required", file=sys.stderr)
        sys.exit(1)

    # Connect to Launchpad
    try:
        lp = Launchpad.login_with(
            "lp-create-bug",
            "production",
            version="devel",
        )
    except Exception as e:
        print(f"Error: Failed to authenticate with Launchpad: {e}", file=sys.stderr)
        sys.exit(1)

    # Resolve target
    target_link = resolve_target(lp, args.target)

    # Build bug creation parameters
    bug_params = {
        "target": target_link,
        "title": title,
        "description": description,
    }

    if args.tags:
        bug_params["tags"] = args.tags

    if args.private:
        bug_params["private"] = True

    if args.security:
        bug_params["security_related"] = True

    # Create the bug
    try:
        bug = lp.bugs.createBug(**bug_params)
    except Exception as e:
        print(f"Error: Failed to create bug: {e}", file=sys.stderr)
        sys.exit(1)

    # Output result
    if args.json_output:
        output = {
            "id": bug.id,
            "link": bug.web_link,
        }
        print(json.dumps(output))
    else:
        print(f"{bug.id}\t{bug.web_link}")

    sys.exit(0)


if __name__ == "__main__":
    main()
