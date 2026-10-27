{ config
, lib
, pkgs
, ...
}:
let
  mkOutOfStoreSymlink = config.lib.file.mkOutOfStoreSymlink;
  # Use builtins.currentSystem to determine platform without evaluating pkgs
  system = builtins.currentSystem;
  isDarwin = builtins.match ".*-darwin" system != null;
  isLinux = builtins.match ".*-linux" system != null;
  isNixOS = isLinux && builtins.pathExists /etc/NIXOS;
  isLinuxNonNixOS = isLinux && !builtins.pathExists /etc/NIXOS;
  gpgAgentPrefix =
    if isNixOS then
      "/run/user/1002/gnupg" # TODO: need a better way to inject user id here
    else if isDarwin then
      "${config.home.homeDirectory}/.gnupg"
    else
      "/run/user/1000/gnupg";
in
{
  config = {
    home = {
      username = "talha";
      stateVersion = "24.05";
      file = {
        "workspace/.gitconfig".source = mkOutOfStoreSymlink ../../../dot/gitconfig.workspace;
        "projects/.gitconfig".source = mkOutOfStoreSymlink ../../../dot/gitconfig.projects;
        ".local/bin/lxc-run".source = mkOutOfStoreSymlink ../../../dot/bin/lxc-run;
        ".local/bin/tq".source = mkOutOfStoreSymlink ../../../dot/bin/tq;
        ".local/bin/tq-worker".source = mkOutOfStoreSymlink ../../../dot/bin/tq-worker;
        ".config/systemd/user/tq.service".source = mkOutOfStoreSymlink ../../../dot/systemd/tq.service;
        ".config/systemd/user/tq.timer".source = mkOutOfStoreSymlink ../../../dot/systemd/tq.timer;
        ".config/jj".source = mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/dotfiles/dot/jj.talha";
        ".config/river".source = mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/dotfiles/dot/river";
        ".config/systemd/user/river-session.target".source = mkOutOfStoreSymlink ../../../dot/systemd/user/river-session.target;
        ".config/systemd/user/river-lid-monitor.service".source = mkOutOfStoreSymlink ../../../dot/systemd/user/river-lid-monitor.service;
        ".config/kwm".source = mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/dotfiles/dot/kwm";
        ".config/kanshi".source = mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/dotfiles/dot/kanshi";
        ".config/wlogout".source = mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/dotfiles/dot/wlogout";
        ".config/waybar".source = mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/dotfiles/dot/waybar";
        ".local/bin/contained".source = mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/dotfiles/dot/bin/contained/contained.sh";
      };

      # - pkgs.stdenv.isLinux
      # - pkgs.stdenv.isAarch64
      # - pkgs.stdenv.isx86_64
      # - pkgs.stdenv.isDarwin
      sessionVariables = {
        TERM = "xterm-256color";
      }
      // lib.optionalAttrs (isDarwin) {
        PATH = "/opt/homebrew/opt/python/libexec/bin:$PATH";
      }
      // lib.optionalAttrs (isLinux) { };

      packages =
        with pkgs;
        [ ]
          ++ lib.optionals (isNixOS) [
          vlc
          gnome.gvfs
          mtools
        ]
          ++ lib.optionals (isDarwin) [
        ]
          ++ lib.optionals (isLinuxNonNixOS) [
        ];

    }
    // lib.optionalAttrs (isDarwin) {
      homeDirectory = "/Users/${config.home.username}";
      activation = {
        # mint-swift-bundler = lib.hm.dag.entryAfter [ "installPackages" ] ''
        #   PATH="/opt/homebrew/bin:${pkgs.git}/bin:/usr/bin:$PATH" $DRY_RUN_CMD mint install stackotter/swift-bundler@main
        # '';
      };
    }
    // lib.optionalAttrs (isLinux) {
      homeDirectory = "/home/${config.home.username}";
    };

    programs = {
      password-store = {
        enable = true;
        settings = {
          PASSWORD_STORE_DIR = "${config.home.homeDirectory}/projects/pass";
        };
      };
      git = {
        enable = true;
        settings = {
          core.excludesfile = "~/.gitignore_global";
          sparse.user.id = "talhaHavadar";
          rebase.autoSquash = true;
          commit.gpgSign = "true";
          # tag.gpgSign = true;
          # log.showSignature = true;
          includeIf."gitdir:~/workspace/".path = "~/workspace/.gitconfig";
          includeIf."gitdir:~/projects/".path = "~/projects/.gitconfig";
        };
      };
      ssh = {
        enable = true;
        extraConfig = ''
          Include ~/.ssh/extra_config

          Host dev-amd64-unlock
            User root
            Port 2222
            HostName dev-amd64.lan

          Host macmini.tailscale
            HostName talha-macmini
            User talha
            StreamLocalBindUnlink yes
            PermitLocalCommand yes
            LocalCommand unset SSH_AUTH_SOCK
            RemoteForward /Users/talha/.gnupg/S.gpg-agent ${gpgAgentPrefix}/S.gpg-agent
            RemoteForward /Users/talha/.gnupg/S.gpg-agent.ssh ${gpgAgentPrefix}/S.gpg-agent.ssh

          Host macmini.lan
            HostName 10.17.0.21
            User talha
            StreamLocalBindUnlink yes
            PermitLocalCommand yes
            LocalCommand unset SSH_AUTH_SOCK
            RemoteForward /Users/talha/.gnupg/S.gpg-agent ${gpgAgentPrefix}/S.gpg-agent
            RemoteForward /Users/talha/.gnupg/S.gpg-agent.ssh ${gpgAgentPrefix}/S.gpg-agent.ssh

          Host pi-dev.local
            User talha
            StreamLocalBindUnlink yes
            RemoteForward /run/user/1000/gnupg/S.gpg-agent ${gpgAgentPrefix}/S.gpg-agent

          Host dev-amd64.tailscale
            HostName dev-amd64
            User ubuntu
            StreamLocalBindUnlink yes
            RemoteForward /run/user/1000/gnupg/S.gpg-agent ${gpgAgentPrefix}/S.gpg-agent
            RemoteForward /run/user/1000/gnupg/S.gpg-agent.ssh ${gpgAgentPrefix}/S.gpg-agent.ssh

          Host dev-amd64.lan
            User ubuntu
            StreamLocalBindUnlink yes
            RemoteForward /run/user/1000/gnupg/S.gpg-agent ${gpgAgentPrefix}/S.gpg-agent
            RemoteForward /run/user/1000/gnupg/S.gpg-agent.ssh ${gpgAgentPrefix}/S.gpg-agent.ssh

          Host orb
            StreamLocalBindUnlink yes
            RemoteForward /run/user/501/gnupg/S.gpg-agent ${gpgAgentPrefix}/S.gpg-agent
            RemoteForward /run/user/501/gnupg/S.gpg-agent.ssh ${gpgAgentPrefix}/S.gpg-agent.ssh

          Host badgerd-nl.jump
            User ubuntu
            HostName badgerd-nl.local
            ProxyJump dev-amd64.lan
            StreamLocalBindUnlink yes
            RemoteForward /run/user/1000/gnupg/S.gpg-agent ${gpgAgentPrefix}/S.gpg-agent
        '';
      };
    }
    // lib.optionalAttrs (isNixOS) {
      gpg = {
        enable = true;
        scdaemonSettings = {
          pcsc-shared = true;
          disable-ccid = true;
        };
      };
    }
    // lib.optionalAttrs (isLinuxNonNixOS) {
      waybar = {
        settings = {
          mainBar = {
            "custom/lock".on-click = lib.mkForce "sh -c '(sleep 0.5s; swaylock)' & disown";
          };
        };
      };
    };

    services =
      { }
      // lib.optionalAttrs (isNixOS) {
        flameshot = {
          enable = true;
          package = pkgs.flameshot.override { enableWlrSupport = true; };
        };
      };

    wayland =
      { }
      // lib.optionalAttrs (isLinuxNonNixOS) {
        windowManager.hyprland.settings = {
          "$screenlocker" = lib.mkForce "swaylock";
        };
      };
  };

}
