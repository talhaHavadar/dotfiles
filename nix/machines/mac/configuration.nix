# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  pkgs,
  ...
}:

{
  environment.systemPackages = [
    pkgs.vim
    pkgs.gnupg
  ];

  environment.variables = {
    EDITOR = "vim";
  };

  # nix.package = pkgs.nix;

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  # Enable alternative shell support in nix-darwin.
  # programs.fish.enable = true;
  programs.bash.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 5;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;

  networking.computerName = "Talha's MacMini";
  networking.hostName = "talha-macmini";
  networking.localHostName = "talha-macmini";
  system.primaryUser = "talha";
  power.sleep.display = 60;
  programs.gnupg.agent.enable = true;
  programs.gnupg.agent.enableSSHSupport = true;
}
