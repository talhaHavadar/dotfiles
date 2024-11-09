{
  config,
  lib,
  pkgs,
  specialArgs,
  ...
}:
let
  pyp = pkgs.python312Packages;
  isPackagingEnabled = (builtins.getEnv "INCLUDE_PACKAGING") == "true";
  mkOutOfStoreSymlink = config.lib.file.mkOutOfStoreSymlink;
in
with lib;
{
  imports = [
    ./git.nix
  ];

  home.packages = with pkgs; [
    teams-for-linux
    pcsclite
    yubikey-manager
  ];
}
