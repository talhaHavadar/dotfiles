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

  config =
    { }
    // optionalAttrs (currentConfigSystem == "home") {
      home =
        {
          username = "talha";
          stateVersion = "24.05";
          file =
            {
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
            };
          # pkgs.stdenv.isDarwin
          sessionVariables =
            {
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
              pass
              yazi
            ]
            ++ optionals (platform == "nixos") [
              google-chrome
              # (google-chrome.override {
              #   commandLineArgs = [
              #     "--enable-features=UseOzonePlatform"
              #     "--ozone-platform=x11"
              #     "--force-device-scale-factor=2"
              #   ];
              # })
              vlc
            ]
            ++ optionals (platform != "macos") [
              gnome.gvfs
              mtools
              obs-studio
              godot
              mattermost-desktop
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
        }
        // optionalAttrs (platform != "macos") {
          homeDirectory = "/home/talha";
        };

      programs =
        {
          ssh = {
            enable = true;
            extraConfig = ''
              IdentityFile ~/.ssh/id_ed25519_sk_mobil

              Host dev-amd64-unlock
                User root
                Port 2222
                HostName dev-amd64.lan

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

              Host dev-amd64.lan
                User ubuntu
                StreamLocalBindUnlink yes
                RemoteForward /run/user/1000/gnupg/S.gpg-agent ${gpgAgentPrefix}/S.gpg-agent 
                RemoteForward /run/user/1000/gnupg/S.gpg-agent.ssh ${gpgAgentPrefix}/S.gpg-agent.ssh

              Host badgerd-nl.jump
                User ubuntu
                HostName badgerd-nl.local
                ProxyJump dev-amd64.lan
                StreamLocalBindUnlink yes
                RemoteForward /run/user/1000/gnupg/S.gpg-agent ${gpgAgentPrefix}/S.gpg-agent 

              Host launchpad.net
                IdentityFile ~/.ssh/id_ed25519
            '';
          };
        }
        // optionalAttrs (platform == "nixos") {
          gpg = {
            enable = true;
            scdaemonSettings = {
              pcsc-shared = true;
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

      services.aerospace = {
        enable = false;
        settings = {
          on-focus-changed = [ "move-mouse window-lazy-center" ];

          on-window-detected = [
            {
              "if".app-id = "Mattermost.Desktop";
              "check-further-callbacks" = false;
              "run" = [ "move-node-to-workspace m" ];
            }
            {
              "if".app-id = "com.apple.mail";
              "check-further-callbacks" = false;
              "run" = "move-node-to-workspace m";
            }
          ];
          exec-on-workspace-change = [
            "/opt/homebrew/bin/bash"
            "-c"
            "sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE"
          ];
          automatically-unhide-macos-hidden-apps = false;

          gaps = {
            inner.horizontal = 24;
            inner.vertical = 24;
            outer.left = 16;
            outer.bottom = 12;
            outer.top = 12;
            outer.right = 16;
          };
          mode.main.binding = {
            # See: https://nikitabobko.github.io/AeroSpace/commands#exec-and-forget
            # You can uncomment the following lines to open up terminal with alt + enter shortcut (like in i3)
            # ctrl-enter = ''
            #   exec-and-forget osascript -e '
            #            tell application "kitty"
            #                do script
            #                activate
            #            end tell'
            # '';
            # See: https://nikitabobko.github.io/AeroSpace/commands#layout
            ctrl-alt-equal = "layout tiles horizontal vertical";
            ctrl-alt-f = "layout floating";
            # ctrl-alt-comma = "layout accordion horizontal vertical";
            cmd-shift-f = "fullscreen";

            ctrl-alt-left = "focus left";
            ctrl-alt-down = "focus down";
            ctrl-alt-up = "focus up";
            ctrl-alt-right = "focus right";
            ctrl-alt-shift-right = "join-with right";
            ctrl-alt-shift-left = "join-with left";
            ctrl-alt-shift-down = "join-with down";
            ctrl-alt-shift-up = "join-with up";

            ctrl-shift-left = "move left";
            ctrl-shift-down = "move down";
            ctrl-shift-up = "move up";
            ctrl-shift-right = "move right";
            ctrl-alt-shift-k = "resize smart +50";
            ctrl-alt-shift-j = "resize smart -50";

            # See: https://nikitabobko.github.io/AeroSpace/commands#workspace
            ctrl-1 = "workspace 1";
            ctrl-2 = "workspace 2";
            ctrl-3 = "workspace 3";
            ctrl-4 = "workspace 4";
            ctrl-5 = "workspace 5";
            ctrl-6 = "workspace 6";
            ctrl-7 = "workspace 7";
            ctrl-8 = "workspace 8";
            ctrl-9 = "workspace 9";
            ctrl-j = "workspace j";
            ctrl-m = "workspace m";
            ctrl-shift-1 = "move-node-to-workspace 1";
            ctrl-shift-2 = "move-node-to-workspace 2";
            ctrl-shift-3 = "move-node-to-workspace 3";
            ctrl-shift-4 = "move-node-to-workspace 4";
            ctrl-shift-5 = "move-node-to-workspace 5";
            ctrl-shift-6 = "move-node-to-workspace 6";
            ctrl-shift-7 = "move-node-to-workspace 7";
            ctrl-shift-8 = "move-node-to-workspace 8";
            ctrl-shift-9 = "move-node-to-workspace 9";
            ctrl-shift-j = "move-node-to-workspace j";
            ctrl-shift-m = "move-node-to-workspace m";
            alt-tab = "workspace-back-and-forth";
            ctrl-left = "workspace prev";
            ctrl-right = "workspace next";
          };
        };
      };

      services.jankyborders = {
        enable = true;
        width = 1.0;
        active_color = "gradient(top_right=0xFF0D9BBF,bottom_left=0xFFB5E710)";
        inactive_color = "0x99000000";
        blur_radius = 2.0;
        order = "above";
      };

      services.sketchybar = {
        enable = false;
        config = '''';
        # extraPackages = [ pkgs.jq ];
      };

      services.tailscale = {
        enable = true;
      };

      # services.karabiner-elements = {
      #   enable = true;
      # };

      # https://daiderd.com/nix-darwin/manual/index.html#opt-homebrew.brews
      homebrew = {
        enable = true;

        brews = [
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
        ];

        casks = [
          "yubico-authenticator"
          "MonitorControl"
          "orbstack"
          "raspberry-pi-imager"
          "tunnelblick"
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
          # "firefox"
          "wifiman"
          "jordanbaird-ice"
          "nordic-nrf-command-line-tools"
          "visual-studio-code"
          "godot"
          "poedit"
          {
            name = "librewolf";
            args = {
              no_quarantine = true;
            };
          }
          "obs"
        ];

        masApps = {
          "Mattermost" = 1614666244;
        };

        onActivation = {
          autoUpdate = false;
          cleanup = "zap";
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
