{
  config,
  lib,
  pkgs,
  ...
}:
let
  isPackagingEnabled = (builtins.getEnv "INCLUDE_PACKAGING") == "true";
  mkOutOfStoreSymlink = config.lib.file.mkOutOfStoreSymlink;
  isDarwin = pkgs.stdenv.isDarwin;
  isNixOS = pkgs.stdenv.isLinux && builtins.pathExists /etc/NIXOS;
  isLinuxNonNixOS = pkgs.stdenv.isLinux && !builtins.pathExists /etc/NIXOS;
  isLinux = pkgs.stdenv.isLinux;
  gpgAgentPrefix =
    if isNixOS then
      "/run/user/1002/gnupg" # TODO: need a better way to inject user id here
    else if isDarwin then
      "/Users/benis/.gnupg"
    else
      "/run/user/1000/gnupg";
in
{

  config = {
    home = {
      username = "benis";
      stateVersion = "24.05";
      packages =
        with pkgs;
        [
        ]
        ++ lib.optionals (isDarwin) [
        ]
        ++ lib.optionals (!isDarwin) [
          teams-for-linux
          obsidian
        ];
    }
    // lib.optionalAttrs (isDarwin) {
      homeDirectory = "/Users/benis";
    }
    // lib.optionalAttrs (!isDarwin) {
      homeDirectory = "/home/benis";
    };

    programs.git = {
      enable = true;
      settings = {
        user.name = "Bahanur Enis";
        user.email = "bahanurenis@gmail.com";
        # tag.gpgSign = "true"
        sparse.user.id = "bahanurenis";
        commit.gpgSign = "true";
        log.showSignature = "true";
        rebase.autoSquash = true;
        user.signingkey = "961F36F44EF82483";
      };
    };

    programs.gpg = {
      enable = true;
      scdaemonSettings = {
        pcsc-shared = true;
        #disable-ccid = true;
      };
    };

  };
}
