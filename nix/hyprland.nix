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
    ./hypr/keybinds.nix
    ./hypr/cosmetics.nix
    ./hypr/hyprlock.nix
  ];

  config = mkIf (home_config.enable && device.system != "aarch64-darwin") {
    home.file = {
      ".config/hypr/keybinds.conf".source = mkOutOfStoreSymlink ../dot/hyprland/keybinds.conf;
    };
    home.packages = with pkgs; [
      waybar
      xfce.thunar
    ];
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
        $fileManager = dolphin
        $menu = wofi --show drun


        #################
        ### AUTOSTART ###
        #################

        # Autostart necessary processes (like notifications daemons, status bars, etc.)
        # Or execute your favorite apps at launch like this:

        # exec-once = $terminal
        # exec-once = nm-applet &
        # exec-once = waybar & hyprpaper & firefox


        #############################
        ### ENVIRONMENT VARIABLES ###
        #############################

        # See https://wiki.hyprland.org/Configuring/Environment-variables/

        env = XCURSOR_SIZE,24
        env = HYPRCURSOR_SIZE,24


        #####################
        ### LOOK AND FEEL ###
        #####################

        # Refer to https://wiki.hyprland.org/Configuring/Variables/

        # https://wiki.hyprland.org/Configuring/Variables/#general
        general {
            gaps_in = 5
            gaps_out = 20

            border_size = 2

            # https://wiki.hyprland.org/Configuring/Variables/#variable-types for info about colors
            col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
            col.inactive_border = rgba(595959aa)

            # Set to true enable resizing windows by clicking and dragging on borders and gaps
            resize_on_border = false

            # Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
            allow_tearing = false

            layout = dwindle
        }

        # https://wiki.hyprland.org/Configuring/Variables/#decoration
        decoration {
            rounding = 10

            # Change transparency of focused and unfocused windows
            active_opacity = 1.0
            inactive_opacity = 1.0

            drop_shadow = true
            shadow_range = 4
            shadow_render_power = 3
            col.shadow = rgba(1a1a1aee)

            # https://wiki.hyprland.org/Configuring/Variables/#blur
            blur {
                enabled = true
                size = 3
                passes = 1

                vibrancy = 0.1696
            }
        }

        # https://wiki.hyprland.org/Configuring/Variables/#animations
        animations {
            enabled = yes, please :)

            # Default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more

            bezier = easeOutQuint,0.23,1,0.32,1
            bezier = easeInOutCubic,0.65,0.05,0.36,1
            bezier = linear,0,0,1,1
            bezier = almostLinear,0.5,0.5,0.75,1.0
            bezier = quick,0.15,0,0.1,1

            animation = global, 1, 10, default
            animation = border, 1, 5.39, easeOutQuint
            animation = windows, 1, 4.79, easeOutQuint
            animation = windowsIn, 1, 4.1, easeOutQuint, popin 87%
            animation = windowsOut, 1, 1.49, linear, popin 87%
            animation = fadeIn, 1, 1.73, almostLinear
            animation = fadeOut, 1, 1.46, almostLinear
            animation = fade, 1, 3.03, quick
            animation = layers, 1, 3.81, easeOutQuint
            animation = layersIn, 1, 4, easeOutQuint, fade
            animation = layersOut, 1, 1.5, linear, fade
            animation = fadeLayersIn, 1, 1.79, almostLinear
            animation = fadeLayersOut, 1, 1.39, almostLinear
            animation = workspaces, 1, 1.94, almostLinear, fade
            animation = workspacesIn, 1, 1.21, almostLinear, fade
            animation = workspacesOut, 1, 1.94, almostLinear, fade
        }

        # Ref https://wiki.hyprland.org/Configuring/Workspace-Rules/
        # "Smart gaps" / "No gaps when only"
        # uncomment all if you wish to use that.
        # workspace = w[t1], gapsout:0, gapsin:0
        # workspace = w[tg1], gapsout:0, gapsin:0
        # workspace = f[1], gapsout:0, gapsin:0
        # windowrulev2 = bordersize 0, floating:0, onworkspace:w[t1]
        # windowrulev2 = rounding 0, floating:0, onworkspace:w[t1]
        # windowrulev2 = bordersize 0, floating:0, onworkspace:w[tg1]
        # windowrulev2 = rounding 0, floating:0, onworkspace:w[tg1]
        # windowrulev2 = bordersize 0, floating:0, onworkspace:f[1]
        # windowrulev2 = rounding 0, floating:0, onworkspace:f[1]

        # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
        dwindle {
            pseudotile = true # Master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
            preserve_split = true # You probably want this
        }

        # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
        master {
            new_status = master
        }

        # https://wiki.hyprland.org/Configuring/Variables/#misc
        misc {
            force_default_wallpaper = -1 # Set to 0 or 1 to disable the anime mascot wallpapers
            disable_hyprland_logo = false # If true disables the random hyprland logo / anime girl background. :(
        }


        #############
        ### INPUT ###
        #############

        # https://wiki.hyprland.org/Configuring/Variables/#input
        input {
            kb_layout = us
            kb_variant =
            kb_model =
            kb_options =
            kb_rules =

            follow_mouse = 1

            sensitivity = 0 # -1.0 - 1.0, 0 means no modification.

            touchpad {
                natural_scroll = false
            }
        }

        # https://wiki.hyprland.org/Configuring/Variables/#gestures
        gestures {
            workspace_swipe = false
        }

        # Example per-device config
        # See https://wiki.hyprland.org/Configuring/Keywords/#per-device-input-configs for more
        device {
            name = epic-mouse-v1
            sensitivity = -0.5
        }



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
