#!/usr/bin/env bash
# requires bash 4.0+ due to maps
set -eu

# Team short code map
declare -A TEAM_MAP=(
    ["bwk"]="bullwinkle-team"
    ["limerick"]="limerick-team"
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

# Clone using git-ubuntu first
git ubuntu clone $REPO
# # Clone the repository
cd "$REPO"
git ubuntu export-orig

git remote add "$TEAM_SHORT" "git+ssh://$LP_USER@git.launchpad.net/~$LP_TEAM/ubuntu/+source/$REPO"

git remote update
echo "Remotes configured:"
git remote -v
