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
  mkOutOfStoreSymlink = config.lib.file.mkOutOfStoreSymlink;
in
with lib;
{

  imports = [
    ./git.nix
  ];
  config =
    { }
    // lib.optionalAttrs (currentConfigSystem == "home") {
      home =
        {
          username = "benis";
          stateVersion = "24.05";
          packages =
            with pkgs;
            [
              yubikey-manager
              yubikey-personalization

            ]
            ++ optionals (platform == "macos") [
              arc-browser
            ]
            ++ optionals (platform != "macos") [
              teams-for-linux
              obsidian
              google-chrome
            ];
        }
        // optionalAttrs (platform == "macos") {
          homeDirectory = "/Users/benis";
        }
        // optionalAttrs (platform != "macos") {
          homeDirectory = "/home/benis";
        };

      programs.gpg = {
        enable = true;
        scdaemonSettings = {
          pcsc-shared = true;
          #disable-ccid = true;
        };
      };

    }
    // lib.optionalAttrs (currentConfigSystem == "darwin") {

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
          "ninja"
          "gperf"
          "python3"
          "python-tk"
          "ccache"
          "libmagic"
          "wget"
          "zig"
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
          "jordanbaird-ice"
          "visual-studio-code"
          "godot"
          "poedit"
          "ghostty"
        ];

        masApps = {
        };

        onActivation = {
          autoUpdate = false;
          # cleanup = "zap";
          upgrade = false;
        };

      };

      system.defaults = {
        finder.AppleShowAllExtensions = true;
        dock.autohide = true;
        controlcenter.Bluetooth = true;
        controlcenter.FocusModes = true;
      };
    }
    // lib.optionalAttrs (currentConfigSystem == "nixos") {
    };
}
