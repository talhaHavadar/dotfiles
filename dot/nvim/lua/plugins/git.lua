return {
	{
		"sindrets/diffview.nvim",
		cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles" },
		config = true,
	},
	{
		"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup({
				current_line_blame = true,
			})
			local keymap = vim.keymap.set

			keymap("n", "<leader>gh", "<cmd>Gitsigns preview_hunk_inline<CR>")
		end,
	},
}
