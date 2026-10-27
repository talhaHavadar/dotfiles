{ config, ... }:
{
  imports = [
  ];

  config = {
    host.features.yubikey.enable = true;
    host.features.tailscale.enable = true;
    host.features.debian-packaging.enable = true;
    host.features.devtools.enable = true;
    host.features.devtools.build-tools.cpp.enable = true;
    host.features.aerospace.enable = false;
    host.features.bash-integration.enable = true;

    host.features.apps.ghostty.enable = true;
    host.features.apps.neovim.enable = true;
    host.features.apps.zen-browser.enable = false;
    host.features.apps.zed-editor.enable = false;
  };
}
