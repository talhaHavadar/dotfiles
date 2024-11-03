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
    opengl.enable = true;
    # pulseaudio.enable = true;
    bluetooth.enable = true;
  };

  users.users.benis = {
    isNormalUser = true;
    initialPassword = "benis";
    extraGroups = [
      "wheel"
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
  programs.ssh.startAgent = true;
  environment.systemPackages = with pkgs; [
    coreutils
    wget
    vim
    libnotify
    git
    pamixer
    blueman
    networkmanagerapplet
    swaynotificationcenter
  ];

  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "Meslo" ]; })
  ];

  documentation.enable = true;

  programs.gnupg.agent = {
    enable = true;
  };
}
