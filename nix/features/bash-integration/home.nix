{
  config,
  lib,
  pkgs,
  username,
  platform,
  flakeOutput,
  ...
}:
let
  bash-integration_config = config.host.features.bash-integration;
  homeDirectory = config.home.homeDirectory;
  username = config.home.username;
  isPackagingEnabled = (builtins.getEnv "INCLUDE_PACKAGING") == "true";
  isDarwin = pkgs.stdenv.isDarwin;
  isNixOS = pkgs.stdenv.isLinux && builtins.pathExists /etc/NIXOS;
  isLinuxNonNixOS = pkgs.stdenv.isLinux && !builtins.pathExists /etc/NIXOS;
  isLinux = pkgs.stdenv.isLinux;
in
{
  config = lib.mkIf bash-integration_config.enable {
    home.sessionPath = [
      "${homeDirectory}/.local/bin"
    ];
    home.sessionVariables = {
      NIX_SYSTEM = pkgs.system;
      NIX_STORE = "/nix/store";
      NIX_MYUSER = "${username}";
      NIX_PLATFORM = "${platform}";
    };

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
        bashrcExtra = ''
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
        + lib.optionalString (isLinuxNonNixOS) ''
          update-home() {
            INCLUDE_PACKAGING=${toString isPackagingEnabled} NIXPKGS_ALLOW_UNFREE=1 NIX_MYUSER="$USER" home-manager switch --flake ~/.config/dotfiles/nix#${flakeOutput} --show-trace --impure -b backup
          }
        ''
        + lib.optionalString (isDarwin) ''
          update-home() {
            INCLUDE_PACKAGING=${toString isPackagingEnabled} NIXPKGS_ALLOW_UNFREE=1 NIX_MYUSER="$USER" sudo -E darwin-rebuild switch --flake ~/.config/dotfiles/nix#${flakeOutput} --show-trace --impure
          }
        ''
        + lib.optionalString (isNixOS) ''
          update-system() {
            INCLUDE_PACKAGING=${toString isPackagingEnabled} NIXPKGS_ALLOW_UNFREE=1 NIX_MYUSER="$USER" sudo -E nixos-rebuild switch --flake ~/.config/dotfiles/nix#${flakeOutput} --show-trace --impure
          }
        ''
        + lib.optionalString isPackagingEnabled ". ~/.packaging.bashrc";

        initExtra =
          ''''
          + lib.optionalString (isDarwin) ''
            eval "$(/opt/homebrew/bin/brew shellenv)"
            export PATH="$HOME/.mint/bin:$(brew --prefix)/opt/python/libexec/bin:$PATH";
          ''
          + lib.optionalString (!isDarwin && platform != "nixos-container") ''
            gpgconf --create-socketdir
            # GPG-Agent
            unset SSH_AGENT_PID
            unset SSH_AUTH_SOCK
            export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
          ''
          + ''
            source ~/.tmux-completion
            source ~/.complete_alias

            complete -F _complete_alias t
            export GPG_TTY="$(tty)"
            source ~/.extra_bashrc 2>/dev/null || true
          '';

        shellAliases = {
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
        };
      };
    };
  };
}
