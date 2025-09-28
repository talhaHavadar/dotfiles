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
  host.home.windowManagers.hyprland.enable = true;

  imports = [
    ../hyprland.nix
  ];

  home.packages = with pkgs; [
    yubioath-flutter
    wl-clipboard
    ubuntu-classic
    nerd-fonts.hack
    nerd-fonts.noto
    nerd-fonts.jetbrains-mono
    nerd-fonts.droid-sans-mono
  ];

}
