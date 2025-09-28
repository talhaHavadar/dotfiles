{ lib, ... }:
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
}
