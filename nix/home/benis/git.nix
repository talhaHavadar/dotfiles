{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  homeDirectory = config.home.homeDirectory;
  isBenis = config.home.username == "benis";
in
with lib;
{

  config = mkIf (isBenis) {
    programs.git = {
      enable = true;
      userName = "Bahanur Enis";
      userEmail = "bahanurenis@gmail.com";
      extraConfig = {
        #commit.gpgSign = "true";
      };
    };
  };
}
