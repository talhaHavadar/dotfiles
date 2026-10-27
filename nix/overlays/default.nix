let
  gnupg = "2.4.7";
  claude-code = "2.1.2";
  # Plain list of overlays, shared by NixOS/Darwin (nixpkgs.overlays) and
  # standalone home-manager (see flake.nix).
  # keep this magic handy
  #hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
in
[
  (final: prev: {
    ppa-dev-tools = final.callPackage ../pkgs/ppa-dev-tools.nix { };
  })
]
