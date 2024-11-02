{
  config,
  inputs,
  lib,
  device,
  pkgs,
  ...
}:
let
  home_config = config.host.home.applications.kitty;
  home = config.home;
  kitty = "${pkgs.kitty}/bin/kitty";
in
with lib;
{

  options = {
    host.home.applications.kitty = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Terminal Emulator";
      };
    };
  };

  config = mkIf (home_config.enable && device.system != "aarch64-darwin") {
    programs.kitty = {
      enable = true;
      themeFile = "Catppuccin-Latte";
      font = {
        package = (pkgs.nerdfonts.override { fonts = [ "Meslo" ]; });
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
        cursor = "#394260";
      };
      keybindings = {
        "ctrl+shift+enter" = "new_window_with_cwd";
        "ctrl+shift+g" = "next_window";
      };

    };

    # FIXME: Remove once GLX issues are solved on standalone installations
    # https://github.com/NixOS/nixpkgs/issues/80936
    # home.activation = {
    #   kitty = lib.hm.dag.entryBefore [ "installPackages" ] ''
    #     PATH="${pkgs.curl}/bin:$HOME/.local/bin:$PATH" $DRY_RUN_CMD curl -L \
    #     https://sw.kovidgoyal.net/kitty/installer.sh | \
    #     PATH="${pkgs.xz}/bin:${pkgs.gnutar}/bin:${pkgs.curl}/bin:$HOME/.local/bin:$PATH" $DRY_RUN_CMD sh /dev/stdin launch=n
    #   '';
    # };
    home.shellAliases.kitty = kitty;
    xdg.dataFile."applications/kitty.desktop" = {
      text = ''
        [Desktop Entry]
        Version=1.0
        Type=Application
        Name=kitty
        GenericName=Terminal emulator
        Comment=Fast, feature-rich, GPU based terminal
        TryExec=${pkgs.kitty}/bin/kitty
        Exec=${kitty}
        Icon=${pkgs.kitty}/share/icons/hicolor/scalable/apps/kitty.svg
        Categories=System;TerminalEmulator;
      '';
    };
    #endof FIXME
  };

}
