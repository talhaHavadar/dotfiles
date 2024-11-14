{
  config,
  lib,
  pkgs,
  username,
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

  # imports = [
  #   ../hyprland.nix
  # ];

  programs.ssh = {
    enable = true;
    extraConfig = ''
      Include ~/.orbstack/ssh/config
      IdentityFile ~/.ssh/id_ed25519_sk_mobil
    '';
  };

  home.packages = with pkgs; [
    gnupg
    yubikey-manager
    #yubioath-flutter
  ];
  # home.activation = {
  #   link-apps = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
  #     new_nix_apps="${config.home.homeDirectory}/Applications/Nix"
  #     rm -rf "$new_nix_apps"
  #     mkdir -p "$new_nix_apps"
  #     find -H -L "$genProfilePath/home-files/Applications" -name "*.app" -type d -print | while read -r app; do
  #       real_app=$(readlink -f "$app")
  #       app_name=$(basename "$app")
  #       target_app="$new_nix_apps/$app_name"
  #       echo "Alias '$real_app' to '$target_app'"
  #       ${pkgs.mkalias}/bin/mkalias "$real_app" "$target_app"
  #     done
  #   '';
  # };
}
