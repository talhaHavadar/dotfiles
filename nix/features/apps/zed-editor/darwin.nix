{
  inputs,
  config,
  lib,
  ...
}:
let
  zed-editor_config = config.host.features.apps.zed-editor;
in
with lib;
{
  config = mkIf (zed-editor_config.enable) {
    homebrew = {
      enable = true;
      taps = [ ];

      brews = [
      ];

      casks = [
        "zed"
      ];

      masApps = {
      };
    };
  };
}
