{
  config,
  inputs,
  lib,
  pkgs,
  currentConfigSystem,
  ...
}:
let
  homeDirectory = config.home.homeDirectory;
in
with lib;
{

  config =
    { }
    // lib.optionalAttrs (currentConfigSystem == "home") {
      programs.git = {
        enable = true;
        userName = "Bahanur Enis";
        userEmail = "bahanurenis@gmail.com";
        extraConfig = {
          # tag.gpgSign = "true"
          commit.gpgSign = "true";
          log.showSignature = "true";
          user.signingkey = "961F36F44EF82483";
        };
      };
    }
    // lib.optionalAttrs (currentConfigSystem == "darwin") {
    }
    // lib.optionalAttrs (currentConfigSystem == "nixos") {
    };
}
