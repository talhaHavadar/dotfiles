{ pkgs, ... }:
{
  keymaps = [
    {
      mode = "n";
      key = "gnc";
      action = ":lua require('neogen').generate()<CR>";
    }
  ];
  plugins = {
    neogen = {
      enable = true;
    };
    none-ls = {
      enable = true;
      enableLspFormat = false;
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
          dxfmt.enable = true;
          gdformat.enable = true;
        };
      };
      settings.on_attach = ''
        function(client, buffer)
            vim.api.nvim_clear_autocmds({ group = fgroup, buffer = bufnr })
            vim.api.nvim_create_autocmd("BufWritePre", {
                group = fgroup,
                buffer = bufnr,
                callback = function()
                    vim.lsp.buf.format({
                      filter = function(client)
                        -- ruff causing conflict with black
                        return client.name ~= "ruff"
                      end
                    })
                end,
            })
        end
      '';
    };

    # lsp-format = {
    #   enable = true;
    #   lspServersToEnable = [
    #     "ruff"
    #   ];
    # };

    lsp = {
      enable = true;
      servers = {
        sourcekit.enable = true;
        lua_ls.enable = true;
        html.enable = true;
        jedi_language_server.enable = true;
        ruff.enable = true;
        gopls.enable = true;
        yamlls.enable = true;
        ts_ls.enable = true;
        rust_analyzer = {
          enable = true;
          installCargo = false;
          installRustc = false;
        };
        taplo.enable = true;
        gdscript = {
          enable = true;
          package = pkgs.vscode-extensions.geequlim.godot-tools;

        };
      };
      keymaps = {
        silent = true;
        lspBuf = {
          gr = "rename";
          ga = "code_action";
          K = "hover";
          "<C-k>" = "signature_help";
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
