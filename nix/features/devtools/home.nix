{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
let
  isDarwin = pkgs.stdenv.isDarwin;
  devtools_config = config.host.features.devtools;
in
{

  config = lib.mkIf devtools_config.enable {
    home.packages =
      with pkgs;
      [
        inputs.sparse.packages.${system}.default
        git
        uv
        go
        zig
        nodejs_24
        qemu
        dtc
        gh
        openocd
        stripe-cli
        wget
        gperf
        viu
        github-copilot-cli
      ]
      ++ lib.optionals (!isDarwin) [
        rpi-imager
      ]
      ++ lib.optionals (devtools_config.ai.enable) [
        claude-code
      ]
      ++ lib.optionals (devtools_config.build-tools.cpp.enable) [
        cmake
        ninja
        ccache
      ];
  };
}
