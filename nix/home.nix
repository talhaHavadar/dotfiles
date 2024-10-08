{ config, lib, pkgs, ... }:
{
  home.stateVersion = "24.05";
  imports = [
    ./tmux.nix
  ];

  home.packages = [
    pkgs.tmux
    pkgs.neovim
    pkgs.fzf
    pkgs.neovim
    pkgs.ripgrep
    pkgs.tmux
    pkgs.git
    pkgs.cmake
    pkgs.build-essential
    pkgs.tio
    pkgs.mtools
    pkgs.gcc-arm-none-eabi
    pkgs.dosfstools
    pkgs.python3-venv
    pkgs.python3-dev
    pkgs.pipx
  ];

  programs.home-manager.enable = true;
  programs.bash.enable = true;

  programs.git = {
    enable = true;
  };
}
