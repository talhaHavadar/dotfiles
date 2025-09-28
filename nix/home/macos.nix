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
  host.home.applications.neovim.claude-code.enable = true;
  #host.home.applications.ghostty.enable = true;
  host.home.applications.kitty.enable = true;

  home.packages = with pkgs; [
    yubikey-manager
    ubuntu-classic
    nerd-fonts.hack
    nerd-fonts.noto
    nerd-fonts.jetbrains-mono
    nerd-fonts.droid-sans-mono
  ];
}
