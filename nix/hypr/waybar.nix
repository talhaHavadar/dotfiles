{ config, lib, ... }:
let
  home_config = config.host.home.windowManagers.hyprland;
  mkOutOfStoreSymlink = config.lib.file.mkOutOfStoreSymlink;
in
with lib;
{
  config = mkIf (home_config.enable) {
    home.file = {
      ".config/waybar/mocha.css".source = mkOutOfStoreSymlink ../../dot/waybar/mocha.css;
      ".config/waybar/latte.css".source = mkOutOfStoreSymlink ../../dot/waybar/latte.css;
    };

    programs.waybar = {

      enable = true;
      settings = {
        mainBar = {
          "layer" = "top"; # Waybar at top layer
          "position" = "bottom"; # Waybar position (top|bottom|left|right)
          # "width": 1280, # Waybar width
          # Choose the order of the modules
          "modules-left" = [
            "hyprland/workspaces"
            "hyprland/language"
          ];
          "modules-center" = [
            "custom/music"
            "hyprland/window"
          ];
          "modules-right" = [
            "wireplumber"
            "cpu"
            "battery"
            "clock"
            "tray"
            "custom/lock"
            "custom/power"
          ];

          cpu = {
            format = "{usage}% 󰍛";
            interval = 1;
            min-length = 5;
            format-alt-click = "click";
            format-alt = "{icon0}{icon1}{icon2}{icon3} {usage:>2}% 󰍛";
            format-icons = [
              "▁"
              "▂"
              "▃"
              "▄"
              "▅"
              "▆"
              "▇"
              "█"
            ];
          };

          "hyprland/workspaces" = {
            "disable-scroll" = true;
            "sort-by-name" = true;
            "format" = " {icon} ";
            "format-icons" = {
              "default" = "";
            };
          };
          "hyprland/language" = {
            "format" = "{}";
            "format-en" = "en-us";
            "format-tr" = "tr";
            "on-click" = "hyprctl switchxkblayout $SET_KB next";
          };
          "hyprland/window" = {
            icon = true;
            separate-outputs = true;
            rewrite = {
              "(.*) - Google Chrome" = "$1";
            };
          };
          "tray" = {
            "icon-size" = 21;
            "spacing" = 10;
          };
          "custom/music" = {
            "format" = "  {}";
            "escape" = true;
            "interval" = 5;
            "tooltip" = false;
            "exec" = "playerctl metadata --format='{{ title }}'";
            "on-click" = "playerctl play-pause";
            "max-length" = 50;
          };
          "clock" = {
            "timezone" = "Europe/Amsterdam";
            "tooltip-format" = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
            "format-alt" = "{:%A, %d %B, %Y (%R)}";
            "format" = "{:%H:%M}";
          };
          "battery" = {
            "states" = {
              "warning" = 30;
              "critical" = 15;
            };
            "format" = "<span font='Font Awesome 6 Free 11'>{icon}</span>";
            "format-charging" = "<span font='Font Awesome 6 Free'></span><span font='Font Awesome 6 Free 11'>{icon}</span>";
            "format-full" = "<span font='Font Awesome 6 Free'></span>  <span font='Font Awesome 6 Free 11'>{icon}</span>";
            "format-alt" = "{icon} {capacity}%";
            "format-icons" = [
              ""
              ""
              ""
              ""
              ""
            ];
          };
          "wireplumber" = {
            # "scroll-step": 1, // %, can be a float
            "format" = "{icon} {volume}%";
            "format-muted" = "";
            "format-icons" = {
              "default" = [
                ""
                ""
                " "
              ];
            };
            "on-click" = "helvum";
          };
          "custom/lock" = {
            "tooltip" = false;
            "on-click" = "sh -c '(sleep 0.5s; hyprlock -q)' & disown";
            "format" = "";
          };
          "custom/power" = {
            "tooltip" = false;
            "on-click" = "wlogout &";
            "format" = "襤";
          };
        };
      };
      style = ''
        @import "mocha.css";

        * {
            font-family: "JetBrainsMono Nerd Font";
            font-weight: bold;
            min-height: 0;
            /* set font-size to 100% if font scaling is set to 1.00 using nwg-look */
            font-size: 16px;
            font-feature-settings: '"zero", "ss01", "ss02", "ss03", "ss04", "ss05", "cv31"';
        }

        #waybar {
          background: transparent;
          color: @text;
          margin: 5px 5px;
        }

        #workspaces {
          border-radius: 1rem;
          margin: 5px;
          background-color: @surface0;
          margin-left: 1rem;
        }

        #workspaces button {
          color: @lavender;
          border-radius: 1rem;
          padding: 0.4rem;
        }

        #workspaces button.active {
          color: @sky;
          border-radius: 1rem;
        }

        #workspaces button:hover {
          color: @sapphire;
          border-radius: 1rem;
        }

        #custom-music,
        #tray,
        #clock,
        #battery,
        #cpu,
        #wireplumber,
        #custom-lock,
        #custom-power {
          background-color: @surface0;
          padding: 0.5rem 1rem;
          margin: 5px 0;
        }

        #clock {
          color: @blue;
          border-radius: 0px 1rem 1rem 0px;
          margin-right: 1rem;
        }

        #cpu {
          color: @blue;
        }

        #battery {
          color: @green;
        }

        #battery.charging {
          color: @green;
        }

        #battery.warning:not(.charging) {
          color: @red;
        }


        #cpu, #battery {
            border-radius: 0;
        }

        #wireplumber {
          color: @maroon;
          border-radius: 1rem 0px 0px 1rem;
          margin-left: 1rem;
        }

        #custom-music {
          color: @mauve;
          border-radius: 1rem;
        }

        #custom-lock {
            border-radius: 1rem 0px 0px 1rem;
            color: @lavender;
        }

        #custom-power {
            margin-right: 1rem;
            border-radius: 0px 1rem 1rem 0px;
            color: @red;
        }

        #tray {
          margin-right: 1rem;
          border-radius: 1rem;
        }
      '';
    };
  };
}
