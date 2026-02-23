require("mason").setup({})
require("mason-lspconfig").setup({
    ensure_installed = {
        "lua_ls",
        "html",
        "ruff",
        "gopls",
        "yamlls",
        "clangd",
        "rust_analyzer",
        "taplo",
        "zls",
        "bashls",
        "efm",
        "pyright",
    },
    automatic_installation = true,
})

require('mason-tool-installer').setup {
    ensure_installed = {
        "prettierd",
        "eslint_d",
        "shellcheck",
        "shfmt",
        "fixjson",
        "checkmake",
        "mbake",
    },
}

-- ============================================================================
-- LSP, Linting, Formatting & Completion
-- ============================================================================

local diagnostic_signs = {
    Error = " ",
    Warn = " ",
    Hint = "",
    Info = "",
}

vim.diagnostic.config({
    virtual_text = { prefix = "●", spacing = 4 },
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = diagnostic_signs.Error,
            [vim.diagnostic.severity.WARN] = diagnostic_signs.Warn,
            [vim.diagnostic.severity.INFO] = diagnostic_signs.Info,
            [vim.diagnostic.severity.HINT] = diagnostic_signs.Hint,
        },
    },
    underline = true,
    update_in_insert = false,
    severity_sort = true,
    float = {
        border = "rounded",
        source = "always",
        header = "",
        prefix = "",
        focusable = false,
        style = "minimal",
    },
})

do
    local orig = vim.lsp.util.open_floating_preview
    function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
        opts = opts or {}
        opts.border = opts.border or "rounded"
        return orig(contents, syntax, opts, ...)
    end
end

local function lsp_on_attach(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client then
        return
    end




    local bufnr = ev.buf
    local opts = { noremap = true, silent = true, buffer = bufnr }

    vim.keymap.set("n", "<leader>gd", function()
        require("fzf-lua").lsp_definitions({ jump_to_single_result = true })
    end, opts)

    vim.keymap.set("n", "<leader>gD", vim.lsp.buf.definition, opts)

    vim.keymap.set("n", "<leader>gS", function()
        vim.cmd("vsplit")
        vim.lsp.buf.definition()
    end, opts)

    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

    vim.keymap.set("n", "<leader>D", function()
        vim.diagnostic.open_float({ scope = "line" })
    end, opts)
    vim.keymap.set("n", "<leader>d", function()
        vim.diagnostic.open_float({ scope = "cursor" })
    end, opts)
    vim.keymap.set("n", "<leader>nd", function()
        vim.diagnostic.jump({ count = 1 })
    end, opts)

    vim.keymap.set("n", "<leader>pd", function()
        vim.diagnostic.jump({ count = -1 })
    end, opts)

    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)

    vim.keymap.set("n", "<leader>fd", function()
        require("fzf-lua").lsp_definitions({ jump_to_single_result = true })
    end, opts)
    vim.keymap.set("n", "<leader>fr", function()
        require("fzf-lua").lsp_references()
    end, opts)
    vim.keymap.set("n", "<leader>ft", function()
        require("fzf-lua").lsp_typedefs()
    end, opts)
    vim.keymap.set("n", "<leader>fs", function()
        require("fzf-lua").lsp_document_symbols()
    end, opts)
    vim.keymap.set("n", "<leader>fw", function()
        require("fzf-lua").lsp_workspace_symbols()
    end, opts)
    vim.keymap.set("n", "<leader>fi", function()
        require("fzf-lua").lsp_implementations()
    end, opts)

    if client:supports_method("textDocument/codeAction", bufnr) then
        vim.keymap.set("n", "<leader>oi", function()
            vim.lsp.buf.code_action({
                context = { only = { "source.organizeImports" }, diagnostics = {} },
                apply = true,
                bufnr = bufnr,
            })
            vim.defer_fn(function()
                vim.lsp.buf.format({ bufnr = bufnr })
            end, 50)
        end, opts)
    end
end

vim.api.nvim_create_autocmd("LspAttach", { group = augroup, callback = lsp_on_attach })

vim.keymap.set("n", "<leader>q", function()
    vim.diagnostic.setloclist({ open = true })
end, { desc = "Open diagnostic list" })
vim.keymap.set("n", "<leader>dl", vim.diagnostic.open_float, { desc = "Show line diagnostics" })

vim.lsp.config("lua_ls", {
    settings = {
        Lua = {
            diagnostics = { globals = { "vim" } },
            telemetry = { enable = false },
        },
    },
})
vim.lsp.config("ruff", {})
vim.lsp.config("bashls", {})
vim.lsp.config("gopls", {})
vim.lsp.config("clangd", {})
vim.lsp.config("zls", {})
vim.lsp.config("pyright", {})

vim.lsp.enable({
    "lua_ls",
    "html",
    "ruff",
    "gopls",
    "yamlls",
    "clangd",
    "rust_analyzer",
    "taplo",
    "zls",
    "bashls",
    "efm",
    "pyright",
})
