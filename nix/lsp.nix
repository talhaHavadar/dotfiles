{ pkgs, ... }:
{
  plugins = {
    none-ls = {
      enable = true;
      sources = {
        formatting = {
          nixfmt = {
            enable = true;
            package = pkgs.nixfmt-rfc-style;
          };
          black.enable = true;
          prettier = {
            enable = true;
            disableTsServerFormatter = true;
            settings = ''
              {
                  extra_args = { "--no-semi", "--single-quote" },
              }
            '';
          };
          stylua.enable = true;
          yamlfmt.enable = true;
        };
      };
      settings.on_attach = ''
        function(client, buffer)
            vim.api.nvim_clear_autocmds({ group = fgroup, buffer = bufnr })
            vim.api.nvim_create_autocmd("BufWritePre", {
                group = fgroup,
                buffer = bufnr,
                callback = function()
                    vim.lsp.buf.format()
                end,
            })
        end
      '';
    };
    lsp = {
      enable = true;
      servers = {
        lua_ls.enable = true;
        html.enable = true;
        jedi_language_server.enable = true;
        gopls.enable = true;
        yamlls.enable = true;
        ts_ls.enable = true;
        rust_analyzer.enable = true;
        taplo.enable = true;
      };
      keymaps = {
        silent = true;
        lspBuf = {
          K = "hover";
          gD = "references";
          gd = "definition";
          gt = "type_definition";
        };
      };
    };
    schemastore = {
      enable = true;
      yaml.enable = true;
      json.enable = false;
    };
  };

}
