{
  config,
  lib,
  pkgs,
  username,
  platform,
  ...
}:
let
  pyp = pkgs.python312Packages;
  mkOutOfStoreSymlink = config.lib.file.mkOutOfStoreSymlink;
in
with lib;
{

  host.home.applications.neovim.enable = true;
  host.home.applications.kitty.enable = true;
  host.home.windowManagers.hyprland.enable = true;

  imports = [
    ../hyprland.nix
  ];

  programs.ssh = {
    enable = true;
    extraConfig = ''
      IdentityFile ~/.ssh/id_ed25519_sk_mobil

      Host macmini.lan
        HostName 10.17.0.21
        User talha
        StreamLocalBindUnlink yes
        PermitLocalCommand yes
        LocalCommand unset SSH_AUTH_SOCK
        RemoteForward /Users/talha/.gnupg/S.gpg-agent /run/user/1000/gnupg/S.gpg-agent
        RemoteForward /Users/talha/.gnupg/S.gpg-agent.ssh /run/user/1000/gnupg/S.gpg-agent.ssh


      Host pi-dev.local
        User talha
        StreamLocalBindUnlink yes
        RemoteForward /run/user/1000/gnupg/S.gpg-agent /run/user/1000/gnupg/S.gpg-agent 

      Host dev-amd64.lan
        User ubuntu
        StreamLocalBindUnlink yes
        RemoteForward /run/user/1000/gnupg/S.gpg-agent /run/user/1000/gnupg/S.gpg-agent 
        RemoteForward /run/user/1000/gnupg/S.gpg-agent.ssh /run/user/1000/gnupg/S.gpg-agent.ssh

      Host badgerd-nl.jump
        User ubuntu
        HostName badgerd-nl.local
        ProxyJump dev-amd64.lan
        StreamLocalBindUnlink yes
        RemoteForward /run/user/1000/gnupg/S.gpg-agent /run/user/1000/gnupg/S.gpg-agent 

      Host launchpad.net
        IdentityFile ~/.ssh/id_ed25519
    '';
  };

  home.packages = with pkgs; [
    yubioath-flutter
  ];

  programs = {
    # bash = {
    #   shellAliases = {
    #     google-chrome = "google-chrome --force-device-scale-factor=1.6";
    #     google-chrome-stable = "google-chrome-stable --force-device-scale-factor=1.6";
    #   };
    # };
  };
}
