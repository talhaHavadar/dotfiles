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
      Host macmini.lan
        HostName 10.17.0.21
        User talha
        StreamLocalBindUnlink yes
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

      Host badgerd-nl.jump
        User ubuntu
        HostName badgerd-nl.local
        ProxyJump dev-amd64.lan
        StreamLocalBindUnlink yes
        RemoteForward /run/user/1000/gnupg/S.gpg-agent /run/user/1000/gnupg/S.gpg-agent 

      IdentityFile ~/.ssh/id_ed25519_sk_mobil
    '';
  };

  home.packages = with pkgs; [
    yubioath-flutter
  ];

}
