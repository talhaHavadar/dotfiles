{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  homeDirectory = config.home.homeDirectory;
in
with lib;
{

  programs.git = {
    enable = true;
    userName = "Bahanur Enis";
    userEmail = "bahanurenis@gmail.com";
    extraConfig = {
      # tag.gpgSign = "true"
      #commit.gpgSign = "true";
      log.showSignature = "true";

    };
  };
}
