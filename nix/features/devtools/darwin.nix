{
  config,
  lib,
  pkgs,
  ...
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
        "openssh"
        "mint"
        "libmagic"
      ];

      casks = [
        "container"
        "multipass"
        "orbstack"
        "raspberry-pi-imager"
        "openvpn-connect"
        "nordic-nrf-command-line-tools"
        "poedit"
        "godot"
        "obs"
        "swiftformat-for-xcode"
        "kicad"
        "wifiman"
      ];

      masApps = {
      };
    };
  };
}
