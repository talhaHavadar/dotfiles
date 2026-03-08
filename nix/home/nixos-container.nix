{ config
, lib
, pkgs
, username
, platform
, ...
}:
let
  pyp = pkgs.python312Packages;
  mkOutOfStoreSymlink = config.lib.file.mkOutOfStoreSymlink;
in
with lib;
{
  host.features.apps.neovim.enable = true;
  host.features.apps.neovim.claude-code.enable = true;
  host.features.apps.ghostty.enable = false;
  host.features.apps.kitty.enable = false;

  imports = [
  ];

  home.packages = with pkgs; [
  ];
}
