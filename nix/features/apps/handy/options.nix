{ lib, ... }:
{
  options = {
    host.features.apps.handy = {
      enable = lib.mkOption {
        default = false;
        type = with lib.types; bool;
        description = "Free, open source, offline speech-to-text application";
      };
    };
  };
}
