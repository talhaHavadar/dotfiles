{
  lib,
  currentConfigSystem,
  ...
}@args:
let
  isNixos = lib.hasPrefix "nixos" currentConfigSystem;
  isDarwin = currentConfigSystem == "darwin";
  isHome = currentConfigSystem == "home";
in
{
  imports = [
    ../talha
  ]
  ++ (
    if isNixos then
      # PASS we are not using nixos here :(
      [ ]
    else if isDarwin then
      # PASS
      [ ]
    else if isHome then
      [ ]
    else
      throw "Invalid config system: ${currentConfigSystem}"
  );

  # Override username - all other paths derive from this automatically
  config.home.username = lib.mkForce "talha.can.havadar@canonical.com";
}
