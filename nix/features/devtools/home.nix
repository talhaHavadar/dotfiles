{ inputs
, config
, lib
, pkgs
, ...
}:
let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  devtools_config = config.host.features.devtools;
in
{

  config = lib.mkIf devtools_config.enable {
    home.packages =
      with pkgs;
      [
        inputs.sparse.packages.${pkgs.stdenv.hostPlatform.system}.default
        git
        uv
        nodejs_24
        qemu
        dtc
        gh
        openocd
        stripe-cli
        wget
        gperf
        viu
        herdr
      ]
      ++ lib.optionals (!isDarwin) [
        rpi-imager
      ]
      ++ lib.optionals (devtools_config.ai.enable) [
        claude-code
        github-copilot-cli
      ]
      ++ lib.optionals (devtools_config.build-tools.cpp.enable) [
        clang
        cmake
        ninja
        ccache
      ];
  };
}
