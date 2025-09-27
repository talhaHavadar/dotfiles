{
  config,
  lib,
  pkgs,
  ...
}:
let
  aerospace_config = config.host.features.aerospace;
in
{
  options = {
    host.features.aerospace = {
      enable = lib.mkOption {
        default = false;
        type = with lib.types; bool;
        description = "Aerospace - Window Manager for MacOS";
      };
    };
  };

  config = lib.mkIf aerospace_config.enable {
    # not available for others so no home manager config
  };
}
