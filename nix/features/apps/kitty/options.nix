{ lib, ... }:
{
  options = {
    host.features.apps.kitty = {
      enable = lib.mkOption {
        default = false;
        type = with lib.types; bool;
        description = "Kitty Terminal Emulator";
      };
    };
  };
}
