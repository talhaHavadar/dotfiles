{
  config,
  lib,
  pkgs,
  packagingEnabled,
  ...
}:
let
  homeDirectory = config.home.homeDirectory;
in
with lib;
{

  programs.git = mkIf packagingEnabled {
    enable = true;
    userName = "Talha Can Havadar";
    userEmail = "talha.can.havadar@canonical.com";
    extraConfig = {
      commit.gpgSign = "true";
      tag.gpgSign = true;
      log.showSignature = true;
      includeIf."gitdir:~/workspace/".path = "~/workspace/.gitconfig";
    };
  };
}
