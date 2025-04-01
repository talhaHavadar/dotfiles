{
  config,
  inputs,
  lib,
  pkgs,
  platform,
  ...
}:
let
  homeDirectory = config.home.homeDirectory;
  isPackagingEnabled = (builtins.getEnv "INCLUDE_PACKAGING") == "true";
in
with lib;
{
  imports = [
    ./kitty.nix
  ];

  programs = {
    home-manager.enable = true;
    starship.enable = true;
    zoxide = {
      enable = true;
      options = [
        "--cmd cd"
      ];
    };
    fzf.enable = true;

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
                      tmux switch-client -t $session_name || (cd $result && tmux new-session -d -s $session_name && cd - && tmux switch-client -t $session_name)
                  else
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
        + optionalString (platform == "ubuntu-headless") ''
          update-home() {
            NIXPKGS_ALLOW_UNFREE=1 home-manager switch --flake ~/.config/dotfiles/nix#ubuntu-headless --show-trace --impure -b backup
          }
        ''
        + optionalString (platform != "macos") ''
          update-home() {
            NIXPKGS_ALLOW_UNFREE=1 home-manager switch --flake ~/.config/dotfiles/nix#linux --show-trace --impure -b backup
          }
        ''
        + optionalString isPackagingEnabled ". ~/.packaging.bashrc";
      initExtra =
        ''
          source ~/.tmux-completion
          source ~/.complete_alias
          # GPG-Agent
          unset SSH_AGENT_PID
          unset SSH_AUTH_SOCK
          export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"

          complete -F _complete_alias t
          export GPG_TTY="$(tty)"
        ''
        + optionalString (platform == "macos") ''
          eval "$(/opt/homebrew/bin/brew shellenv)"
          export PATH="$(brew --prefix)/opt/python/libexec/bin:$PATH";
        ''
        + optionalString (platform != "macos") ''
          gpgconf --create-socketdir
        '';

      shellAliases =
        {
          gg = "git grep --no-index";
          ls = "ls --color=auto";
          ll = "ls --color=auto -al";
          tn = "tmux new -As $(pwd | sed \"s/.*\\///g\")";
          t = "tmux new -A -s";
          tl = "tmux list-sessions";
          tk = "tmux kill-session -t";
          tf = "tmux_find_or_create_prompt";
          tp = "tmux list-panes -a -F '#D #T #{pane_tty} #{pane_current_command} #{pane_current_path}'";
          gvim = "nvim --listen ~/.cache/nvim/godot.pipe .";
        }
        // optionalAttrs isPackagingEnabled {
          update-home = "INCLUDE_PACKAGING=\"true\" update-home";
        };
    };
  };

  home.sessionPath = [
    "${homeDirectory}/.local/bin"
  ];
  home.sessionVariables = {
    NIX_SYSTEM = pkgs.system;
    NIX_STORE = "/nix/store";
  };
}
