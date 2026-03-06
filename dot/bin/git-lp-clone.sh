#!/usr/bin/env bash
# requires bash 4.0+ due to maps
set -eu

# Team short code map
declare -A TEAM_MAP=(
	["bwk"]="bullwinkle-team"
)

# Resolve team short code to full name
resolve_team() {
	local input="$1"
	echo "${TEAM_MAP[$input]:-$input}"
}

# Get short code for team (reverse lookup), returns full name if no short code
get_team_short() {
	local team="$1"
	for key in "${!TEAM_MAP[@]}"; do
		if [[ "${TEAM_MAP[$key]}" == "$team" ]]; then
			echo "$key"
			return
		fi
	done
	echo "$team"
}

OPTS=$(getopt -o '' --long team: -n 'git-lp-clone' -- "$@")
eval set -- "$OPTS"

while true; do
	case "$1" in
	--team)
		LP_TEAM="$2"
		shift 2
		;;
	--)
		shift
		break
		;;
	*) break ;;
	esac
done

if [ $# -eq 0 ]; then
	echo "Usage: git ${0##*/git-} [--team <team>] <repo>"
	echo "  --team    Launchpad team or short code (e.g., bwk)"
	exit 1
fi

LP_USER="$(git config gitubuntu.lpuser)"
LP_TEAM_INPUT="${LP_TEAM:-$LP_USER}"
LP_TEAM="$(resolve_team "$LP_TEAM_INPUT")"
TEAM_SHORT="$(get_team_short "$LP_TEAM")"
REPO="$1"

# Clone the repository
git clone "git+ssh://$LP_USER@git.launchpad.net/~$LP_TEAM/ubuntu/+source/$REPO"
cd "$REPO"

# Rename origin to team short name
git remote rename origin "$TEAM_SHORT"

# Add ubuntu archive remote (pkg)
git remote add pkg "https://git.launchpad.net/ubuntu/+source/$REPO"
git remote set-url --push pkg "git+ssh://$LP_USER@git.launchpad.net/ubuntu/+source/$REPO"

# Add user remote if different from team
if [[ "$LP_USER" != "$LP_TEAM" ]]; then
	git remote add "$LP_USER" "https://git.launchpad.net/~$LP_USER/ubuntu/+source/$REPO"
	git remote set-url --push "$LP_USER" "git+ssh://$LP_USER@git.launchpad.net/~$LP_USER/ubuntu/+source/$REPO"
fi

git remote update
echo "Remotes configured:"
git remote -v
