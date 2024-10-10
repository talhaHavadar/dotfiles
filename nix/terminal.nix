{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  homeDirectory = config.home.homeDirectory;
in
with lib;
{
  programs = {
    home-manager.enable = true;
    bash.enable = true;
    starship.enable = true;
    zoxide = {
      enable = true;
      options = [
        "--cmd cd"
      ];
    };
  };

  home.packages = [
    pkgs.cowsay
  ];

  home.sessionPath = [
    "${homeDirectory}/.local/bin"
  ];
  home.sessionVariables = {
    GPG_TTY = "$(tty)";
  };
}
