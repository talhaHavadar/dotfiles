{ pkgs, ... }:
{
  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "x86_64-linux";

  # Auto upgrade nix package
  nix.settings.experimental-features = "nix-command flakes";
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  # programs.hyprland = {
  #   enable = true;
  #   xwayland.enable = true;
  # };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  security = {
    polkit.enable = true;
    pam.services.hyprlock = { };
  };

  hardware = {
    opengl.enable = true;
  };

  networking.networkmanager.enable = true;
  networking.hostName = "surface";
  users.users.benis.extraGroups = [ "networkmanager" ];
  users.users.benis.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILkzdb7RdgSlGfBePdpnBmbT+7hjpyhrL5y5QhlDIAh5 talhahavadar@hotmail.com"
  ];
  services.openssh.enable = true;
  environment.systemPackages = with pkgs; [
    coreutils
    openssh
    vim
    libnotify
  ];

  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "Meslo" ]; })
  ];

  documentation.enable = true;

}
