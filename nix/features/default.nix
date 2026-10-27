{
  lib,
  pkgs,
  modulesPath,
  currentConfigSystem ? "nothome",
  ...
}:
let
  isHome = currentConfigSystem == "home";
in
{

  imports = [
    ./aerospace
    ./apps
    ./bash-integration
    ./debian-packaging
    ./devtools
    ./tailscale
    ./yubikey
  ]
  ++ lib.optionals (!isHome) [ { nixpkgs.overlays = import ../overlays; } ];
}
