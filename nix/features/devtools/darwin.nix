{ config
, lib
, pkgs
, ...
}:
let
  devtools_config = config.host.features.devtools;
in
{
  config = lib.mkIf devtools_config.enable {
    homebrew = {
      enable = true;
      taps = [ ];

      brews = [
        "bash"
        "git"
        "go"
        "curl"
        "openssh"
        "mint"
        "libmagic"
      ];

      casks = [
        "container"
        "raspberry-pi-imager"
        "nordic-nrf-command-line-tools"
        "poedit"
        "godot"
        "swiftformat-for-xcode"
        "kicad"
        "wifiman"
      ];

      masApps = { };
    };
  };
}
