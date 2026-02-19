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
			keymap("n", "<leader>ga", "<cmd>Gitsigns stage_buffer<CR>")
			keymap("n", "<leader>gsh", "<cmd>Gitsigns stage_hunk<cr>")
			keymap("n", "<leader>guh", "<cmd>Gitsigns undo_stage_hunk<cr>")
			keymap("v", "<leader>gsh", "<cmd>Gitsigns stage_hunk<CR>")
		end,
	},
	{
		"NeogitOrg/neogit",
		lazy = true,
		dependencies = {
			"nvim-lua/plenary.nvim", -- required
			"sindrets/diffview.nvim", -- optional
			"folke/snacks.nvim", -- optional
		},
		cmd = "Neogit",
		keys = {
			{ "<leader>gg", "<cmd>Neogit<cr>", desc = "Show Neogit UI" },
		},
	},
	{
		dir = vim.fn.stdpath("config") .. "/lua/git-fixup",
		name = "git-fixup",
		dependencies = { "nvim-telescope/telescope.nvim" },
		config = function()
			require("git-fixup").setup({
				commit_limit = 20,
				keymap = "<leader>gf",
			})
		end,
	},
}
