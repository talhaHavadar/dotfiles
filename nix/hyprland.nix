{
  config,
  inputs,
  lib,
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
    ./hypr/env.nix
    ./hypr/settings.nix
    ./hypr/keybinds.nix
    ./hypr/monitors.nix
    ./hypr/cosmetics.nix
    ./hypr/hyprlock.nix
    ./hypr/waybar.nix
    ./hypr/hyprpaper.nix
    inputs.walker.homeManagerModules.default
  ];

  config = mkIf (home_config.enable && pkgs.system != "aarch64-darwin") {
    home.file = {
      ".config/hypr/scripts/volume.sh".source = mkOutOfStoreSymlink ../dot/hyprland/volume.sh;
    };

    programs.walker = {
      enable = true;
      runAsService = true;

      # All options from the config.json can be used here.
      config = {
        search.placeholder = "Example";
        ui.fullscreen = true;
        list = {
          height = 200;
        };
        websearch.prefix = "?";
        switcher.prefix = "/";
      };

      # If this is not set the default styling is used.
      # style = ''
      #   * {
      #     color: #dcd7ba;
      #   }
      # '';
    };

    systemd.user = {
      services = {
        reset_hyprland_laptop_display = {
          Unit = {
            Description = "Systemd Service to Reset Hyprland Monitor Config";
          };

          Service = {
            Type = "simple";
            ExecStart = "/usr/bin/env bash -c echo '' > ${home.homeDirectory}/.config/hypr/laptop_display.conf";
            Restart = "no";
          };
        };
      };
    };

    home.packages = with pkgs; [
      xfce.thunar
      playerctl
      bibata-cursors
      pwvucontrol
      hyprsunset
    ];
    programs.bash = {
      initExtra = ''
        export QT_IM_MODULE=fcitx
        export XMODIFIERS=@im=fcitx
      '';
    };

    i18n.inputMethod = {
      enabled = "fcitx5";
      fcitx5 = {
        waylandFrontend = true;
        addons = with pkgs; [
          fcitx5-mozc
        ];
      };
    };

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
        exec-once = touch ~/.config/hypr/laptop_display.conf
        source=laptop_display.conf

        ###################
        ### MY PROGRAMS ###
        ###################

        # See https://wiki.hyprland.org/Configuring/Keywords/

        # Set programs that you use
        $menu = walker

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
        exec-once = hyprpaper
        exec-once = hyprsunset &
        exec-once = walker --gapplication-service
        exec-once = sleep 2s && ~/.config/hypr/scripts/wallpaperUpdate.sh

        # hyprpaper & firefox

        ##############################
        ### WINDOWS AND WORKSPACES ###
        ##############################

        #windowrule = center,^(pavucontrol|org.pulseaudio.pavucontrol|com.saivert.pwvucontrol)

        # WINDOWRULE v2

        ## Ignore maximize requests from apps. You'll probably like this.
        windowrulev2 = suppressevent maximize, class:.*

        ## Fix some dragging issues with XWayland
        windowrulev2 = nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0

        #windowrulev2 = idleinhibit fullscreen, class:^(*)$
        #windowrulev2 = idleinhibit fullscreen, title:^(*)$
        windowrulev2 = idleinhibit fullscreen, fullscreen:1

        ## Picture-in-Picture
        windowrulev2 = move 72% 7%, title:^(Picture-in-Picture)$ 
        windowrulev2 = float, title:^(Picture-in-Picture)$
        windowrulev2 = opacity 0.95 0.75, title:^(Picture-in-Picture)$
        windowrulev2 = size 25% 25%, title:^(Picture-in-Picture)$
        windowrulev2 = pin, title:^(Picture-in-Picture)$

        windowrulev2 = move 72% 7%, title:^([Mm]eet -) class:(Google-chrome)
        windowrulev2 = float, title:^([Mm]eet -) class:(Google-chrome)
        windowrulev2 = opacity 1.0 0.90, title:^([Mm]eet -) class:(Google-chrome)
        windowrulev2 = size 15% 25%, title:^([Mm]eet -) class:(Google-chrome)
        windowrulev2 = pin, title:^([Mm]eet -) class:(Google-chrome)

        # windowrule v2 - float
        windowrulev2 = float, class:^(org.kde.polkit-kde-authentication-agent-1)$ 
        windowrulev2 = float, class:([Zz]oom|onedriver|onedriver-launcher)$
        windowrulev2 = float, class:(xdg-desktop-portal-gtk)
        windowrulev2 = float, class:(org.gnome.Calculator), title:(Calculator)
        windowrulev2 = float, class:(codium|codium-url-handler|VSCodium), title:(Add Folder to Workspace)
        windowrulev2 = float, class:^([Rr]ofi)$
        windowrulev2 = float, class:^(eog|org.gnome.Loupe)$ # image viewer
        windowrulev2 = float, class:^(pavucontrol|org.pulseaudio.pavucontrol|com.saivert.pwvucontrol)$
        windowrulev2 = float, class:^(nwg-look|qt5ct|qt6ct)$
        windowrulev2 = float, class:^(mpv|com.github.rafostar.Clapper)$
        windowrulev2 = float, class:^(nm-applet|nm-connection-editor|blueman-manager|.blueman-manager-wrapped)$
        windowrulev2 = float, class:^(gnome-system-monitor|org.gnome.SystemMonitor|io.missioncenter.MissionCenter)$ # system monitor
        windowrulev2 = float, class:^([Yy]ad)$ 
        windowrulev2 = float, class:^(wihotspot(-gui)?)$ # wifi hotspot
        windowrulev2 = float, class:^(file-roller|org.gnome.FileRoller)$ # archive manager
        windowrulev2 = float, class:^([Bb]aobab|org.gnome.[Bb]aobab)$ # Disk usage analyzer
        windowrulev2 = float, title:(Kvantum Manager)
        #windowrulev2 = float, class:^([Ss]team)$,title:^((?![Ss]team).*|[Ss]team [Ss]ettings)$
        windowrulev2 = float, class:^([Qq]alculate-gtk)$

        # windowrule v2 - size
        windowrulev2 = size 70% 70%, class:^(gnome-system-monitor|org.gnome.SystemMonitor|io.missioncenter.MissionCenter)$
        windowrulev2 = size 70% 70%, class:^(xdg-desktop-portal-gtk)$
        windowrulev2 = size 60% 70%, title:(Kvantum Manager)
        windowrulev2 = size 60% 70%, class:^(qt6ct)$
        windowrulev2 = size 70% 70%, class:^(evince|wihotspot(-gui)?)$
        windowrulev2 = size 60% 70%, class:^(file-roller|org.gnome.FileRoller)$
        windowrulev2 = size 60% 70%, class:^([Ww]hatsapp-for-linux)$

        ## File Browser
        windowrulev2 = opacity 0.9 0.8, class:^([Tt]hunar|org.gnome.Nautilus)$

        windowrulev2 = center, class:([Nn]autilus), title:(File Operation Progress)
        windowrulev2 = center, class:([Nn]autilus), title:(Confirm to replace files)
        windowrulev2 = float, class:([Nn]autilus), title:(File Operation Progress)
        windowrulev2 = float, class:([Nn]autilus), title:(Confirm to replace files)

        windowrulev2 = center, class:([Tt]hunar), title:(File Operation Progress)
        windowrulev2 = center, class:([Tt]hunar), title:(Confirm to replace files)
        windowrulev2 = float, class:([Tt]hunar), title:(File Operation Progress)
        windowrulev2 = float, class:([Tt]hunar), title:(Confirm to replace files)

        ## Web Browser
        #windowrulev2 = workspace 2, class:^([Ff]irefox|org.mozilla.firefox|[Ff]irefox-esr)$
        #windowrulev2 = workspace 2, class:^([Gg]oogle-chrome(-beta|-dev|-unstable)?)$
        windowrulev2 = opacity 0.95 0.9, class:^([Ff]irefox|org.mozilla.firefox|[Ff]irefox-esr)$
        windowrulev2 = opacity 0.98 0.9, class:^(google-chrome(-beta|-dev|-unstable)?)$
        windowrulev2 = opacity 0.94 0.86, class:^(chrome-.+-Default)$ # Chrome PWAs

        ## Imagers
        windowrulev2 = workspace 3, class:(org.raspberrypi.)
        windowrulev2 = center, class:(org.raspberrypi.)
        windowrulev2 = float, class:(org.raspberrypi.)

        # windowrule v2 move to workspace
        windowrulev2 = workspace 6 silent, class:(Mattermost)
        windowrulev2 = workspace 1, class:^([Tt]hunderbird)$
      '';
    };
  };

}
