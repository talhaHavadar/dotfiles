{ lib, ... }:
{
  options = {
    host.features.bash-integration = {
      enable = lib.mkOption {
        default = true;
        type = with lib.types; bool;
        description = "Handy bash commands and settings";
      };
    };
  };
}
