{
  config,
  lib,
  pkgs,
  username,
  platform,
  currentConfigSystem,
  ...
}:
let
  yubikey_config = config.host.yubikey;
  pyp = pkgs.python312Packages;
  mkOutOfStoreSymlink = config.lib.file.mkOutOfStoreSymlink;
in
{
  options = {
    host.yubikey = {
      enable = lib.mkOption {
        default = false;
        type = with lib.types; bool;
        description = "FIDO Key";
      };
    };
  };

  imports = [
  ];

  config =
    { }
    // lib.mkIf (yubikey_config.enable && currentConfigSystem == "home") {

    }
    // lib.mkIf (yubikey_config.enable && currentConfigSystem == "darwin") {
    }
    // lib.mkIf (yubikey_config.enable && lib.hasPrefix "nixos" currentConfigSystem) {
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
