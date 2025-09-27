let
  gnupg = "2.4.7";
  claude-code = "1.0.119";
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
    (final: prev: {
      claude-code = prev.claude-code.overrideAttrs (oldAttrs: {
        version = claude-code;
        src = prev.fetchurl {
          url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${claude-code}.tgz";
          sha256 = "sha256-xAqdGLJrJVPGyhrYZen8iNCSbSLa76iodxjhQnCQp6Q=";
        };
      });
    })
  ];
}
