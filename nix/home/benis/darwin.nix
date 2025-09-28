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
    system.primaryUser = "benis";
    users.users.benis = {
      name = "benis";
      home = "/Users/benis";
    };

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
        "obsidian"
        "jordanbaird-ice"
      ];

      masApps = {
      };

      onActivation = {
        autoUpdate = false;
        cleanup = "zap";
        upgrade = true;
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
