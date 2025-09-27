{
  config,
  lib,
  pkgs,
  platform,
  currentConfigSystem,
  ...
}:
let
  pyp = pkgs.python312Packages;
  isPackagingEnabled = (builtins.getEnv "INCLUDE_PACKAGING") == "true";
  mkOutOfStoreSymlink = config.lib.file.mkOutOfStoreSymlink;
  mkIfElse =
    p: yes: no:
    lib.mkMerge [
      (lib.mkIf p yes)
      (lib.mkIf (!p) no)
    ];
  gpgAgentPrefix =
    if platform == "nixos" then
      "/run/user/1002/gnupg"
    else if platform == "macos" then
      "/Users/talha/.gnupg"
    else
      "/run/user/1000/gnupg";
in
with lib;
{

  imports = [
    ./git.nix
  ];

  config = {
    host.features.yubikey.enable = true;
    host.features.tailscale.enable = true;
    host.features.zen-browser.enable = true;
    host.features.aerospace.enable = false;
  }
  // optionalAttrs (currentConfigSystem == "home") {
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
      # pkgs.stdenv.isDarwin
      sessionVariables = {
        TERM = "xterm-256color";
      }
      // optionalAttrs (platform == "macos") {
        PATH = "/opt/homebrew/opt/python/libexec/bin:$PATH";
      }
      // optionalAttrs (platform != "macos") {
        GIO_EXTRA_MODULES = "${pkgs.gvfs}/lib/gio/modules";
      };
      packages =
        with pkgs;
        [
        ]
        ++ optionals (platform == "nixos") [
          nodejs_22
          vlc
        ]
        ++ optionals (platform == "macos") [
          claude-code
        ]
        ++ optionals (platform == "nixos-container") [
          uv
          go
          gnupg
          claude-code
        ]
        ++ optionals (platform != "macos" && platform != "nixos-container") [
          uv
          go
          gnupg
          gnome.gvfs
          mtools
          obs-studio
          godot
          mattermost-desktop
          rpi-imager
          zig
          claude-code
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
    // optionalAttrs (platform == "macos") {
      homeDirectory = "/Users/talha";
      activation = {
        mint-swift-bundler = lib.hm.dag.entryAfter [ "installPackages" ] ''
          PATH="/opt/homebrew/bin:${pkgs.git}/bin:/usr/bin:$PATH" $DRY_RUN_CMD mint install stackotter/swift-bundler@main
        '';
      };
    }
    // optionalAttrs (platform != "macos") {
      homeDirectory = "/home/talha";
    };

    programs = {

      password-store = {
        enable = true;
        settings = {
          PASSWORD_STORE_DIR = "${config.home.homeDirectory}/projects/pass";
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
    // optionalAttrs (platform == "nixos") {
      gpg = {
        enable = true;
        scdaemonSettings = {
          pcsc-shared = true;
          disable-ccid = true;
        };
      };
    }
    // optionalAttrs (platform == "non-nixos") {
      waybar = {
        settings = {
          mainBar = {
            "custom/lock".on-click = mkForce "sh -c '(sleep 0.5s; swaylock)' & disown";
          };
        };
      };
    };
    services =
      { }
      // optionalAttrs (platform == "nixos") {
        flameshot = {
          enable = true;
          package = pkgs.flameshot.override { enableWlrSupport = true; };
        };
      };

    wayland =
      { }
      // optionalAttrs (platform == "non-nixos") {
        windowManager.hyprland.settings = {
          "$screenlocker" = mkForce "swaylock";
        };
      };
  }
  // optionalAttrs (currentConfigSystem == "darwin") {
    users.users.talha = {
      name = "talha";
      home = "/Users/talha";
    };

    # services.karabiner-elements = {
    #   enable = true;
    # };

    # https://daiderd.com/nix-darwin/manual/index.html#opt-homebrew.brews
    homebrew = {
      enable = true;

      taps = [
        "cameroncooke/axe"
      ];

      brews = [
        "git"
        "bash"
        "libfido2"
        "openssh"
        "tailscale"
        "cmake"
        "ninja"
        "gperf"
        "python3"
        "python-tk"
        "ccache"
        "qemu"
        "dtc"
        "libmagic"
        "wget"
        "openocd"
        "gh"
        "zig"
        # Swift package manager
        "mint"
        "uv"
        # https://github.com/cameroncooke/XcodeBuildMCP/tree/v26.0.0?tab=readme-ov-file
        "node"
        "go"
        "stripe-cli"
      ];

      casks = [
        "container"
        "multipass"
        "yubico-authenticator"
        "MonitorControl"
        "orbstack"
        "raspberry-pi-imager"
        "openvpn-connect"
        "karabiner-elements"
        {
          name = "middleclick";
          args = {
            no_quarantine = true;
          };
        }
        "google-chrome"
        "obsidian"
        "kicad"
        "wifiman"
        "jordanbaird-ice"
        "nordic-nrf-command-line-tools"
        "visual-studio-code"
        "godot"
        "poedit"
        "obs"
        "ghostty"
        "swiftformat-for-xcode"
      ];

      masApps = {
      };

      onActivation = {
        autoUpdate = false;
        #cleanup = "zap";
        upgrade = false;
      };

    };

    # users.users.talha.openssh.authorizedKeys.keys = [ ];

    system.defaults = {
      # loginwindow.autoLoginUser = "talha";
      finder.AppleShowAllExtensions = true;
      dock.autohide = true;
      controlcenter.Bluetooth = true;
      controlcenter.FocusModes = true;
    };
  }
  // optionalAttrs (currentConfigSystem == "nixos") {
    services.openvpn.servers = {
      tw-vpn = {
        config = ''config /etc/nixos/talha-vpn/tw-tchavadar.conf '';
        autoStart = false;
        #updateResolvConf = true;
      };
      uk-vpn = {
        config = ''config /etc/nixos/talha-vpn/uk-tchavadar.conf '';
        autoStart = false;
        #updateResolvConf = true;
      };
    };
  };
}
