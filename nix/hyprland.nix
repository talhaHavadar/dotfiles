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
    home.packages = with pkgs; [
      waybar
      rofi-wayland
      # hyprlock
      # mattermost-desktop
    ];
    xdg.portal.enable = true;
    xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    # xdg.desktopEntries.Mattermost = {
    #   name = "Mattermost";
    #   comment = "Mattermost Desktop application for Linux";
    #   exec = "${pkgs.mattermost-desktop}/bin/mattermost-desktop --ozone-platform-hint=x11";
    #   terminal = false;
    #   type = "Application";
    #   mimeType = [ "x-scheme-handler/mattermost" ];
    #   icon = "${pkgs.mattermost-desktop}/share/mattermost-desktop/app_icon.png";
    #   categories = [
    #     "Network"
    #     "InstantMessaging"
    #   ];
    # };
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

        #source=$configs/settings.conf
        #source=$configs/keybinds.conf

        #source=startup_apps.conf
        #source=env.conf
        #source=monitors.conf
        #source=laptops.conf
        #source=laptop_display.conf
        #source=cosmetics.conf

        #source=window_rules.conf

        # https://wiki.hyprland.org/Configuring/Workspace-Rules/

        # Assigning workspace to a certain monitor
        # workspace = 1, monitor:eDP-1
        # workspace = 2, monitor:DP-2

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
