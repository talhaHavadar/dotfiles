{
  config,
  lib,
  pkgs,
  username,
  platform,
  ...
}:
let
  pyp = pkgs.python312Packages;
  isPackagingEnabled = (builtins.getEnv "INCLUDE_PACKAGING") == "true";
  mkOutOfStoreSymlink = config.lib.file.mkOutOfStoreSymlink;
in
with lib;
{

  host.home.applications.neovim.enable = true;
  host.home.applications.kitty.enable = false;

  imports =
    [
    ];

  home.packages =
    with pkgs;
    [
    ];

}
