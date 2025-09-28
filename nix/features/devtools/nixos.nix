{
  config,
  lib,
  pkgs,
  ...
}:
let
  devtools_config = config.host.features.devtools;
in
{
  config = lib.mkIf devtools_config.enable {
  };
}
