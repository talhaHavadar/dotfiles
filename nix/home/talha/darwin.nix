{ config
, lib
, pkgs
, platform
, currentConfigSystem
, ...
}:
{
  config = {
    system.primaryUser = "talha";
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
        "jj"
        "python3"
        "python-tk"
        # Swift package manager
        # https://github.com/cameroncooke/XcodeBuildMCP/tree/v26.0.0?tab=readme-ov-file
      ];

      casks = [
        "jordanbaird-ice"
      ];

      masApps = { };

      onActivation = {
        autoUpdate = false;
        cleanup = "none";
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
