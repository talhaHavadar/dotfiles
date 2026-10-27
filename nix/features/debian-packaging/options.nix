{ lib, ... }:
{
  options = {
    host.features.debian-packaging = {
      enable = lib.mkOption {
        default = false;
        type = with lib.types; bool;
        description = "Tools for Debian/Ubuntu packaging work";
      };
    };
  };
}
