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
  home =
    {
      username = "talha";
      stateVersion = "24.05";
      file =
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

      sessionVariables =
        {
          TERM = "xterm-256color";
        }
        // optionalAttrs (platform == "macos") {
          PATH = "/opt/homebrew/opt/python/libexec/bin:$PATH";
        }
        // optionalAttrs (platform != "macos") {
          GIO_EXTRA_MODULES = "${pkgs.gvfs}/lib/gio/modules";
        };
      packages =
        with pkgs;
        [
          pass
          obsidian
          yazi
        ]
        ++ optionals (platform != "macos") [
          gnome.gvfs
          mtools
          obs-studio
          godot
          mattermost-desktop
        ];

    }
    // optionalAttrs (platform == "macos") {
      homeDirectory = "/Users/talha";
    }
    // optionalAttrs (platform != "macos") {
      homeDirectory = "/home/talha";
    };

  imports = [
    ./git.nix
  ];

  programs =
    {
      ssh = {
        enable = true;
        extraConfig = ''
          Host dev-amd64-unlock
            User root
            Port 2222
            HostName dev-amd64.lan
        '';
      };
    }
    // optionalAttrs (platform != "macos") {
      waybar = {
        settings = {
          mainBar = {
            "custom/lock".on-click = mkForce "sh -c '(sleep 0.5s; swaylock)' & disown";
          };
        };
      };
    };

  wayland =
    { }
    // optionalAttrs (platform != "macos") {
      windowManager.hyprland.settings = {
        "$screenlocker" = mkForce "swaylock";
      };
    };
}
