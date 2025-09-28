{
  config,
  lib,
  pkgs,
  currentConfigSystem ? "",
  ...
}@args:
let
  # Determine which module to import based on context
  isNixos = lib.hasPrefix "nixos" currentConfigSystem;
  isDarwin = currentConfigSystem == "darwin";
  isHome = currentConfigSystem == "home";
in
(import ./options.nix args)
// (
  if isDarwin then
    import ./darwin.nix args
  else if isNixos then
    import ./nixos.nix args
  else if isHome then
    import ./home.nix args
  else
    import ./InvalidConfigSystem
)
