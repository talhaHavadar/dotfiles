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
  #services.udev.extraRules = ''
  #  SUBSYSTEM=="usb", ATTRS{idVendor}=="0463", ATTRS{idProduct}=="ffff", MODE="664", GROUP="nut", OWNER="watcher"
  #'';

  # ups.status OL for online OB for on battery
  environment.etc = {
    "nut/something.dev" = {
      source = /home/talha/eaton_something.dev;
      mode = "0777";
      group = "users";
      user = "watcher";
    };
  };
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
      #main = {
      #  driver = "usbhid-ups";
      #  port = "";
      #  description = "Main UPS";
      #};
      dummy = {
        driver = "dummy-ups";
        port = "something.dev";
        description = "dummy-ups dummy-once mode";
      };
    };
    upsmon = {
      enable = true;
      monitor = {
        #main = {
        #  powerValue = 1;
        #  user = "watcher";
        #  type = "primary";
        #};
        dummy = {
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
        {
          address = "127.0.0.1";
          port = 3493;
        }
      ];
    };
  };
  services.apcupsd = {
    enable = true;
    configText = ''
        UPSTYPE usb
        DEVICE
        BATTERYLEVEL 5
        MINUTES 5
        ONBATTERYDELAY 30
        NISIP 127.0.0.1
        NISPORT 3551
    '';
    hooks = {
      onbattery = ''
        echo "UPS is on battery!!"
        now="$(date -Iseconds)"
        echo "$now" >> /home/talha/upsbattery.log
	sed -i "s/ups.status:.*/ups.status: OB/" /etc/nut/something.dev
        exit 99
      '';
      mainsback = ''
        echo "UPS is on main power!!"
        now="$(date -Iseconds)"
        echo "$now" >> /home/talha/upsmains.log
	sed -i "s/ups.status:.*/ups.status: OL/" /etc/nut/something.dev
        exit 99
      '';
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
