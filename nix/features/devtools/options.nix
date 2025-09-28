{ lib, ... }:
{
  options = {
    host.features.devtools = {
      enable = lib.mkOption {
        default = false;
        type = with lib.types; bool;
        description = "Tool chains and development tools for software engineering";
      };
      ai = {
        enable = lib.mkOption {
          default = true;
          type = with lib.types; bool;
          description = "Enable AI related devtools";
        };
      };
      build-tools = {
        cpp = {
          enable = lib.mkOption {
            default = true;
            type = with lib.types; bool;
            description = "Enable C/C++ focused build tools like CMake, Ninja, etc.";
          };
        };
      };
    };
  };
}
