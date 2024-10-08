{ pkgs, ... }:
let
in {
  programs.tmux = {
    enable = true;
    historyLimit = 100000;
    keyMode = "vi";
    plugins = with pkgs;
      [
        {
          plugin = tmuxPlugins.catppuccin;
          extraConfig = ''
set -g @catppuccin_flavor 'latte'
          '';
        }
      ];
    extraConfig = ''
set -g prefix C-g
    '';
  };
}
