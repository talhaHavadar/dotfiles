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
    ./apps
    ./aerospace
    ./yubikey
    ./tailscale
    ./devtools
  ]
  ++ (if !isHome then [ ../overlays ] else [ ]);
}
