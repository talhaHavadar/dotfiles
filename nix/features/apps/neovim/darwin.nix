{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  neovim_config = config.host.features.apps.neovim;
  swift = neovim_config.swift;
in
with lib;
{
  config = mkIf (neovim_config.enable && swift.enable) {
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
