{ config
, lib
, pkgs
, ...
}:
let
  debian_packaging_config = config.host.features.debian-packaging;
in
{
  config = lib.mkIf debian_packaging_config.enable { };
}
