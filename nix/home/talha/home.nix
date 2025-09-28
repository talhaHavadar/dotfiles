{
  config,
  lib,
  pkgs,
  ...
}:
let
  isPackagingEnabled = (builtins.getEnv "INCLUDE_PACKAGING") == "true";
  mkOutOfStoreSymlink = config.lib.file.mkOutOfStoreSymlink;
  isDarwin = pkgs.stdenv.isDarwin;
  isNixOS = pkgs.stdenv.isLinux && builtins.pathExists /etc/NIXOS;
  isLinuxNonNixOS = pkgs.stdenv.isLinux && !builtins.pathExists /etc/NIXOS;
  isLinux = pkgs.stdenv.isLinux;
  gpgAgentPrefix =
    if isNixOS then
      "/run/user/1002/gnupg" # TODO: need a better way to inject user id here
    else if isDarwin then
      "/Users/talha/.gnupg"
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
      }
      // lib.optionalAttrs isPackagingEnabled {
        ".devscripts".source = mkOutOfStoreSymlink ../../../dot/devscripts;
        ".gbp.conf".source = mkOutOfStoreSymlink ../../../dot/gbp.conf;
        ".mk-sbuild.rc".source = mkOutOfStoreSymlink ../../../dot/mk-sbuild.rc;
        ".quiltrc-dpkg".source = mkOutOfStoreSymlink ../../../dot/quiltrc-dpkg;
        ".sbuildrc".source = mkOutOfStoreSymlink ../../../dot/sbuildrc;
        ".packaging.bashrc".source = mkOutOfStoreSymlink ../../../dot/packaging.bashrc;
        ".local/bin/packaging".source = mkOutOfStoreSymlink ../../../dot/bin/packaging/packaging;
        ".local/bin/packaging-get-uploads".source =
          mkOutOfStoreSymlink ../../../dot/bin/packaging/get-uploads;
        ".local/bin/packaging-mk-sbuild".source = mkOutOfStoreSymlink ../../../dot/bin/packaging/mk-sbuild;
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
      // lib.optionalAttrs (isLinux) {
        GIO_EXTRA_MODULES = "${pkgs.gvfs}/lib/gio/modules";
      };

      packages =
        with pkgs;
        [
          gnupg
        ]
        ++ lib.optionals (isNixOS) [
          vlc
          gnome.gvfs
          mtools
        ]
        ++ lib.optionals (isDarwin) [
        ]
        ++ lib.optionals (isLinuxNonNixOS) [
          gnome.gvfs
          mtools
          godot
          mattermost-desktop
          yazi
          (obsidian.override {
            commandLineArgs = [
              "--enable-features=UseOzonePlatform"
              "--ozone-platform=x11"
              "--force-device-scale-factor=2"
            ];
          })
        ];

    }
    // lib.optionalAttrs (isDarwin) {
      homeDirectory = "/Users/talha";
      activation = {
        mint-swift-bundler = lib.hm.dag.entryAfter [ "installPackages" ] ''
          PATH="/opt/homebrew/bin:${pkgs.git}/bin:/usr/bin:$PATH" $DRY_RUN_CMD mint install stackotter/swift-bundler@main
        '';
      };
    }
    // lib.optionalAttrs (isLinux) {
      homeDirectory = "/home/talha";
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
        userName = "Talha Can Havadar";
        userEmail = "havadartalha@gmail.com";
        extraConfig = {
          core.excludesfile = "~/.gitignore_global";
          sparse.user.id = "talhaHavadar";
          rebase.autoSquash = true;
          commit.gpgSign = "true";
          tag.gpgSign = true;
          log.showSignature = true;
          includeIf."gitdir:~/workspace/".path = "~/workspace/.gitconfig";
        };
      };
      ssh = {
        enable = true;
        extraConfig = ''
          Include ~/.orbstack/ssh/config
          IdentityFile ~/.ssh/id_ed25519_sk_mobil

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

          Host *launchpad.net
            IdentityFile ~/.ssh/id_ed25519
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
