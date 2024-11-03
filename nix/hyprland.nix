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
  mkOutOfStoreSymlink = config.lib.file.mkOutOfStoreSymlink;
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
  imports = [
    ./hypr/settings.nix
    ./hypr/keybinds.nix
    ./hypr/cosmetics.nix
    ./hypr/hyprlock.nix
    ./hypr/waybar.nix
  ];

  config = mkIf (home_config.enable && device.system != "aarch64-darwin") {
    home.file = {
      ".config/hypr/scripts/volume.sh".source = mkOutOfStoreSymlink ../dot/hyprland/volume.sh;
    };
    home.packages = with pkgs; [
      xfce.thunar
      playerctl
      bibata-cursors
    ];
    programs.wlogout = {
      enable = true;
      layout = [
        {
          "label" = "lock";
          "action" = "hyprlock -q";
          "text" = "Lock";
          "keybind" = "l";
        }
        {
          "label" = "reboot";
          "action" = "systemctl reboot";
          "text" = "Reboot";
          "keybind" = "r";
        }
        {
          "label" = "shutdown";
          "action" = "systemctl poweroff";
          "text" = "Shutdown";
          "keybind" = "s";
        }
        {
          "label" = "logout";
          "action" = "loginctl kill-session $XDG_SESSION_ID";
          "text" = "Logout";
          "keybind" = "e";
        }
        {
          "label" = "suspend";
          "action" = "systemctl suspend";
          "text" = "Suspend";
          "keybind" = "u";
        }
        {
          "label" = "hibernate";
          "action" = "systemctl hibernate";
          "text" = "Hibernate";
          "keybind" = "h";
        }
      ];

    };
    xdg.portal = {
      enable = true;
      config.common.default = "*";
      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
      ];

    };
    programs.rofi = {
      enable = true;
      package = pkgs.rofi-wayland;
      font = "MesloLG Nerd Font";
    };

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
      ];
      extraConfig = ''
        # This is an example Hyprland config file.
        # Refer to the wiki for more information.
        # https://wiki.hyprland.org/Configuring/

        # Please note not all available settings / options are set here.
        # For a full list, see the wiki

        # You can split this configuration into multiple files
        # Create your files separately and then link them to this file like this:
        # source = ~/.config/hypr/myColors.conf


        ################
        ### MONITORS ###
        ################

        # See https://wiki.hyprland.org/Configuring/Monitors/
        monitor=,preferred,auto,auto


        ###################
        ### MY PROGRAMS ###
        ###################

        # See https://wiki.hyprland.org/Configuring/Keywords/

        # Set programs that you use
        $menu = rofi --show drun


        #################
        ### AUTOSTART ###
        #################

        # Autostart necessary processes (like notifications daemons, status bars, etc.)
        # Or execute your favorite apps at launch like this:

        # exec-once = $terminal
        exec-once = dconf write /org/gnome/desktop/interface/cursor-theme "'Bibata-Modern-Ice'"
        exec-once = hyprctl setcursor Bibata-Modern-Ice 24
        exec-once = nm-applet & blueman-applet &
        exec-once = waybar &
        # hyprpaper & firefox


        #############################
        ### ENVIRONMENT VARIABLES ###
        #############################

        # See https://wiki.hyprland.org/Configuring/Environment-variables/

        env = XCURSOR_SIZE,30
        env = HYPRCURSOR_SIZE,24
        env = CLUTTER_BACKEND,wayland
        env = GDK_BACKEND,wayland,x11
        env = QT_AUTO_SCREEN_SCALE_FACTOR,1.6
        env = QT_QPA_PLATFORM,wayland;xcb
        env = QT_QPA_PLATFORMTHEME,qt5ct
        env = QT_QPA_PLATFORMTHEME,qt6ct   
        env = QT_SCALE_FACTOR,1.6
        env = QT_WAYLAND_DISABLE_WINDOWDECORATION,1

        ##############################
        ### WINDOWS AND WORKSPACES ###
        ##############################

        # See https://wiki.hyprland.org/Configuring/Window-Rules/ for more
        # See https://wiki.hyprland.org/Configuring/Workspace-Rules/ for workspace rules

        # Example windowrule v1
        # windowrule = float, ^(kitty)$

        # Example windowrule v2
        # windowrulev2 = float,class:^(kitty)$,title:^(kitty)$

        # Ignore maximize requests from apps. You'll probably like this.
        windowrulev2 = suppressevent maximize, class:.*

        # Fix some dragging issues with XWayland
        windowrulev2 = nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0
      '';
    };
  };

}
