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
    // lib.optionalAttrs (currentConfigSystem == "home") {
      home.file = {
      };
      programs.git = {
        enable = true;
        userName = "Talha Can Havadar";
        userEmail = "havadartalha@gmail.com";
        extraConfig = {
          core.excludesfile = "~/.gitignore_global";
          sparse.user.id = "talhaHavadar";
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
