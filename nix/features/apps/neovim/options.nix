{ lib, ... }:
{
  options = {
    host.features.apps.neovim = {
      enable = lib.mkOption {
        default = false;
        type = lib.types.bool;
        description = "Text editor";
      };
      copilot = {
        enable = lib.mkOption {
          default = false;
          type = lib.types.bool;
          description = "Enable Github Copilot";
        };
      };
      claude-code = {
        enable = lib.mkOption {
          default = false;
          type = lib.types.bool;
          description = "Enable Claude Code";
        };
      };
      diffview = {
        enable = lib.mkOption {
          default = true;
          type = lib.types.bool;
          description = "Enable diffview";
        };
      };
    };
  };
}
