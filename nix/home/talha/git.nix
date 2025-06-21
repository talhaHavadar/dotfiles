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
        ".local/bin/git-wapply".source = mkOutOfStoreSymlink ../../../dot/bin/git-wapply;
      };
      programs.git = {
        enable = true;
        userName = "Talha Can Havadar";
        userEmail = "havadartalha@gmail.com";
        extraConfig = {
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
