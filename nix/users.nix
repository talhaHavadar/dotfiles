{
  config,
  lib,
  pkgs,
  username,
  platform,
  currentConfigSystem,
  ...
}:
let
  pyp = pkgs.python312Packages;
  mkOutOfStoreSymlink = config.lib.file.mkOutOfStoreSymlink;
in
{

  imports = [
    ./home/${username} # user specific configuration
  ];

  config =
    { }
    // lib.optionalAttrs (currentConfigSystem == "home") {
    }
    // lib.optionalAttrs (currentConfigSystem == "darwin") {
    }
    // lib.optionalAttrs (currentConfigSystem == "nixos") {
    };

}
