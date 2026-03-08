#!/usr/bin/env bash
#
# river-lid-handler - Handle laptop lid events for River compositor
#
# This script monitors /proc/acpi/button/lid/LID0/state and adjusts
# display configuration accordingly using wlr-randr.
#
# Requirements:
# - wlr-randr
# - WAYLAND_DISPLAY must be set (inherited from systemd user session)
#
# Logic:
#   Lid closed + external monitor + laptop enabled  -> disable laptop display
#   Lid open   + laptop disabled                    -> enable laptop display
#   (kanshi handles the layout after we enable/disable)

set -euo pipefail

readonly LID_STATE_FILE="/proc/acpi/button/lid/LID0/state"
readonly LAPTOP_DISPLAY="eDP-1"
readonly POLL_INTERVAL="${RIVER_LID_POLL_INTERVAL:-2}"

log() {
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

get_lid_state() {
	# Returns "open" or "closed"
	if [[ -f "$LID_STATE_FILE" ]]; then
		awk '{print $2}' "$LID_STATE_FILE"
	else
		echo "unknown"
	fi
}

has_external_monitor() {
	# Check if any monitor other than eDP-1 is connected and enabled
	local outputs
	outputs=$(wlr-randr 2>/dev/null) || return 1

	# Look for any output that is not eDP-1 and is enabled
	echo "$outputs" | awk '
        /^[^ ]/ { current_output = $1 }
        /Enabled: yes/ && current_output != "eDP-1" { found = 1 }
        END { exit !found }
    '
}

is_laptop_display_enabled() {
	# Check if laptop display is currently enabled
	wlr-randr 2>/dev/null | awk '
        /^eDP-1/ { in_edp = 1 }
        /^[^ ]/ && !/^eDP-1/ { in_edp = 0 }
        in_edp && /Enabled: yes/ { found = 1 }
        END { exit !found }
    '
}

disable_laptop_display() {
	log "Disabling laptop display (${LAPTOP_DISPLAY})"
	if ! wlr-randr --output "$LAPTOP_DISPLAY" --off 2>&1; then
		log "Warning: Failed to disable laptop display"
		return 1
	fi
}

enable_laptop_display() {
	log "Enabling laptop display (${LAPTOP_DISPLAY})"
	if ! wlr-randr --output "$LAPTOP_DISPLAY" --on 2>&1; then
		log "Warning: Failed to enable laptop display"
		return 1
	fi
	# Let kanshi handle the proper configuration after enabling
}

check_wayland() {
	if [[ -z "${WAYLAND_DISPLAY:-}" ]]; then
		log "Error: WAYLAND_DISPLAY not set"
		return 1
	fi
	if [[ -z "${XDG_RUNTIME_DIR:-}" ]]; then
		log "Error: XDG_RUNTIME_DIR not set"
		return 1
	fi
	if [[ ! -S "${XDG_RUNTIME_DIR}/${WAYLAND_DISPLAY}" ]]; then
		log "Error: Wayland socket not found at ${XDG_RUNTIME_DIR}/${WAYLAND_DISPLAY}"
		return 1
	fi
	return 0
}

handle_state() {
	local lid_state="$1"
	local has_external=false
	local laptop_enabled=false

	# Check external monitor presence
	if has_external_monitor; then
		has_external=true
	fi

	# Check current laptop display state
	if is_laptop_display_enabled; then
		laptop_enabled=true
	fi

	log "State: lid=$lid_state external=$has_external laptop_enabled=$laptop_enabled"

	case "$lid_state" in
	closed)
		# Lid closed: disable laptop if external is connected and laptop is on
		if [[ "$has_external" == "true" ]] && [[ "$laptop_enabled" == "true" ]]; then
			disable_laptop_display
		fi
		# If no external and lid closed, system will suspend via logind
		;;
	open)
		# Lid open: enable laptop if it's disabled
		# This covers:
		# - Opening lid with external connected
		# - Waking from suspend where external was disconnected
		if [[ "$laptop_enabled" == "false" ]]; then
			enable_laptop_display
		fi
		;;
	esac
}

main() {
	log "Starting river-lid-handler (poll interval: ${POLL_INTERVAL}s)"
	log "WAYLAND_DISPLAY: ${WAYLAND_DISPLAY:-unset}"
	log "XDG_RUNTIME_DIR: ${XDG_RUNTIME_DIR:-unset}"

	# Verify Wayland session is available
	if ! check_wayland; then
		log "Wayland session not available, exiting"
		exit 1
	fi

	local last_state=""

	# Main polling loop
	while true; do
		# Re-check Wayland availability (River might have exited)
		if ! check_wayland; then
			log "Wayland session lost, exiting"
			exit 0
		fi

		local current_state
		current_state=$(get_lid_state)

		# Only act on state changes
		if [[ "$current_state" != "$last_state" ]]; then
			if [[ -n "$last_state" ]]; then
				log "Lid state changed: $last_state -> $current_state"
			else
				log "Initial lid state: $current_state"
			fi
			handle_state "$current_state"
			last_state="$current_state"
		fi

		sleep "$POLL_INTERVAL"
	done
}

main "$@"
