#!/usr/bin/env bash
WALLPAPER_DIR="$HOME/Pictures/Wallpaper-Bank/wallpapers"

selected_wallpaper=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | shuf -n 1)

if [[ -z "$selected_wallpaper" ]]; then
    echo "Error: No wallpapers found in $WALLPAPER_DIR" >&2
    exit 1
fi

pkill -x swaybg 2>/dev/null
exec swaybg -i "$selected_wallpaper" -m fill
