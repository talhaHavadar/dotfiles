{ config, lib, ... }:
let
  home_config = config.host.home.windowManagers.hyprland;
in
with lib;
{
  config = mkIf (home_config.enable) {
    wayland.windowManager.hyprland.settings = {
      # See https://wiki.hyprland.org/Configuring/Environment-variables/
      env = [
        "XCURSOR_SIZE,30"
        "HYPRCURSOR_SIZE,24"
        "CLUTTER_BACKEND,wayland"
        "GDK_BACKEND,wayland,x11"
        "QT_AUTO_SCREEN_SCALE_FACTOR,2"
        "QT_QPA_PLATFORM,wayland;xcb"
        "QT_QPA_PLATFORMTHEME,qt5ct"
        "QT_QPA_PLATFORMTHEME,qt6ct   "
        "QT_SCALE_FACTOR,2"
        "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
        "GDK_SCALE,2"
      ];
    };
  };
}
