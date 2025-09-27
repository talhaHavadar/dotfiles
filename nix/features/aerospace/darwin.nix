{
  config,
  lib,
  pkgs,
  ...
}:
let
  aerospace_config = config.host.features.aerospace;
in
{
  options = {
    host.features.aerospace = {
      enable = lib.mkOption {
        default = false;
        type = with lib.types; bool;
        description = "Aerospace - Window Manager for MacOS";
      };
    };
  };

  config = lib.mkIf aerospace_config.enable {
    services.aerospace = {
      enable = false;
      settings = {
        on-focus-changed = [ "move-mouse window-lazy-center" ];

        on-window-detected = [
          {
            "if".app-id = "Mattermost.Desktop";
            "check-further-callbacks" = false;
            "run" = [ "move-node-to-workspace m" ];
          }
          {
            "if".app-id = "com.apple.mail";
            "check-further-callbacks" = false;
            "run" = "move-node-to-workspace m";
          }
        ];
        exec-on-workspace-change = [
          "/opt/homebrew/bin/bash"
          "-c"
          "sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE"
        ];
        automatically-unhide-macos-hidden-apps = false;

        gaps = {
          inner.horizontal = 24;
          inner.vertical = 24;
          outer.left = 16;
          outer.bottom = 12;
          outer.top = 12;
          outer.right = 16;
        };
        mode.main.binding = {
          # See: https://nikitabobko.github.io/AeroSpace/commands#exec-and-forget
          # You can uncomment the following lines to open up terminal with alt + enter shortcut (like in i3)
          # ctrl-enter = ''
          #   exec-and-forget osascript -e '
          #            tell application "kitty"
          #                do script
          #                activate
          #            end tell'
          # '';
          # See: https://nikitabobko.github.io/AeroSpace/commands#layout
          ctrl-alt-equal = "layout tiles horizontal vertical";
          ctrl-alt-f = "layout floating";
          # ctrl-alt-comma = "layout accordion horizontal vertical";
          cmd-shift-f = "fullscreen";

          cmd-left = "focus left";
          cmd-down = "focus down";
          cmd-up = "focus up";
          cmd-right = "focus right";
          ctrl-alt-shift-right = "join-with right";
          ctrl-alt-shift-left = "join-with left";
          ctrl-alt-shift-down = "join-with down";
          ctrl-alt-shift-up = "join-with up";

          ctrl-shift-left = "move left";
          ctrl-shift-down = "move down";
          ctrl-shift-up = "move up";
          ctrl-shift-right = "move right";
          ctrl-alt-shift-k = "resize smart +50";
          ctrl-alt-shift-j = "resize smart -50";

          # See: https://nikitabobko.github.io/AeroSpace/commands#workspace
          cmd-1 = "workspace 1";
          cmd-2 = "workspace 2";
          cmd-3 = "workspace 3";
          cmd-4 = "workspace 4";
          cmd-5 = "workspace 5";
          cmd-6 = "workspace 6";
          cmd-7 = "workspace 7";
          cmd-8 = "workspace 8";
          cmd-9 = "workspace 9";
          cmd-j = "workspace j";
          cmd-m = "workspace m";
          cmd-shift-1 = "move-node-to-workspace 1";
          cmd-shift-2 = "move-node-to-workspace 2";
          cmd-shift-3 = "move-node-to-workspace 3";
          cmd-shift-4 = "move-node-to-workspace 4";
          cmd-shift-5 = "move-node-to-workspace 5";
          cmd-shift-6 = "move-node-to-workspace 6";
          cmd-shift-7 = "move-node-to-workspace 7";
          cmd-shift-8 = "move-node-to-workspace 8";
          cmd-shift-9 = "move-node-to-workspace 9";
          cmd-shift-j = "move-node-to-workspace j";
          cmd-shift-m = "move-node-to-workspace m";
          alt-tab = "workspace-back-and-forth";
          cmd-alt-left = "workspace prev";
          cmd-alt-right = "workspace next";
        };
      };
    };
  };
}
