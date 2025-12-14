{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  neovim_config = config.host.features.apps.neovim;
in
with lib;
{
  config = mkIf neovim_config.enable {
    homebrew = {
      enable = true;
      taps = [ ];

      brews = [
        "xcp"
        "xcode-build-server"
        "coreutils"
        "swiftlint"
        "swiftformat"
      ];

      casks = [
      ];

      masApps = {
      };
    };
  };

}
