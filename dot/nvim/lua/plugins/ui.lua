return {
  -- Colorscheme
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "frappe",
        integrations = {
          cmp = true,
          gitsigns = true,
          treesitter = true,
          fidget = true,
          mason = true,
          telescope = true,
          barbar = true,
        },
        term_colors = true,
      })
      vim.cmd.colorscheme("catppuccin")
    end,
  },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "dracula",
        },
      })
    end,
  },

  -- Bufferline
  {
    "romgrk/barbar.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    init = function()
      vim.g.barbar_auto_setup = false
    end,
    keys = {
      { "<Tab><Tab>", "<cmd>BufferNext<cr>", desc = "Next buffer" },
      { "<Tab>p", "<cmd>BufferPrevious<cr>", desc = "Previous buffer" },
      { "<Tab>c", "<cmd>BufferClose<cr>", desc = "Close buffer" },
    },
    opts = {},
  },

  -- Icons
  {
    "nvim-tree/nvim-web-devicons",
    lazy = true,
  },
}
