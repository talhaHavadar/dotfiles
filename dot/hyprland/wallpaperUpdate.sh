#!/usr/bin/env bash
wp="~/Pictures/wallpapers/$(ls ~/Pictures/wallpapers | sort -R | tail -1)"

hyprctl hyprpaper reload "$wp"
hyprctl hyprpaper wallpaper ",$wp"
