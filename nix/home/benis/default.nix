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
  home = {
    username = "benis";
    homeDirectory = "/home/benis";
    stateVersion = "24.05";
  };
  imports = [
    ./git.nix
  ];

  programs.gpg = {
    enable = true;
    scdaemonSettings = {
      pcsc-shared = true;
      #disable-ccid = true;
    };
  };
  home.packages = with pkgs; [
    teams-for-linux # TODO: linux only use "teams" for darwin
    yubikey-manager
    yubikey-personalization
  ];
}
