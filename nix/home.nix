{ config, pkgs, ... }:
let
  username = "ubuntu";
  homeDirectory = "/home/${username}";
  dotfilesPath = "/home/${username}/.config/dotfiles";
in {
  imports = [
    ./tmux.nix
  ];

  home = {
    inherit username homeDirectory;
    stateVersion = "24.05"
  };

  home.packages = [
    pkgs.tmux
  ];

}
