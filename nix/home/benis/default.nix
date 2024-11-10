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
      disable-ccid = true;
    };
  };
  home.packages = with pkgs; [
    teams-for-linux
    pcsclite
    #yubikey-manager
    #yubikey-personalization
  ];
}
