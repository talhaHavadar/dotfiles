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
  home.packages = with pkgs; [
    ubuntu-classic
    nerd-fonts.hack
    nerd-fonts.noto
    nerd-fonts.jetbrains-mono
    nerd-fonts.droid-sans-mono
  ];
}
