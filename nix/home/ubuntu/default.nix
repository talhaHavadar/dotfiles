{ config
, lib
, pkgs
, platform
, currentConfigSystem
, ...
}:
let
  pyp = pkgs.python312Packages;
  mkOutOfStoreSymlink = config.lib.file.mkOutOfStoreSymlink;
in
with lib;
{
  config =
    { }
    // lib.optionalAttrs (currentConfigSystem == "home") {
      host.features.debian-packaging.enable = lib.mkDefault ((builtins.getEnv "INCLUDE_PACKAGING") == "1");

      home = {
        username = "ubuntu";
        homeDirectory = "/home/ubuntu";
        stateVersion = "24.05";
      };

      home.file = {
        "workspace/.gitconfig".source = mkOutOfStoreSymlink ../../../dot/gitconfig.workspace;
        "projects/.gitconfig".source = mkOutOfStoreSymlink ../../../dot/gitconfig.projects;
      };

      home.sessionVariables = {
        TERM = "xterm-256color";
      };

      home.packages = with pkgs; [
        gcc13Stdenv
        mtools
        gcc-arm-embedded-13
      ];
    }
    // lib.optionalAttrs (currentConfigSystem == "darwin") { }
    // lib.optionalAttrs (currentConfigSystem == "nixos") { };

}
