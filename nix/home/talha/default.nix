{
  config,
  lib,
  pkgs,
  specialArgs,
  ...
}:
let
  pyp = pkgs.python312Packages;
  isPackagingEnabled = (builtins.getEnv "INCLUDE_PACKAGING") == "true";
  mkOutOfStoreSymlink = config.lib.file.mkOutOfStoreSymlink;
in
with lib;
{
  imports = [
    ./git.nix
  ];

  home.file =
    {
      "workspace/.gitconfig".source = mkOutOfStoreSymlink ../../../dot/gitconfig.workspace;
    }
    // lib.optionalAttrs isPackagingEnabled {
      ".devscripts".source = mkOutOfStoreSymlink ../../../dot/devscripts;
      ".gbp.conf".source = mkOutOfStoreSymlink ../../../dot/gbp.conf;
      ".mk-sbuild.rc".source = mkOutOfStoreSymlink ../../../dot/mk-sbuild.rc;
      ".quiltrc-dpkg".source = mkOutOfStoreSymlink ../../../dot/quiltrc-dpkg;
      ".sbuildrc".source = mkOutOfStoreSymlink ../../../dot/sbuildrc;
      ".packaging.bashrc".source = mkOutOfStoreSymlink ../../../dot/packaging.bashrc;
    };

  home.sessionVariables = {
    GIO_EXTRA_MODULES = "${pkgs.gvfs}/lib/gio/modules";
  };

  home.packages = with pkgs; [
    rpi-imager
    nixgl.nixGLMesa
    gnome.gvfs
    pass
    gcc13Stdenv
    mtools
    gcc-arm-embedded-13
  ];

  programs.waybar = {
    settings = {
      mainBar = {
        "custom/lock".on-click = mkForce "sh -c '(sleep 0.5s; swaylock)' & disown";
      };
    };
  };

  wayland.windowManager.hyprland.settings = {
    "$screenlocker" = mkForce "swaylock";
  };
}
