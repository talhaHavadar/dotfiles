return {
  -- Conform for Swift formatting
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    opts = {
      formatters_by_ft = {
        swift = { "swiftformat" },
      },
      format_on_save = function(bufnr)
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        return { timeout_ms = 500, lsp_fallback = true }
      end,
    },
  },

  -- Snacks (image support)
  {
    "folke/snacks.nvim",
    lazy = false,
    opts = {
      image = {
        enabled = true,
      },
    },
  },

  -- Nui (UI components)
  {
    "MunifTanjim/nui.nvim",
    lazy = true,
  },
}
