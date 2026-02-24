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

  host.home.windowManagers.hyprland.enable = false;
  # TODO: Swift build is failing on ubuntu
  host.features.apps.neovim.swift.enable = lib.mkForce false;

  imports = [
    ../hyprland.nix
  ];

  home.packages = with pkgs; [
    yubioath-flutter
    ubuntu-classic
    nerd-fonts.hack
    nerd-fonts.noto
    nerd-fonts.jetbrains-mono
    nerd-fonts.droid-sans-mono
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
