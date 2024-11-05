#!/bin/env bash


laptop_display_conf="$HOME/.config/hypr/laptop_display.conf"

other_monitor=$(hyprctl monitors all | grep "ID 1")
if [[ ! -z "${other_monitor}" ]]; then
    # echo "there is another monitor $other_monitor"
    echo "monitor = eDP-1, disable" > $laptop_display_conf
else
    # echo "there is no another monitor $other_monitor"
    echo "" > $laptop_display_conf
fi
