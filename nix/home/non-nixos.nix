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

  home.packages = with pkgs; [
    nixgl.nixGLMesa
    yubioath-flutter
  ];

}
