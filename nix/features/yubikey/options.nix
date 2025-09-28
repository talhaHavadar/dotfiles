{ lib, ... }:
{
  options = {
    host.features.yubikey = {
      enable = lib.mkOption {
        default = false;
        type = with lib.types; bool;
        description = "FIDO Key support for NixOS";
      };
    };
  };
}
