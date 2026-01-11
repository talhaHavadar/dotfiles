return {
  {
    "nvimtools/none-ls.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local null_ls = require("null-ls")
      local formatting = null_ls.builtins.formatting

      local fgroup = vim.api.nvim_create_augroup("LspFormatting", { clear = true })

      null_ls.setup({
        sources = {
          formatting.nixfmt,
          formatting.black,
          formatting.prettier.with({
            extra_args = { "--no-semi", "--single-quote" },
          }),
          formatting.stylua,
          formatting.yamlfmt,
          formatting.gdformat,
        },
        on_attach = function(client, bufnr)
          if client.supports_method("textDocument/formatting") then
            vim.api.nvim_clear_autocmds({ group = fgroup, buffer = bufnr })
            vim.api.nvim_create_autocmd("BufWritePre", {
              group = fgroup,
              buffer = bufnr,
              callback = function()
                vim.lsp.buf.format({
                  filter = function(c)
                    -- ruff causing conflict with black
                    return c.name ~= "ruff"
                  end,
                })
              end,
            })
          end
        end,
      })
    end,
  },
}
