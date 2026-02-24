-- ============================================================================
-- PLUGINS (vim.pack)
-- ============================================================================

require("git-fixup").setup({
    commit_limit = 20,
    keymap = "<leader>gf",
})

vim.pack.add({
    "https://www.github.com/nvim-lua/plenary.nvim",
    "https://www.github.com/echasnovski/mini.nvim",
    "https://www.github.com/ibhagwan/fzf-lua",
    "https://www.github.com/nvim-tree/nvim-tree.lua",
    {
        src = "https://github.com/nvim-treesitter/nvim-treesitter",
        branch = "main",
        build = ":TSUpdate",
    },
    -- Language Server Protocols
    "https://www.github.com/neovim/nvim-lspconfig",
    "https://github.com/mason-org/mason.nvim",
    "https://github.com/mason-org/mason-lspconfig.nvim",
    "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim",
    "https://github.com/creativenull/efmls-configs-nvim",
    {
        src = "https://github.com/saghen/blink.cmp",
        version = vim.version.range("1.*"),
    },
    "https://github.com/L3MON4D3/LuaSnip",
    "https://github.com/lewis6991/gitsigns.nvim",
    "https://github.com/NeogitOrg/neogit",
    "https://github.com/sindrets/diffview.nvim",
})
local function packadd(name)
    vim.cmd("packadd " .. name)
end

packadd("neogit")
packadd("gitsigns.nvim")
packadd("diffview.nvim")
packadd("plenary.nvim")
packadd("nvim-treesitter")
packadd("mini.nvim")
packadd("fzf-lua")
packadd("nvim-tree.lua")
-- LSP
packadd("mason.nvim")
packadd("mason-lspconfig.nvim")
packadd("nvim-lspconfig")
packadd("efmls-configs-nvim")
packadd("LuaSnip")
packadd("blink.cmp")

require("settings.fzf")
require("settings.cmp")
require("settings.lsp")

-- ============================================================================
-- PLUGIN CONFIGS
-- ============================================================================

local setup_treesitter = function()
    local treesitter = require("nvim-treesitter")
    treesitter.setup({})
    local ensure_installed = {
        "vim",
        "vimdoc",
        "rust",
        "c",
        "cpp",
        "go",
        "html",
        "css",
        "javascript",
        "json",
        "lua",
        "markdown",
        "python",
        "typescript",
        "vue",
        "svelte",
        "bash",
        "lua",
        "python",
        "zig",
    }

    local config = require("nvim-treesitter.config")

    local already_installed = config.get_installed()
    local parsers_to_install = {}

    for _, parser in ipairs(ensure_installed) do
        if not vim.tbl_contains(already_installed, parser) then
            table.insert(parsers_to_install, parser)
        end
    end

    if #parsers_to_install > 0 then
        treesitter.install(parsers_to_install)
    end

    local group = vim.api.nvim_create_augroup("TreeSitterConfig", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
        group = group,
        callback = function(args)
            if vim.list_contains(treesitter.get_installed(), vim.treesitter.language.get_lang(args.match)) then
                vim.treesitter.start(args.buf)
            end
        end,
    })
end

setup_treesitter()

require("nvim-tree").setup({
    view = {
        width = 35,
    },
    filters = {
        dotfiles = false,
    },
    renderer = {
        group_empty = true,
    },
})
vim.keymap.set("n", "<C-b>", function()
    require("nvim-tree.api").tree.toggle()
end, { desc = "Toggle NvimTree" })

vim.api.nvim_set_hl(0, "NvimTreeNormalNC", { bg = "none" })
vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
vim.api.nvim_set_hl(0, "NvimTreeSignColumn", { bg = "none" })
vim.api.nvim_set_hl(0, "NvimTreeNormal", { bg = "none" })
vim.api.nvim_set_hl(0, "NvimTreeWinSeparator", { fg = "#2a2a2a", bg = "none" })
vim.api.nvim_set_hl(0, "NvimTreeEndOfBuffer", { bg = "none" })

require("mini.ai").setup({})
require("mini.comment").setup({})
require("mini.move").setup({})
require("mini.surround").setup({})
require("mini.cursorword").setup({})
require("mini.indentscope").setup({})
require("mini.pairs").setup({})
require("mini.trailspace").setup({})
require("mini.bufremove").setup({})
require("mini.notify").setup({})
require("mini.icons").setup({})
require("mini.tabline").setup({})


require("settings.terminal")
require("settings.efm-configs")
require("settings.git")
