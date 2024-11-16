{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports =
    [
    ];

  time.timeZone = "Europe/Amsterdam";

  networking.hostName = "nutter"; # Define your hostname.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.talha = {
    isNormalUser = true;
    initialPassword = "talha";
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  };

  users.groups.nut.name = "nut";
  users.users.watcher = {
    group = "nut";
    isNormalUser = true;
    isSystemUser = false;
    createHome = true;
    home = "/var/lib/nut";
    hashedPassword = "$y$j9T$17hd7uG6Fy5t6eKlg76uz/$zPmSH6YLQjcYC28ebpyZQlLf8uXF6xBlBQdBbkkN9Y6";
  };

  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTRS{idVendor}=="1cb0", ATTRS{idProduct}=="0038", MODE="664", GROUP="nut", OWNER="watcher"
  '';

  power.ups = {
    enable = true;
    mode = "netserver";
    openFirewall = true;
    users = {
      watcher = {
        passwordFile = "/home/talha/nut_user";
        upsmon = "primary";
      };
    };
    ups = {
      main = {
        driver = "usbhid-ups";
        port = "auto";
        description = "Main UPS";
      };
    };
    upsmon = {
      enable = true;
      monitor = {
        main = {
          powerValue = 1;
          user = "watcher";
          type = "primary";
        };
      };
      settings = {
        MINSUPPLIES = 1;
        RUN_AS_USER = lib.mkForce "watcher";
      };
    };
    upsd = {
      enable = true;
      listen = [
        {
          address = "0.0.0.0";
          port = 3493;
        }
      ];
    };
  };
  # List packages installed in system profile. To search, run:
  # $ nix search wget

  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    usbutils
  ];
}
