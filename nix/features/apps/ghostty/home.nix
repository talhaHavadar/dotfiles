{ inputs
, config
, lib
, pkgs
, ...
}:
let
  ghostty_config = config.host.features.apps.ghostty;
  isDarwin = pkgs.stdenv.isDarwin;
  mkOutOfStoreSymlink = config.lib.file.mkOutOfStoreSymlink;
in
{
  config = lib.mkIf (ghostty_config.enable && !isDarwin) {
    home.file = {
      ".config/ghostty".source = mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/dotfiles/dot/ghostty";
    };
    programs.ghostty = {
      enable = false;
      # enableBashIntegration = true;
      settings = { };
    };
    home.activation = {
      ghostty = lib.hm.dag.entryAfter [ "installPackages" ] ''
        $DRY_RUN_CMD /usr/bin/snap install ghostty --classic
      '';
    };

    # home.shellAliases.ghostty = "${pkgs.ghostty}/bin/ghostty";
    # xdg.dataFile."applications/ghostty.desktop" = {
    #   # TODO: not needed/effective in macos
    #   text = ''
    #     [Desktop Entry]
    #     Version=1.0
    #     Type=Application
    #     Name=ghostty
    #     GenericName=Terminal emulator
    #     Comment=Fast, feature-rich, GPU based terminal
    #     TryExec=${pkgs.ghostty}/bin/ghostty
    #     Exec=${pkgs.ghostty}/bin/ghostty
    #     Icon=${pkgs.ghostty}/share/icons/hicolor/256x256/apps/com.mitchellh.ghostty.png
    #     Categories=System;TerminalEmulator;
    #   '';
    # };
  };
}
