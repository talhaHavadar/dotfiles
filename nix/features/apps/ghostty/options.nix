{ lib, ... }:
{
  options = {
    host.features.apps.ghostty = {
      enable = lib.mkOption {
        default = true;
        type = with lib.types; bool;
        description = "A ghost like terminal";
      };
    };
  };
}
