# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  self,
  config,
  lib,
  pkgs,
  ...
}:

{

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = [
    pkgs.vim
  ];

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  # nix.package = pkgs.nix;

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  # Enable alternative shell support in nix-darwin.
  # programs.fish.enable = true;
  programs.bash.enable = true;

  # Set Git commit hash for darwin-version.
  system.configurationRevision = self.rev or self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 5;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;

  networking.computerName = "Talha's MacMini";
  networking.hostName = "talha-macmini";
  networking.localHostName = "talha-macmini";

  power.sleep.display = 60;

  programs.gnupg.agent.enable = true;

  services.aerospace = {
    enable = true;
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
