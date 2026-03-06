#!/usr/bin/env bash

# Check if at least one argument is provided
if [ $# -eq 0 ]; then
	echo "Usage: $0 <command> [arguments...]"
	echo "
Example: $0 create-bug --help
See available packaging binaries:

$(basename -a "$HOME"/.local/bin/lp-tools-*)
    "
	exit 1
fi

command="$1"

# Shift to remove the first argument, leaving only the remaining arguments
shift
full_command="$0-${command}"

exec "$full_command" "$@"
