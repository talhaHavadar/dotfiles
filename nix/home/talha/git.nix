{
  config,
  lib,
  pkgs,
  currentConfigSystem,
  ...
}:
let
  homeDirectory = config.home.homeDirectory;
  mkOutOfStoreSymlink = config.lib.file.mkOutOfStoreSymlink;
in
with lib;
{

  config =
    { }
    };
}
