# Yubikey feature module for NixOS system context
{
  config,
  lib,
  pkgs,
  ...
}:
let
  yubikey_config = config.host.features.yubikey;
in
{
  config = lib.mkIf yubikey_config.enable {
    homebrew = {
      enable = true;
      taps = [ ];

      brews = [
        "libfido2"
        "openssh"
      ];

      casks = [
        "yubico-authenticator"
      ];

      masApps = {
      };
    };
  };
}
