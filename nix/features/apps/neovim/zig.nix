{ pkgs, ... }:
{

  plugins = {
    zig.enable = true;
    lsp = {
      enable = true;
      servers = {
        zls.enable = true;
      };
    };
  };

}
