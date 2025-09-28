{ config, ... }:
{
  imports = [
  ];

  config = {
    host.features.yubikey.enable = true;
    host.features.tailscale.enable = true;
    host.features.devtools.enable = true;
    host.features.aerospace.enable = false;

    host.features.apps.ghostty.enable = true;
    host.features.apps.neovim.enable = true;
    host.features.apps.neovim.copilot.enable = true;
    host.features.apps.neovim.claude-code.enable = true;
    host.features.apps.zen-browser.enable = true;
  };
}
