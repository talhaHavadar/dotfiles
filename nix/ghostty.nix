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
        theme = "catppuccin-frappe";
        #font-size = 10;
        "gtk-titlebar" = false;
        "cursor-style" = "block";
        "window-colorspace" = "display-p3";
        "background-opacity" = 0.9;
        "background-blur" = 5;
        "unfocused-split-opacity" = 0.9;
        "macos-option-as-alt" = "left";
        keybind = [
          # Keybinds to match macOS since this is a VM
          "super+c=copy_to_clipboard"
          "super+v=paste_from_clipboard"
          "super+shift+c=copy_to_clipboard"
          "super+shift+v=paste_from_clipboard"
          "super+plus=increase_font_size:1"
          "super+minus=decrease_font_size:1"
          "super+zero=reset_font_size"
          "super+q=quit"
          "super+shift+comma=reload_config"
          "super+n=new_window"
          "super+w=close_surface"
          "super+shift+w=close_window"
          "super+t=new_tab"
          "super+shift+left=previous_tab"
          "super+shift+right=next_tab"
          "super+ctrl+v=new_split:right"
          "super+ctrl+h=new_split:down"
          "super+shift+j=goto_split:down"
          "super+shift+k=goto_split:up"
          "super+shift+h=goto_split:left"
          "super+shift+l=goto_split:right"
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

    home.shellAliases.ghostty = "${pkgs.ghostty}/bin/ghostty";
    xdg.dataFile."applications/ghostty.desktop" = {
      # TODO: not needed/effective in macos
      text = ''
        [Desktop Entry]
        Version=1.0
        Type=Application
        Name=ghostty
        GenericName=Terminal emulator
        Comment=Fast, feature-rich, GPU based terminal
        TryExec=${pkgs.ghostty}/bin/ghostty
        Exec=${pkgs.ghostty}/bin/ghostty
        Icon=${pkgs.ghostty}/share/icons/hicolor/256x256/apps/com.mitchellh.ghostty.png
        Categories=System;TerminalEmulator;
      '';
    };
  };

}
