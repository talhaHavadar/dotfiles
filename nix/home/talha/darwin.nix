{
  config,
  lib,
  pkgs,
  platform,
  currentConfigSystem,
  ...
}:
{
  config = {
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
        "python3"
        "python-tk"
        # Swift package manager
        # https://github.com/cameroncooke/XcodeBuildMCP/tree/v26.0.0?tab=readme-ov-file
      ];

      casks = [
        "MonitorControl"
        "karabiner-elements"
        {
          name = "middleclick";
          args = {
            no_quarantine = true;
          };
        }
        "obsidian"
        "jordanbaird-ice"
      ];

      masApps = {
      };

      onActivation = {
        autoUpdate = false;
        cleanup = "zap";
        upgrade = false;
      };

    };

    system.defaults = {
      finder.AppleShowAllExtensions = true;
      dock.autohide = true;
      controlcenter.Bluetooth = true;
      controlcenter.FocusModes = true;
    };
  };
}
