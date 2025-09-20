{
  config,
  lib,
  pkgs,
  ...
}:
{
  networking.hostName = "ai-crawler";

  imports = [
  ];

  environment.systemPackages = with pkgs; [
  ];
}
