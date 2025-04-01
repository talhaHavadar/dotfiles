{
  config,
  lib,
  pkgs,
  platform,
  packagingEnabled,
  ...
}:
let
  pyp = pkgs.python312Packages;
  mkOutOfStoreSymlink = config.lib.file.mkOutOfStoreSymlink;
in
with lib;
{
  home = {
    username = "ubuntu";
    homeDirectory = "/home/ubuntu";
    stateVersion = "24.05";
  };

  imports = [
    ./git.nix
  ];

  home.file =
    {
      "workspace/.gitconfig".source = mkOutOfStoreSymlink ../../../dot/gitconfig.workspace;
      "projects/.gitconfig".source = mkOutOfStoreSymlink ../../../dot/gitconfig.projects;
    }
    // lib.optionalAttrs packagingEnabled {
      ".devscripts".source = mkOutOfStoreSymlink ../../../dot/devscripts;
      ".gbp.conf".source = mkOutOfStoreSymlink ../../../dot/gbp.conf;
      ".mk-sbuild.rc".source = mkOutOfStoreSymlink ../../../dot/mk-sbuild.rc;
      ".quiltrc-dpkg".source = mkOutOfStoreSymlink ../../../dot/quiltrc-dpkg;
      ".sbuildrc".source = mkOutOfStoreSymlink ../../../dot/sbuildrc;
      ".packaging.bashrc".source = mkOutOfStoreSymlink ../../../dot/packaging.bashrc;
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
