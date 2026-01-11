return {
	{
		"nvim-telescope/telescope.nvim",
		branch = "master",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope-ui-select.nvim",
		},
		keys = {
			{ "<C-p>", "<cmd>Telescope git_files<cr>", desc = "Git files" },
			{ "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
			{ "<C-f>", "<cmd>Telescope grep_string<cr>", desc = "Grep string" },
		},
		config = function()
			local telescope = require("telescope")
			telescope.setup({
				defaults = {
					file_ignore_patterns = {
						"^.git/",
						"node_modules",
						"target",
						"^.mypy_cache/",
						"^__pycache__/",
						"^output/",
						"^data/",
						"%.ipynb",
					},
				},
			})
			telescope.load_extension("ui-select")
		end,
	},
}
