{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
with lib;
{
  home.packages = [
    pkgs.cowsay
  ];
}
