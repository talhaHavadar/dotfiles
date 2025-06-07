let
  gnupg = "2.4.7";
in
{
  # keep this magic handy
  #hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

  nixpkgs.overlays = [
    (final: prev: {
      gnupg = prev.gnupg.overrideAttrs (old: {
        version = gnupg;
        src = prev.fetchurl {
          url = "https://gnupg.org/ftp/gcrypt/gnupg/gnupg-${gnupg}.tar.bz2";
          hash = "sha256-eyRwbk2n4OOwbKBoIxAnQB8jgQLEHJCWMTSdzDuF60Y=";
        };
      });
    })
  ];
}
