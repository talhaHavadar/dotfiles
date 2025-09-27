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
  options = {
    host.features.yubikey = {
      enable = lib.mkOption {
        default = false;
        type = with lib.types; bool;
        description = "FIDO Key support for home-manager";
      };
    };
  };

  config = lib.mkIf yubikey_config.enable {
    home.packages = with pkgs; [
      yubikey-manager
    ];
  };
}
