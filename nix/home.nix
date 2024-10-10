{
  config,
  lib,
  pkgs,
  specialArgs,
  ...
}:
let
  pyp = pkgs.python312Packages;
in
{

  imports = [
    ./tmux.nix
  ];

  home.packages = [
    pkgs.rustc
    pkgs.cargo
    pkgs.cargo-deb
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
  host.home.applications.neovim.enable = true;
  programs.home-manager.enable = true;
  programs.bash.enable = true;

  programs.git = {
    enable = true;
  };
}
