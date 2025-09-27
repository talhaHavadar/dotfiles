{
  config,
  lib,
  pkgs,
  currentConfigSystem ? "",
  ...
}@args:
let
  # Determine which module to import based on context
  isDarwin = currentConfigSystem == "darwin";

in
if isDarwin then import ./darwin.nix args else import ./home.nix args
