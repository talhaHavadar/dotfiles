{
  config,
  lib,
  pkgs,
  currentConfigSystem ? "",
  ...
}@args:
let
  # Determine which module to import based on context
  isHomeManager = currentConfigSystem == "home";
in
if isHomeManager then import ./home.nix args else import ./system.nix args
