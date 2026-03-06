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
import re
import subprocess
import sys
import tempfile
from typing import Optional, Tuple

from launchpadlib.launchpad import Launchpad


EDITOR_TEMPLATE = """{commit_message}

{description}
# ──────────────────────────────────────────────────────────────────────
# Propose merge: {source} -> {target}
#
# Line 1: Commit message (optional, used when merging)
# Line 3+: Description (optional, can be multiple lines)
#
# Lines starting with # are comments and will be ignored.
# Save and close the editor to submit, or leave empty to abort.
# ──────────────────────────────────────────────────────────────────────
"""


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Create a merge proposal on Launchpad",
        epilog="Examples:\n"
        "  %(prog)s                                        # Propose to 'pkg' remote\n"
        "  %(prog)s --source-remote origin --target-remote pkg  # Fork workflow\n"
        "  %(prog)s --target ubuntu/devel                  # Propose to ubuntu/devel\n"
        "  %(prog)s -m 'Fix bug' -d 'Details'              # Non-interactive mode\n",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument(
        "--source-remote",
        default="origin",
        help="Git remote for source branch (default: origin)",
    )
    parser.add_argument(
        "--target-remote",
        default="pkg",
        help="Git remote for target branch (default: pkg)",
    )
    parser.add_argument(
        "--source",
        help="Source branch (default: current branch)",
    )
    parser.add_argument(
        "--target",
        help="Target branch for merge (default: main, master, or ubuntu/devel)",
    )
    parser.add_argument(
        "--prerequisite",
        help="Prerequisite branch (must be merged before this)",
    )
    parser.add_argument(
        "-m",
        "--commit-message",
        help="Commit message for the merge",
    )
    parser.add_argument(
        "-d",
        "--description",
        help="Description/initial comment for the proposal",
    )
    parser.add_argument(
        "--reviewer",
        action="append",
        dest="reviewers",
        metavar="USER",
        help="Add reviewer (can be repeated)",
    )
    parser.add_argument(
        "--wip",
        action="store_true",
        help="Mark as work-in-progress (not ready for review)",
    )
    parser.add_argument(
        "--json",
        action="store_true",
        dest="json_output",
        help="Output result as JSON",
    )
    return parser.parse_args()


