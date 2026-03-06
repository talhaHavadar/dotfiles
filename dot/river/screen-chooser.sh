#!/usr/bin/env bash
# Screen chooser for xdg-desktop-portal-wlr
# Note: Window capture not supported on River (missing ext_foreign_toplevel_image_capture_source_manager_v1)

wlr-randr | grep -oP '^\S+' | fuzzel --dmenu -p "Share monitor: " | xargs -I{} echo "Monitor: {}"
