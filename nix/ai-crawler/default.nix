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
    sshpass
    yt-dlp
    nodejs_24
    jq
    chromium
  ];
}
