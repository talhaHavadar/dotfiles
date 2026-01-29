{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
let
  ghostty_config = config.host.features.apps.ghostty;
  isDarwin = pkgs.stdenv.isDarwin;
in
{
  config = lib.mkIf (ghostty_config.enable && !isDarwin) {
    programs.ghostty = {
      enable = true;
      # enableBashIntegration = true;
      settings = {
        theme = "Catppuccin Frappe";
        #font-size = 10;
        "gtk-titlebar" = false;
        "cursor-style" = "block";
        "window-colorspace" = "display-p3";
        "background-opacity" = 0.9;
        "background-blur" = 5;
        "unfocused-split-opacity" = 0.9;
        "macos-option-as-alt" = "left";
        "command" = "/usr/bin/env bash --login";
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
          "super+alt+left=previous_tab"
          "super+alt+right=next_tab"
          "super+ctrl+v=new_split:right"
          "super+ctrl+h=new_split:down"
          "super+shift+j=goto_split:down"
          "super+shift+k=goto_split:up"
          "super+shift+h=goto_split:left"
          "super+shift+l=goto_split:right"
        ];
      };
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
