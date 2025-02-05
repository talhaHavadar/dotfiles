{
  config,
  lib,
  pkgs,
  platform,
  ...
}:
let
  pyp = pkgs.python312Packages;
  isPackagingEnabled = (builtins.getEnv "INCLUDE_PACKAGING") == "true";
  mkOutOfStoreSymlink = config.lib.file.mkOutOfStoreSymlink;
in
with lib;
{
  home = {
    username = "talha";
    homeDirectory = "/Users/talha";
    stateVersion = "24.05";
  };

  programs.ssh = {
    enable = true;
    extraConfig = ''
      Host dev-amd64-unlock
        User root
        Port 2222
        HostName dev-amd64.lan
    '';
  };

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

  home.packages =
    with pkgs;
    [
      pass
      #      gcc13Stdenv
      #      mtools
      #      gcc-arm-embedded-13
    ]
    ++ optionals (platform != "macos") [
      gnome.gvfs
    ];

  # programs.waybar = {
  #   settings = {
  #     mainBar = {
  #       "custom/lock".on-click = mkForce "sh -c '(sleep 0.5s; swaylock)' & disown";
  #     };
  #   };
  # };

  # wayland.windowManager.hyprland.settings = {
  #   "$screenlocker" = mkForce "swaylock";
  # };
}
