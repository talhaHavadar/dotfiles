{ inputs
, config
, lib
, pkgs
, ...
}:
let
  ghostty_config = config.host.features.apps.ghostty;
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  mkOutOfStoreSymlink = config.lib.file.mkOutOfStoreSymlink;
in
{
  config = lib.mkIf (ghostty_config.enable && !isDarwin) {
    home.file = {
      ".config/ghostty".source = mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/dotfiles/dot/ghostty";
    };
    programs.ghostty = {
      enable = true;
      enableBashIntegration = true;
      settings = { };
    };
  };
}
