{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
with lib;
{
  programs.home-manager.enable = true;
  programs.bash.enable = true;
  programs.starship.enable = true;
  programs.zoxide = {
    enable = true;
    options = [
      "--cmd cd"
    ];
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
