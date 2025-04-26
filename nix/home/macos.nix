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
  isPackagingEnabled = (builtins.getEnv "INCLUDE_PACKAGING") == "true";
  mkOutOfStoreSymlink = config.lib.file.mkOutOfStoreSymlink;
in
with lib;
{

  host.home.applications.neovim.enable = true;
  host.home.applications.neovim.copilot.enable = true;
  host.home.applications.kitty.enable = true;

  programs.ssh = {
    enable = true;
    extraConfig = ''
      Host launchpad.net
        IdentityFile ~/.ssh/id_ed25519

      Host macmini.lan
        HostName 10.17.0.21
        User talha
        StreamLocalBindUnlink yes
        RemoteForward /Users/talha/.gnupg/S.gpg-agent /Users/talha/.gnupg/S.gpg-agent

      Host pi-dev.local
        User talha
        StreamLocalBindUnlink yes
        RemoteForward /run/user/1000/gnupg/S.gpg-agent /Users/talha/.gnupg/S.gpg-agent

      Host dev-amd64-unlock
        User root
        Port 2222
        HostName dev-amd64.lan

      Host dev-amd64.lan
        User ubuntu
        StreamLocalBindUnlink yes
        RemoteForward /run/user/1000/gnupg/S.gpg-agent /Users/talha/.gnupg/S.gpg-agent
        RemoteForward /run/user/1000/gnupg/S.gpg-agent.ssh /Users/talha/.gnupg/S.gpg-agent.ssh

      Host badgerd-nl.jump
        User ubuntu
        HostName badgerd-nl.local
        ProxyJump dev-amd64.lan
        StreamLocalBindUnlink yes
        RemoteForward /run/user/1000/gnupg/S.gpg-agent /Users/talha/.gnupg/S.gpg-agent
        RemoteForward /run/user/1000/gnupg/S.gpg-agent.ssh /Users/talha/.gnupg/S.gpg-agent.ssh

      Include ~/.orbstack/ssh/config
      IdentityFile ~/.ssh/id_ed25519_sk_mobil
    '';
  };

  home.packages = with pkgs; [
    gnupg
    yubikey-manager
    #yubioath-flutter
  ];
}
