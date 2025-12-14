{
  config,
  options,
  pkgs,
  lib,
  ...
}:
let
  neovim_option = config.host.features.apps.neovim;
in
{
  config = lib.mkIf (neovim_option.enable) {
    programs.nixvim = {
      keymaps = [
      ];
      plugins = {
        conform-nvim = {
          enable = true;
          settings = {
            # formatters = {
            #   swiftformat = {
            #     command = lib.getExe pkgs.swiftformat;
            #   };
            # };
            formatters_by_ft = {
              swift = [ "swiftformat" ];
            };
            format_on_save = ''
              function(bufnr)
                if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
                  return
                end

                return { timeout_ms = 500, lsp_fallback = true }
               end
            '';
          };
        };
        snacks = {
          enable = true;
          settings = {
            image = {
              enabled = true;
            };
          };
        };
        nui = {
          enable = true;
        };
        lint = {
          lintersByFt = {
            swift = [ "swiftlint" ];
          };
        };
      };
    };
  };
}
