{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
let
  zed-editor_config = config.host.features.apps.zed-editor;
  isDarwin = pkgs.stdenv.isDarwin;
in
{
  config = lib.mkIf (zed-editor_config.enable) {
    # it is fucking taking ages
    # so better disable zed-editor from nix
    # improve compile times rust!!
    programs.zed-editor.enable = false;
  };
}
