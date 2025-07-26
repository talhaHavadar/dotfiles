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
    {
      host.home.applications.ghostty.enable = true;
    }
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
              yazi
            ]
            ++ optionals (platform == "nixos") [
              nodejs_22
              vlc
            ]
            ++ optionals (platform != "macos") [
              gnupg
              gnome.gvfs
              mtools
              obs-studio
              godot
              mattermost-desktop
              rpi-imager
              zig
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

      programs =
        {

          password-store = {
            enable = true;
            settings = {
              PASSWORD_STORE_DIR = "${config.home.homeDirectory}/projects/pass";
            };
          };
          ssh = {
            enable = true;
            extraConfig = ''
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
          zen-browser = {
            enable = true;
            policies = {
              AutofillAddressEnabled = true;
              AutofillCreditCardEnabled = false;
              DisableAppUpdate = true;
              DisableFeedbackCommands = true;
              DisableFirefoxStudies = true;
              DisablePocket = true; # save webs for later reading
              DisableTelemetry = true;
              DontCheckDefaultBrowser = true;
              NoDefaultBookmarks = true;
              OfferToSaveLogins = false;
            };
          };
          gpg = {
            enable = true;
            scdaemonSettings = {
              pcsc-shared = true;
            };
          };
        }
        // optionalAttrs (platform == "non-nixos") {
          zen-browser = {
            enable = true;
            nativeMessagingHosts = [ pkgs.firefoxpwa ];
            # Add any other native connectors here
            policies = {
              AutofillAddressEnabled = true;
              AutofillCreditCardEnabled = false;
              DisableAppUpdate = true;
              DisableFeedbackCommands = true;
              DisableFirefoxStudies = true;
              DisablePocket = true; # save webs for later reading
              DisableTelemetry = true;
              DontCheckDefaultBrowser = true;
              NoDefaultBookmarks = true;
              OfferToSaveLogins = false;
            };
          };

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

            cmd-left = "focus left";
            cmd-down = "focus down";
            cmd-up = "focus up";
            cmd-right = "focus right";
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
            cmd-1 = "workspace 1";
            cmd-2 = "workspace 2";
            cmd-3 = "workspace 3";
            cmd-4 = "workspace 4";
            cmd-5 = "workspace 5";
            cmd-6 = "workspace 6";
            cmd-7 = "workspace 7";
            cmd-8 = "workspace 8";
            cmd-9 = "workspace 9";
            cmd-j = "workspace j";
            cmd-m = "workspace m";
            cmd-shift-1 = "move-node-to-workspace 1";
            cmd-shift-2 = "move-node-to-workspace 2";
            cmd-shift-3 = "move-node-to-workspace 3";
            cmd-shift-4 = "move-node-to-workspace 4";
            cmd-shift-5 = "move-node-to-workspace 5";
            cmd-shift-6 = "move-node-to-workspace 6";
            cmd-shift-7 = "move-node-to-workspace 7";
            cmd-shift-8 = "move-node-to-workspace 8";
            cmd-shift-9 = "move-node-to-workspace 9";
            cmd-shift-j = "move-node-to-workspace j";
            cmd-shift-m = "move-node-to-workspace m";
            alt-tab = "workspace-back-and-forth";
            cmd-alt-left = "workspace prev";
            cmd-alt-right = "workspace next";
          };
        };
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
        ];

        casks = [
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
        ];

        masApps = {
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
      services.tailscale.enable = true;
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
