# Yubikey feature module for NixOS system context
{
  config,
  lib,
  pkgs,
  ...
}:
let
  yubikey_config = config.host.features.yubikey;
in
{
  options = {
    host.features.yubikey = {
      enable = lib.mkOption {
        default = false;
        type = with lib.types; bool;
        description = "FIDO Key support for NixOS";
      };
    };
  };

  config = lib.mkIf yubikey_config.enable {
    environment.systemPackages = with pkgs; [
      yubikey-manager
      opensc
      libfido2
      pcsclite
    ];

    services.pcscd = {
      enable = true;
    };

    # Add udev rules for YubiKey access
    services.udev = {
      packages = [
        pkgs.yubikey-manager
        pkgs.yubikey-personalization
      ];
      extraRules = ''
        # YubiKey rules for direct USB access
        ACTION=="add|change", SUBSYSTEM=="usb", ATTRS{idVendor}=="1050", ATTRS{idProduct}=="0407", MODE="0660", GROUP="wheel", TAG+="uaccess"
        # Generic YubiKey rule
        ACTION=="add|change", SUBSYSTEM=="usb", ATTRS{idVendor}=="1050", MODE="0660", GROUP="wheel", TAG+="uaccess"
      '';
    };
  };
}