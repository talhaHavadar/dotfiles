{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
let
  ghostty_config = config.host.features.apps.ghostty;
  isDarwin = pkgs.stdenv.isDarwin;
in
{
  config = lib.mkIf (ghostty_config.enable && !isDarwin) {
  };
}
