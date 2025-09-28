{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
let
  kitty_config = config.host.features.apps.kitty;
  isDarwin = pkgs.stdenv.isDarwin;
  isNixOS = pkgs.stdenv.isLinux && builtins.pathExists /etc/NIXOS;
  isLinuxNonNixOS = pkgs.stdenv.isLinux && !builtins.pathExists /etc/NIXOS;
  isLinux = pkgs.stdenv.isLinux;
in
{
  config = lib.mkIf (kitty_config.enable) {
    programs.kitty = {
      enable = true;
      themeFile = "Chalk";
      font = {
        package = (pkgs.nerd-fonts.meslo-lg);
        name = "MesloLG Nerd Font";
        size = 12;
      };
      shellIntegration.enableBashIntegration = true;
      settings = {
        scrollback_pager_history_size = 100000;
        background_opacity = 0.88;
        tab_bar_edge = "top";
        tab_bar_style = "powerline";
        tab_powerline_style = "slanted";
        tab_bar_align = "left";
        enable_audio_bell = "no";
        enabled_layouts = "fat:bias=80;full_size=1;mirrored=false";
        update_check_interval = 0;
        cursor = "#ebedf2";
        kitty_mod = "super+shift";
      }
      // lib.optionalAttrs (isDarwin) {
        shell = "/opt/homebrew/bin/bash --login";
      };
      keybindings = {
        "kitty_mod+enter" = "new_window_with_cwd";
        "kitty_mod+g" = "next_window";
        "kitty_mod+w" = "close_window";
      };

    };
    home.shellAliases.kitty = "${pkgs.kitty}/bin/kitty";
    xdg.dataFile."applications/kitty.desktop" = {
      # TODO: not needed/effective in macos
      text = ''
        [Desktop Entry]
        Version=1.0
        Type=Application
        Name=kitty
        GenericName=Terminal emulator
        Comment=Fast, feature-rich, GPU based terminal
        TryExec=${pkgs.kitty}/bin/kitty
        Exec=${pkgs.kitty}/bin/kitty
        Icon=${pkgs.kitty}/share/icons/hicolor/scalable/apps/kitty.svg
        Categories=System;TerminalEmulator;
      '';
    };
    #endof FIXME
  };
}
