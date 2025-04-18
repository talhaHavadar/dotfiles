{
  config,
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
        userName = "Talha Can Havadar";
        userEmail = "havadartalha@gmail.com";
        extraConfig = {
          rebase.autoSquash = true;
          commit.gpgSign = "true";
          tag.gpgSign = true;
          log.showSignature = true;
          includeIf."gitdir:~/workspace/".path = "~/workspace/.gitconfig";
        };
      };
    }
    // lib.optionalAttrs (currentConfigSystem == "darwin") {
    }
    // lib.optionalAttrs (currentConfigSystem == "nixos") {
    };
}
