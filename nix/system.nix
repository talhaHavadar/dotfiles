{ pkgs, device, ... }:
let
  currentSystem = builtins.currentSystem;
in
{
  # Auto upgrade nix package
  services.nix-daemon.enable = true;
  nix.settings.experimental-features = "nix-command flakes";
  # nix.package = pkgs.nix;

  environment.systemPackages = [
    pkgs.vim
  ];

  documentation.enable = false;
  programs.bash.enable = true;

  # Set Git commit hash for darwin-version.
  system.configurationRevision = self.rev or self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 5;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = currentSystem;

}
