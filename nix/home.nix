{ config, lib, pkgs, specialArgs, ... }:
let
  pyp = pkgs.python312Packages;
in
{

  imports = [
    ./tmux.nix
    ./configs.nix
  ];

  home.packages = [
    pkgs.tmux
    pkgs.fzf
    pkgs.ripgrep
    pkgs.git
    pkgs.cmake
    pkgs.gcc13Stdenv
    pkgs.tio
    pkgs.mtools
    pkgs.gcc-arm-embedded-13
    pkgs.dosfstools
    pyp.pipx
  ];

  programs.home-manager.enable = true;
  programs.bash.enable = true;

  programs.git = {
    enable = true;
  };
}