def run_git(*args: str) -> str:
    """Run a git command and return output."""
    result = subprocess.run(
        ["git", *args],
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        return ""
    return result.stdout.strip()


def get_current_branch() -> str:
    """Get the current git branch name."""
    branch = run_git("rev-parse", "--abbrev-ref", "HEAD")
    if branch and branch != "HEAD":
        return branch

    # Detached HEAD - try to find a branch pointing to the same commit
    branches = run_git("branch", "--points-at", "HEAD", "--format=%(refname:short)")
    if branches:
        # Filter out detached HEAD indicator lines (start with "(")
        for line in branches.split("\n"):
            if line and not line.startswith("("):
                return line

    print("Error: Could not determine current branch", file=sys.stderr)
    print("  (detached HEAD and no branch points to this commit)", file=sys.stderr)
    sys.exit(1)


def get_default_target_branch(remote: str) -> str:
    """Determine the default target branch (main, master, or devel)."""
    # Check remote refs
    refs = run_git("ls-remote", "--heads", remote)
    for candidate in ["main", "master", "ubuntu/devel"]:
        if f"refs/heads/{candidate}" in refs:
            return candidate
    return "main"


def parse_lp_remote(remote: str) -> Tuple[Optional[str], Optional[str]]:
    """Parse Launchpad repository path from git remote.

    Returns (repo_path, owner) or (None, None) if not a Launchpad remote.

    Supported formats:
    - git+ssh://USER@git.launchpad.net/~OWNER/PROJECT/+git/REPO
    - git+ssh://USER@git.launchpad.net/PROJECT
    - https://git.launchpad.net/~OWNER/PROJECT/+git/REPO
    """
    remote_url = run_git("remote", "get-url", remote)
    if not remote_url:
        return None, None

    # Patterns for Launchpad git URLs
    patterns = [
        # git+ssh://user@git.launchpad.net/~owner/project/+git/repo
        r"git\+ssh://[^@]+@git\.launchpad\.net/(.+)",
        # https://git.launchpad.net/~owner/project/+git/repo
        r"https://git\.launchpad\.net/(.+)",
        # git@git.launchpad.net:~owner/project/+git/repo
        r"git@git\.launchpad\.net:(.+)",
    ]

    for pattern in patterns:
        match = re.match(pattern, remote_url)
        if match:
            path = match.group(1).rstrip("/").rstrip(".git")
            return path, None

    return None, None


def get_editor() -> str:
    """Get the user's preferred editor."""
    return os.environ.get("EDITOR") or os.environ.get("VISUAL") or "vi"


def get_input_from_editor(
    source: str,
    target: str,
    commit_message: Optional[str] = None,
    description: Optional[str] = None,
) -> Tuple[str, str]:
    """Open editor for user to enter commit message and description."""
    editor = get_editor()

    content = EDITOR_TEMPLATE.format(
        commit_message=commit_message or "",
        description=description or "",
        source=source,
        target=target,
    )

    with tempfile.NamedTemporaryFile(mode="w", suffix=".txt", delete=False) as f:
        f.write(content)
        temp_path = f.name

    try:
        with open("/dev/tty", "r") as tty_in, open("/dev/tty", "w") as tty_out:
            result = subprocess.run([editor, temp_path], stdin=tty_in, stdout=tty_out)
        if result.returncode != 0:
            print("Editor exited with non-zero status", file=sys.stderr)
            sys.exit(1)

        with open(temp_path, "r") as f:
            lines = f.readlines()
    finally:
        os.unlink(temp_path)

    # Parse: remove comment lines
    non_comment_lines = [
        line.rstrip("\n") for line in lines if not line.startswith("#")
    ]

    # Template format: line 1 = commit message, blank line, then description
    # Line 0 is commit message (may be empty)
    commit_msg = non_comment_lines[0].strip() if non_comment_lines else ""

    # Find the blank separator line, description starts after it
    desc_start = 1
    for i in range(1, len(non_comment_lines)):
        if not non_comment_lines[i].strip():
            desc_start = i + 1
            break

    # Description is everything after the blank separator
    desc_lines = non_comment_lines[desc_start:]
    if desc_lines and not desc_lines[0].strip():
        desc_lines = desc_lines[1:]

    description_text = "\n".join(desc_lines).strip()

    return commit_msg, description_text


def main():
    args = parse_args()

    # Get repository paths from git remotes
    source_repo_path, _ = parse_lp_remote(args.source_remote)
    if not source_repo_path:
        print(f"Error: '{args.source_remote}' is not a Launchpad git remote", file=sys.stderr)
        print("  Remote URL must be git.launchpad.net", file=sys.stderr)
        sys.exit(1)

    target_repo_path, _ = parse_lp_remote(args.target_remote)
    if not target_repo_path:
        print(f"Error: '{args.target_remote}' is not a Launchpad git remote", file=sys.stderr)
        print("  Remote URL must be git.launchpad.net", file=sys.stderr)
        sys.exit(1)

    # Get source branch
    source_branch = args.source or get_current_branch()

    # Get target branch
    target_branch = args.target or get_default_target_branch(args.target_remote)

    # Get commit message and description
    if args.commit_message:
        commit_message = args.commit_message
        description = args.description or ""
    else:
        commit_message, description = get_input_from_editor(
            source=source_branch,
            target=target_branch,
            commit_message=args.commit_message,
            description=args.description,
        )

    # Connect to Launchpad
    try:
        lp = Launchpad.login_with(
            "lp-propose-merge",
            "production",
            version="devel",
        )
    except Exception as e:
        print(f"Error: Failed to authenticate with Launchpad: {e}", file=sys.stderr)
        sys.exit(1)

    # Get the repositories
    try:
        source_repo = lp.git_repositories.getByPath(path=source_repo_path)
        if not source_repo:
            print(f"Error: Source repository not found: {source_repo_path}", file=sys.stderr)
            sys.exit(1)
    except Exception as e:
        print(f"Error: Failed to find source repository: {e}", file=sys.stderr)
        sys.exit(1)

    try:
        target_repo = lp.git_repositories.getByPath(path=target_repo_path)
        if not target_repo:
            print(f"Error: Target repository not found: {target_repo_path}", file=sys.stderr)
            sys.exit(1)
    except Exception as e:
        print(f"Error: Failed to find target repository: {e}", file=sys.stderr)
        sys.exit(1)

    # Get source and target refs
    try:
        source_ref = source_repo.getRefByPath(path=f"refs/heads/{source_branch}")
        if not source_ref:
            print(f"Error: Source branch not found: {source_branch}", file=sys.stderr)
            sys.exit(1)
    except Exception as e:
        print(f"Error: Failed to find source branch: {e}", file=sys.stderr)
        sys.exit(1)

    try:
        target_ref = target_repo.getRefByPath(path=f"refs/heads/{target_branch}")
        if not target_ref:
            print(f"Error: Target branch not found: {target_branch}", file=sys.stderr)
            sys.exit(1)
    except Exception as e:
        print(f"Error: Failed to find target branch: {e}", file=sys.stderr)
        sys.exit(1)

    # Get prerequisite ref if specified (from target repo)
    prereq_ref = None
    if args.prerequisite:
        try:
            prereq_ref = target_repo.getRefByPath(path=f"refs/heads/{args.prerequisite}")
            if not prereq_ref:
                print(
                    f"Error: Prerequisite branch not found: {args.prerequisite}",
                    file=sys.stderr,
                )
                sys.exit(1)
        except Exception as e:
            print(f"Error: Failed to find prerequisite branch: {e}", file=sys.stderr)
            sys.exit(1)

    # Resolve reviewers
    reviewers = []
    review_types = []
    if args.reviewers:
        for reviewer_name in args.reviewers:
            try:
                reviewer = lp.people[reviewer_name]
                reviewers.append(reviewer)
                review_types.append(None)  # Default review type
            except Exception as e:
                print(
                    f"Warning: Could not find reviewer '{reviewer_name}': {e}",
                    file=sys.stderr,
                )

    # Create merge proposal
    mp_params = {
        "merge_target": target_ref,
        "needs_review": not args.wip,
    }

    if commit_message:
        mp_params["commit_message"] = commit_message

    if description:
        mp_params["initial_comment"] = description

    if prereq_ref:
        mp_params["merge_prerequisite"] = prereq_ref

    if reviewers:
        mp_params["reviewers"] = reviewers
        mp_params["review_types"] = review_types

    try:
        mp = source_ref.createMergeProposal(**mp_params)
    except Exception as e:
        print(f"Error: Failed to create merge proposal: {e}", file=sys.stderr)
        sys.exit(1)

    # Output result
    if args.json_output:
        output = {
            "id": mp.id if hasattr(mp, "id") else None,
            "link": mp.web_link,
            "source": source_branch,
            "target": target_branch,
            "status": mp.queue_status,
        }
        print(json.dumps(output))
    else:
        print(f"{mp.web_link}")


if __name__ == "__main__":
    main()
