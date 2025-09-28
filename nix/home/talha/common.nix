{ config, ... }:
{
  imports = [
  ];

  config = {
    host.features.yubikey.enable = true;
    host.features.tailscale.enable = true;
    host.features.devtools.enable = true;
    host.features.aerospace.enable = false;

    host.features.apps.zen-browser.enable = true;
  };
}
