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
  config = lib.mkIf tailscale_config.enable {
    services.tailscale.enable = true;
  };
}
