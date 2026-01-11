return {
  -- Surround
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    config = true,
  },

  -- Auto pairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = true,
  },

  -- Undo tree
  {
    "mbbill/undotree",
    keys = {
      { "<C-h>", "<cmd>UndotreeToggle<cr><cmd>UndotreeFocus<cr>", desc = "Toggle undotree" },
    },
  },

  -- Trouble (diagnostics)
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    keys = {
      { "<leader>tt", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics" },
      { "<leader>tq", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix" },
    },
    opts = {
      auto_preview = true,
      auto_refresh = true,
      indent_guides = true,
      preview = {
        scratch = true,
        type = "main",
      },
    },
  },

  -- Comments
  {
    "numToStr/Comment.nvim",
    event = "VeryLazy",
    config = true,
  },

  -- Cloak (hide secrets)
  {
    "laytan/cloak.nvim",
    event = "VeryLazy",
    opts = {
      enabled = true,
      cloak_character = "*",
      cloak_length = nil,
      cloak_telescope = true,
      patterns = {
        {
          cloak_pattern = "=.+",
          replace = nil,
          file_pattern = { ".env*", "Rocket.toml" },
        },
      },
    },
  },

  -- Linter
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = {
        swift = { "swiftlint" },
      }
      vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter" }, {
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },
}
