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
  host.home.applications.ghostty.enable = true;
  host.home.windowManagers.hyprland.enable = true;
  host.home.applications.neovim.claude-code.enable = true;

  imports = [
    ../hyprland.nix
  ];

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
