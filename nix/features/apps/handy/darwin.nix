{
  config,
  lib,
  ...
}:
let
  handy_config = config.host.features.apps.handy;
in
with lib;
{
  config = mkIf (handy_config.enable) {
    homebrew = {
      enable = true;
      taps = [ ];

      brews = [
      ];

      casks = [
        "handy"
      ];

      masApps = {
      };
    };
  };
}
