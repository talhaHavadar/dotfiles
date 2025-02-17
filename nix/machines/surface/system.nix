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
    ];

    # udev rules for legacy sdwire
    extraRules = ''
      SUBSYSTEM=="usb", ATTRS{idVendor}=="04e8", ATTRS{idProduct}=="6001", MODE="0666", GROUP="dialout"
    '';
  };

  users.users.benis = {
    isNormalUser = true;
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
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILkzdb7RdgSlGfBePdpnBmbT+7hjpyhrL5y5QhlDIAh5 talhahavadar@hotmail.com"
    ];

  };
  programs.regreet.enable = true;
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd Hyprland";
        #command = "${pkgs.greetd.regreet}/bin/regreet";
        user = "greeter";
      };
    };
  };

  networking.networkmanager.enable = true;
  networking.hostName = "surface";
  services.openssh.enable = true;
  programs.ssh.startAgent = true;
  programs.dconf = {
    enable = true;
  };
  environment.systemPackages = with pkgs; [
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
  ];

  virtualisation.lxd.enable = true;
  virtualisation.lxc.lxcfs.enable = true;
  fonts.packages = with pkgs; [
    font-awesome
    noto-fonts
    noto-fonts-extra
    noto-fonts-emoji
    powerline-fonts
    powerline-symbols
    (nerdfonts.override { fonts = [ "Meslo" ]; })
  ];

  documentation.enable = true;

  programs.gnupg.agent = {
    enable = true;
  };
}
