{ config, lib, ... }:
let
  home_config = config.host.home.windowManagers.hyprland;
in
with lib;
{
  config = mkIf (home_config.enable) {
    wayland.windowManager.hyprland.settings = {
      decoration = {
        "rounding" = 10;
        "active_opacity" = 1.0;
        "inactive_opacity" = 0.95;
        "fullscreen_opacity" = 1.0;

        "dim_inactive" = false;
        "dim_strength" = 5.0e-2;
        "dim_special" = 0.8;

        "drop_shadow" = true;
        "shadow_range" = 6;
        "shadow_render_power" = 1;
        "col.shadow" = "rgb(0C0C14)";
        "col.shadow_inactive" = "0x50000000";

        blur = {
          enabled = true;
          size = 6;
          passes = 2;
          ignore_opacity = true;
          new_optimizations = true;
          special = true;
        };
      };

      animations = {
        enabled = "yes";

        bezier = [
          "wind, 0.05, 0.9, 0.1, 1.05"
          "winIn, 0.1, 1.1, 0.1, 1.1"
          "winOut, 0.3, -0.3, 0, 1"
          "liner, 1, 1, 1, 1"
          "overshot, 0.05, 0.9, 0.1, 1.05"
          "smoothOut, 0.5, 0, 0.99, 0.99"
          "smoothIn, 0.5, -0.5, 0.68, 1.5"
        ];
        animation = [
          "windows, 1, 6, wind, slide"
          "windowsIn, 1, 5, winIn, slide"
          "windowsOut, 1, 3, smoothOut, slide"
          "windowsMove, 1, 5, wind, slide"
          "border, 1, 1, liner"
          "borderangle, 1, 180, liner, loop #used by rainbow borders and rotating colors"
          "fade, 1, 3, smoothOut"
          "workspaces, 1, 5, overshot"
        ];

        # animations for -git or version >0.42.0
        #animation = workspacesIn, 1, 5, winIn, slide
        #animation = workspacesOut, 1, 5, winOut, slide
      };

    };
  };
}
