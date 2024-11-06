{
  config,
  lib,
  pkgs,
  ...
}:
let
  home_config = config.host.home.windowManagers.hyprland;
  mkOutOfStoreSymlink = config.lib.file.mkOutOfStoreSymlink;
in
with lib;
{
  config = mkIf (home_config.enable) {
    home.file = {
      ".config/hypr/scripts/wallpaperUpdate.sh".source = mkOutOfStoreSymlink ../../dot/hyprland/wallpaperUpdate.sh;
    };
    services.hyprpaper = {
      enable = true;
      settings = {
        ipc = "on";
        splash = false;
      };
    };

  };
}
