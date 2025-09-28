{ lib, ... }:
{
  options = {
    host.features.apps.zed-editor = {
      enable = lib.mkOption {
        default = false;
        type = with lib.types; bool;
        description = "High-performance, multiplayer code editor from creators of Atom and Tree-sitter";
      };
    };
  };
}
