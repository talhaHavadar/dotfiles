{
  config,
  lib,
  pkgs,
  platform,
  packagingEnabled,
  currentConfigSystem,
  ...
}:
let
  pyp = pkgs.python312Packages;
  mkOutOfStoreSymlink = config.lib.file.mkOutOfStoreSymlink;
in
with lib;
{
  imports = [
    ./git.nix
  ];

  config =
    { }
    // lib.optionalAttrs (currentConfigSystem == "home") {
      home = {
        username = "ubuntu";
        homeDirectory = "/home/ubuntu";
        stateVersion = "24.05";
      };

      home.file = {
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
        ".local/bin/packaging".source = mkOutOfStoreSymlink ../../../dot/bin/packaging/packaging;
        ".local/bin/packaging-get-uploads".source =
          mkOutOfStoreSymlink ../../../dot/bin/packaging/get-uploads;
        ".local/bin/packaging-mk-sbuild".source = mkOutOfStoreSymlink ../../../dot/bin/packaging/mk-sbuild;
        ".local/bin/packaging-convert-symbols".source =
          mkOutOfStoreSymlink ../../../dot/bin/packaging/convert-symbols;
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
    // lib.optionalAttrs (currentConfigSystem == "darwin") {
    }
    // lib.optionalAttrs (currentConfigSystem == "nixos") {
    };

}
