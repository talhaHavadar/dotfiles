{ config, lib, ... }:
let
  home_config = config.host.home.windowManagers.hyprland;
  mkOutOfStoreSymlink = config.lib.file.mkOutOfStoreSymlink;
in
with lib;
{
  config = mkIf (home_config.enable) {
    home.file = {
      ".config/hypr/scripts/laptopDisplayHandler.sh".source = mkOutOfStoreSymlink ../../dot/hyprland/laptopDisplayHandler.sh;
    };
    wayland.windowManager.hyprland.settings = {
      "$scriptsDir" = "$HOME/.config/hypr/scripts";
      "$laptop_display_conf" = "$HOME/.config/hypr/laptop_display.conf";

      # See https://wiki.hyprland.org/Configuring/Monitors/
      monitor = [
        "desc:BNQ BenQ PD3220U 27P00235019, preferred, 0x0, 1.6"
        ",preferred,auto,1.6"
      ];
      bind = [
        "$mainMod SHIFT, M, exec, $scriptsDir/laptopDisplayHandler.sh"
      ];
      bindl = [
        ", switch:off:Lid Switch,exec,echo \"monitor = eDP-1, preferred, auto, 2\" > $laptop_display_conf"
        ", switch:on:Lid Switch,exec, $scriptsDir/laptopDisplayHandler.sh"
      ];
    };
  };
}
