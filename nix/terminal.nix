{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  homeDirectory = config.home.homeDirectory;
  isPackagingEnabled = (builtins.getEnv "INCLUDE_PACKAGING") == "true";
in
with lib;
{
  programs = {
    home-manager.enable = true;
    starship.enable = true;
    zoxide = {
      enable = true;
      options = [
        "--cmd cd"
      ];
    };

    bash = {
      enable = true;
      bashrcExtra =
        ''
          tmux_find_or_create_prompt() {
              query="$(zoxide query -l)"$'\n'"$(tmux list-sessions)"
              result=$(echo "$query" | fzf-tmux -p -w 62% -h 38% -m)
              if [ "$result" = "" ]; then
                  echo ""
              else
                  zoxide add "$result" &>/dev/null
                  session_name=$(echo $result | sed "s/:.*//g" | sed "s/.*\///g")
                  if [ "$TMUX" ]; then
                      echo "in tmux session"
                      
                      tmux switch-client -t $session_name || (cd $result && tmux new-session -d -s $session_name && cd - && tmux switch-client -t $session_name)
                  else
                      echo "not in tmux session"
                      cd $result
                      tmux new -As $session_name
                  fi
              fi
          }
          lxc-update-ssh-keys() {
            container_name=$1
            cat ~/.ssh/id_ed25519.pub | lxc exec "$1" -- \
            sh -c "cat >> /home/ubuntu/.ssh/authorized_keys"
            lxc exec "$1" -- systemctl restart ssh
          }
        ''
        + optionalString isPackagingEnabled ". ~/.packaging.bashrc";
      shellAliases = {
        ll = "ls -al";
        tn = "tmux new -As $(pwd | sed \"s/.*\\///g\")";
        t = "tmux new -As";
        tl = "tmux list-sessions";
        tk = "tmux kill-session -t";
        tf = "tmux_find_or_create_prompt";
        tp = "tmux list-panes -a -F '#D #T #{pane_tty} #{pane_current_command} #{pane_current_path}'";
      };
    };
  };

  home.sessionPath = [
    "${homeDirectory}/.local/bin"
  ];
  home.sessionVariables = {
    GPG_TTY = "$(tty)";
  };
}