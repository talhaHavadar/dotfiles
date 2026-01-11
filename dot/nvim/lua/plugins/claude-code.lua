return {
  {
    "greggh/claude-code.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>cc", "<cmd>ClaudeCode<cr>", mode = "n", desc = "Open Claude Code" },
      { "<C-t><C-t>", "<cmd>ClaudeCode<cr>", mode = "t", desc = "Toggle Claude Code" },
    },
    config = function()
      require("claude-code").setup({
        window = {
          split_ratio = 0.3,
          position = "float",
          enter_insert = true,
          hide_numbers = true,
          hide_signcolumn = true,
        },
      })
    end,
  },
}
