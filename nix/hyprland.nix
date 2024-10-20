{
  config,
  inputs,
  lib,
  device,
  pkgs,
  ...
}:
let
  home_config = config.host.home.windowManagers.hyprland;
  home = config.home;
  hyprland = pkgs.hyprland;
in
# hyprspace = inputs.hyprspace.packages.${device.system}.Hyprspace;
with lib;
{
  options = {
    host.home.windowManagers.hyprland = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Tiling Window Manager";
      };
    };
  };

  config = mkIf (home_config.enable && device.system != "aarch64-darwin") {
    home.sessionVariables.NIXOS_OZONE_WL = "1";
    wayland.windowManager.hyprland = {
      enable = true;
      package = hyprland;
      xwayland.enable = true;
      systemd = {
        enable = true;
        variables = [ "--all" ];
        extraCommands = [
          "systemctl --user stop graphical-session.target"
          "systemctl --user start hyprland-session.target"
        ];
      };
      plugins = [
        pkgs.hyprlandPlugins.hyprexpo
        # inputs.hyprland-plugins.packages.${device.system}.hyprexpo
      ];
      extraConfig = ''
        # Default Configs
        $configs = $HOME/.config/hypr/configs

        source=$configs/settings.conf
        source=$configs/keybinds.conf

        source=startup_apps.conf
        source=env.conf
        source=monitors.conf
        source=laptops.conf
        source=laptop_display.conf
        source=cosmetics.conf

        source=window_rules.conf

        # https://wiki.hyprland.org/Configuring/Workspace-Rules/

        # Assigning workspace to a certain monitor
        # workspace = 1, monitor:eDP-1
        # workspace = 2, monitor:DP-2

        workspace = name:work
        # example rules (from wiki)
        # workspace = 3, rounding:false, decorate:false
        # workspace = name:coding, rounding:false, decorate:false, gapsin:0, gapsout:0, border:false, decorate:false, monitor:DP-1
        # workspace = 8,bordersize:8
        # workspace = name:Hello, monitor:DP-1, default:true
        # workspace = name:gaming, monitor:desc:Chimei Innolux Corporation 0x150C, default:true
        # workspace = 5, on-created-empty:[float] firefox
        # workspace = special:scratchpad, on-created-empty:foot '';
    };
  };

}
