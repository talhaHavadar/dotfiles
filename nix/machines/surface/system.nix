{ pkgs, ... }:
{
  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "x86_64-linux";

  nixpkgs.config.allowUnfree = true;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  security = {
    polkit.enable = true;
    pam.services.hyprlock = { };
  };

  services.pipewire = {
    enable = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;
  };
  hardware = {
    graphics.enable = true;
    gpgSmartcards.enable = true;
    ledger.enable = true;
    bluetooth = {
      enable = true;
      # settings = {
      #   General = {
      #     Name = "Hello";
      #     ControllerMode = "dual";
      #     FastConnectable = "true";
      #     Experimental = "true";
      #   };
      #   Policy = {
      #     AutoEnable = true;
      #   };
      # };
    };
  };

  services.pcscd.enable = true;
  services.udev = {
    packages = [
      pkgs.yubikey-personalization
      pkgs.iptsd
      pkgs.surface-control
    ];

    # udev rules for legacy sdwire
    extraRules = ''
      SUBSYSTEM=="usb", ATTRS{idVendor}=="04e8", ATTRS{idProduct}=="6001", MODE="0666", GROUP="dialout"
    '';
  };

  users.users = {
    talha = {
      isNormalUser = true;
      hashedPasswordFile = "/etc/talhapw";
      initialPassword = "talha";
      extraGroups = [
        "wheel"
        "dialout"
        "networkmanager"
        "sound"
        "audio"
        "video"
        "render"
        "input"
        "tty"
        "lxd"
      ];

      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILkzdb7RdgSlGfBePdpnBmbT+7hjpyhrL5y5QhlDIAh5 talhahavadar@hotmail.com"
      ];

    };
    benis = {
      isNormalUser = true;
      hashedPasswordFile = "/etc/benispw";
      initialPassword = "benis";
      extraGroups = [
        "wheel"
        "dialout"
        "networkmanager"
        "sound"
        "audio"
        "video"
        "render"
        "input"
        "tty"
        "lxd"
      ];

      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILkzdb7RdgSlGfBePdpnBmbT+7hjpyhrL5y5QhlDIAh5 talhahavadar@hotmail.com"
      ];

    };
  };
  programs.regreet.enable = true;
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd Hyprland";
        user = "greeter";
      };
    };
  };

  networking.networkmanager.enable = true;
  networking.hostName = "surface";
  services.openssh.enable = true;
  programs.ssh.startAgent = false;
  programs.dconf = {
    enable = true;
  };
  environment.systemPackages = with pkgs; [
    iptsd
    coreutils
    wget
    vim
    libnotify
    git
    python312
    pamixer
    blueman
    networkmanagerapplet
    swaynotificationcenter
    helvum
    nwg-look
    yaru-theme
    lz4
    yubikey-personalization
  ];

  virtualisation.lxd = {
    enable = true;
    zfsSupport = true;
    recommendedSysctlSettings = true;
    # preseed = {
    #   networks = [
    #     {
    #       name = "lxdbr0";
    #       type = "bridge";
    #       config = {
    #         "ipv4.address" = "10.0.100.1/24";
    #         "ipv4.nat" = "true";
    #       };
    #     }
    #   ];
    #   profiles = [
    #     {
    #       name = "default";
    #       devices = {
    #         eth0 = {
    #           name = "eth0";
    #           network = "lxdbr0";
    #           type = "nic";
    #         };
    #         root = {
    #           path = "/";
    #           pool = "default";
    #           size = "35GiB";
    #           type = "disk";
    #         };
    #       };
    #     }
    #   ];
    #   storage_pools = [
    #     {
    #       name = "default";
    #       driver = "btrfs";
    #       config = {
    #         source = "/var/lib/lxd/storage-pools/default";
    #       };
    #     }
    #   ];
    # };
  };
  # networking.firewall.interfaces."lxdbr*".allowedTCPPorts = [ 53 ];
  # networking.firewall.interfaces."lxdbr*".allowedUDPPorts = [
  #   53
  #   67
  # ];
  networking.firewall.interfaces.lxdbr0.allowedTCPPorts = [ 53 ];
  networking.firewall.interfaces.lxdbr0.allowedUDPPorts = [
    53
    67
  ];
  virtualisation.lxc = {
    enable = true;
    lxcfs.enable = true;
    defaultConfig = ''
      lxc.include = ${pkgs.lxcfs}/share/lxc/config/common.conf.d/00-lxcfs.conf
    '';
  };

  fonts.packages = with pkgs; [
    font-awesome
    noto-fonts
    noto-fonts-extra
    noto-fonts-emoji
    powerline-fonts
    powerline-symbols
    nerd-fonts.meslo-lg
  ];

  documentation.enable = true;

  programs.gnupg.agent = {
    enable = true;
    enableExtraSocket = true;
    enableSSHSupport = true;
  };
  services.iptsd.enable = true;
  services.iptsd.config = {
    Touchscreen.DisableOnStylus = true;
    Touchscreen.DisableOnPalm = true;

  };
}
