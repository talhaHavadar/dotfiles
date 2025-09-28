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
    programs.zed-editor.enable = true;
  };
}
