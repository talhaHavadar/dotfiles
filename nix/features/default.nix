{
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
    ./devtools
    ./tailscale
    ./yubikey
  ]
  ++ (if !isHome then [ ../overlays ] else [ ]);
}
