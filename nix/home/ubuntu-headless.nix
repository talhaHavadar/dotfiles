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

  host.features.apps.neovim.enable = true;
  host.features.apps.neovim.claude-code.enable = true;
  host.features.apps.ghostty.enable = false;
  host.features.apps.kitty.enable = false;

  imports = [
  ];

  home.packages = with pkgs; [
    ubuntu-classic
    nerd-fonts.hack
    nerd-fonts.noto
    nerd-fonts.jetbrains-mono
    nerd-fonts.droid-sans-mono
  ];

}
