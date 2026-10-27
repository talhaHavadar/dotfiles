{ config
, lib
, pkgs
, username
, platform
, ...
}:
let
  pyp = pkgs.python312Packages;
  mkOutOfStoreSymlink = config.lib.file.mkOutOfStoreSymlink;
in
with lib;
{
  targets.genericLinux =
    {
      enable = true;
      gpu.enable = true;
    };
  host.home.windowManagers.hyprland.enable = false;

  imports = [
    ../hyprland.nix
  ];

  home.packages = with pkgs; [
    less
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
