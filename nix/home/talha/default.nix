{
  config,
  lib,
  pkgs,
  platform,
  currentConfigSystem,
  ...
}@args:
let
  # Determine which module to import based on context
  isNixos = lib.hasPrefix "nixos" currentConfigSystem;
  isDarwin = currentConfigSystem == "darwin";
  isHome = currentConfigSystem == "home";
in
{
  imports = [
    ./common.nix
  ] ++ (
    if isNixos then
      [ ./nixos.nix ]
    else if isDarwin then
      [ ./darwin.nix ]
    else if isHome then
      [ ./home.nix ]
    else
      throw "Invalid config system: ${currentConfigSystem}"
  );
}
