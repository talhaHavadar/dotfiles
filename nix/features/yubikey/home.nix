# Yubikey feature module for home-manager context
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
    home.packages = with pkgs; [
      yubikey-manager
    ];
  };
}
