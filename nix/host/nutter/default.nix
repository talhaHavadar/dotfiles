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

  # power.ups = {
  #   enable = true;
  # };
  # List packages installed in system profile. To search, run:
  # $ nix search wget

  environment.systemPackages = with pkgs; [
    vim
    wget
    git
  ];
}
