{
  config,
  inputs,
  lib,
  pkgs,
  platform,
  ...
}:
let
  home_config = config.host.home.applications.ghostty;
  home = config.home;
in
with lib;
{

  options = {
    host.home.applications.ghostty = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Terminal Emulator";
      };
    };
  };

  config = mkIf (home_config.enable) {
    programs.ghostty = {
      enable = true;
      # enableBashIntegration = true;
      settings = {
        theme = "catppuccin-mocha";
        #font-size = 10;
        keybind = [
          "super+right=next_tab"
          "super+left=previous_tab"
          "super+shift+w=close_tab"
          "super+shift+t=new_tab"
          "super+shift+enter=new_split:down"
          "super+shift+plus=increase_font_size:1"
          "super+shift+minus=decrease_font_size:1"
        ];
      };
      # themes = {
      #   catppuccin-mocha = {
      #     background = "1e1e2e";
      #     cursor-color = "f5e0dc";
      #     foreground = "cdd6f4";
      #     palette = [
      #       "0=#45475a"
      #       "1=#f38ba8"
      #       "2=#a6e3a1"
      #       "3=#f9e2af"
      #       "4=#89b4fa"
      #       "5=#f5c2e7"
      #       "6=#94e2d5"
      #       "7=#bac2de"
      #       "8=#585b70"
      #       "9=#f38ba8"
      #       "10=#a6e3a1"
      #       "11=#f9e2af"
      #       "12=#89b4fa"
      #       "13=#f5c2e7"
      #       "14=#94e2d5"
      #       "15=#a6adc8"
      #     ];
      #     selection-background = "353749";
      #     selection-foreground = "cdd6f4";
      #   };
      # };
    };
  };

}
