{
  config,
  lib,
  pkgs,
  ...
}:
let
  ghostty_config = config.host.features.apps.ghostty;
in
{
  config = lib.mkIf ghostty_config.enable {
    homebrew = {
      enable = true;
      taps = [ ];

      brews = [
      ];

      casks = [
        "ghostty"
      ];

      masApps = {
      };
    };
  };
}
