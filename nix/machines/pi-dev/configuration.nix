{ nixos-raspberrypi, ... }:
{
  imports = with nixos-raspberrypi.nixosModules; [
    raspberry-pi-5.base
    raspberry-pi-5.bluetooth
    usb-gadget-ethernet # Configures USB Gadget/Ethernet - Ethernet emulation over USB
  ];

  fileSystems = {
    "/boot/firmware" = {
      device = "/dev/disk/by-id/nvme-Corsair_MP600_CORE_MINI_A7SEB340009OL6_1-part1";
      fsType = "vfat";
      options = [
        "noatime"
        "noauto"
        "x-systemd.automount"
        "x-systemd.idle-timeout=1min"
      ];
    };
    "/" = {
      device = "/dev/disk/by-id/nvme-Corsair_MP600_CORE_MINI_A7SEB340009OL6_1-part2";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  system.stateVersion = "25.05";
}
