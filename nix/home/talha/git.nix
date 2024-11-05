{
  config,
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
    userName = "Talha Can Havadar";
    userEmail = "havadartalha@gmail.com";
    extraConfig = {
      commit.gpgSign = "true";
      includeIf."gitdir:~/workspace/".path = "~/workspace/.gitconfig";
    };
  };
}
