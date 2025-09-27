{
  config,
  lib,
  pkgs,
  ...
}:
let
  tailscale_config = config.host.features.tailscale;
in
{
  options = {
    host.features.tailscale = {
      enable = lib.mkOption {
        default = false;
        type = with lib.types; bool;
        description = "tailscale VPN system";
      };
    };
  };

  config = lib.mkIf tailscale_config.enable {
    home.packages = with pkgs; [
      tailscale
    ];
  };
}
