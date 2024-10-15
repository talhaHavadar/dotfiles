{ pkgs, device, ... }:
let
  currentSystem = builtins.currentSystem;
in
{
  # Auto upgrade nix package
  services.nix-daemon.enable = true;
  nix.settings.experimental-features = "nix-command flakes";
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
  # nix.package = pkgs.nix;
  imports = [
    ./homebrew.nix
  ];

  environment.systemPackages = with pkgs; [
    coreutils
    vim
  ];

  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "Meslo" ]; })
  ];

  documentation.enable = true;
  programs.bash.enable = true;
  environment.loginShell = pkgs.bash;

  # Set Git commit hash for darwin-version.
  system.configurationRevision = self.rev or self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 5;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = currentSystem;

  system.defaults.finder.AppleShowAllExtensions = true;
  system.defaults.dock.autohide = true;
}
