{ pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;

  nixpkgs.overlays = [
    (final: prev: {
      claude-code = prev.claude-code.overrideAttrs (oldAttrs: {
        version = "1.0.119";
        src = prev.fetchurl {
          url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-1.0.119.tgz";
          sha256 = "sha256-xAqdGLJrJVPGyhrYZen8iNCSbSLa76iodxjhQnCQp6Q=";
        };
      });
    })
  ];

  networking.hostName = "pi-dev";
  networking.networkmanager.enable = true;

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    EDITOR = "vim";
  };

  security = {
    polkit.enable = true;
  };

  hardware = {
    # graphics.enable = true;
    gpgSmartcards.enable = true;
    ledger.enable = true;
  };

  services.udev = {
    packages = [
    ];

    # udev rules for legacy sdwire
    extraRules = ''
      SUBSYSTEM=="usb", ATTRS{idVendor}=="04e8", ATTRS{idProduct}=="6001", MODE="0666", GROUP="dialout"
    '';
  };

  users.users.talha = {
    initialPassword = "talha";
    isNormalUser = true;
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

  services.openssh.enable = true;
  programs.ssh.startAgent = false;

  programs.dconf = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    gcr
    coreutils
    wget
    vim
    git
    python312
    blueman
    helvum
    lz4
    gnupg
  ];

  # virtualisation.lxd = {
  #   enable = true;
  #   zfsSupport = true;
  #   recommendedSysctlSettings = true;
  # };
  # networking.firewall.interfaces.lxdbr0.allowedTCPPorts = [ 53 ];
  # networking.firewall.interfaces.lxdbr0.allowedUDPPorts = [
  #   53
  #   67
  # ];
  # virtualisation.lxc = {
  #   enable = true;
  #   lxcfs.enable = true;
  #   defaultConfig = ''
  #     lxc.include = ${pkgs.lxcfs}/share/lxc/config/common.conf.d/00-lxcfs.conf
  #   '';
  # };

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
    pinentryPackage = pkgs.pinentry-curses;
  };
}
