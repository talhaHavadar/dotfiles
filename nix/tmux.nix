{ pkgs, ... }:
let
  tmuxPlugins = pkgs.tmuxPlugins;
in
{
  programs.tmux = {
    enable = true;
    historyLimit = 100000;
    keyMode = "vi";
    shell = "/opt/homebrew/bin/bash";
    plugins = with tmuxPlugins; [
      {
        plugin = catppuccin;
        extraConfig = ''
          set -g @catppuccin_flavor 'latte'
          set -g @catppuccin_window_status_style "rounded"
          set -g @catppuccin_status_modules_right "load cpu user"
        '';
      }
      cpu
      sensible

    ];
    extraConfig = ''
      unbind C-b
      set -g prefix C-g
      set -g mouse on

      set-option -g detach-on-destroy off
      set-option -g default-command "/opt/homebrew/bin/bash"

      unbind C-g
      bind C-g select-pane -t :.+

      bind h split-window -v
      bind v split-window -h

      setw -g mode-keys vi

      unbind j
      bind j run-shell -b "~/.config/dotfiles/tmux.sh"
    '';
  };
}
