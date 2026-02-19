return {
	{
		"williamboman/mason.nvim",
		build = ":MasonUpdate",
		config = true,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "williamboman/mason.nvim" },
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"lua_ls",
					"html",
					"ruff",
					"gopls",
					"yamlls",
					"ts_ls",
					"rust_analyzer",
					"taplo",
					"zls",
				},
				automatic_installation = true,
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"b0o/schemastore.nvim",
		},
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			-- Diagnostic settings
			vim.diagnostic.config({
				virtual_text = false,
				virtual_lines = { current_line = true },
			})

			-- LSP keymaps
			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(args)
					local opts = { buffer = args.buf, silent = true }
					vim.keymap.set("n", "gr", vim.lsp.buf.rename, opts)
					vim.keymap.set("n", "ga", vim.lsp.buf.code_action, opts)
					vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
					vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
					vim.keymap.set("n", "gD", vim.lsp.buf.references, opts)
					vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
					vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, opts)
					vim.keymap.set("i", "<C-r>", vim.lsp.buf.rename, opts)
				end,
			})

			-- Server configs using new vim.lsp.config API (Neovim 0.11+)
			local servers = {
				"lua_ls",
				"html",
				"ruff",
				"gopls",
				"ts_ls",
				"rust_analyzer",
				"taplo",
				"zls",
				"gdscript",
				"sourcekit",
			}

			for _, server in ipairs(servers) do
				vim.lsp.config(server, {
					capabilities = capabilities,
				})
			end

			-- YAML with schemastore (special config)
			vim.lsp.config("yamlls", {
				capabilities = capabilities,
				settings = {
					yaml = {
						format = {
							enable = false,
						},
						schemaStore = {
							enable = false,
							url = "",
						},
						schemas = require("schemastore").yaml.schemas(),
					},
				},
			})

			vim.lsp.config("lua_ls", {
				settings = {
					Lua = {
						diagnostics = {
							globals = { "vim" },
						},
					},
				},
			})

			-- Enable all servers
			vim.lsp.enable(servers)
			vim.lsp.enable("yamlls")
		end,
	},
	{
		"danymat/neogen",
		cmd = "Neogen",
		keys = {
			{ "gnc", "<cmd>Neogen<cr>", desc = "Generate annotation" },
		},
		config = true,
	},
	{
		"j-hui/fidget.nvim",
		event = "LspAttach",
		config = true,
	},
	{
		"b0o/schemastore.nvim",
		lazy = true,
	},
}
