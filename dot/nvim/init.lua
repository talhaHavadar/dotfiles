package.path = package.path .. ";" .. vim.fn.stdpath("config") .. "/?.lua"

-- Use a writable location for the lock file (Nix store is read-only)
vim.g.pack_lockfile = vim.fn.stdpath("data") .. "/nvim-pack-lock.json"

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.termguicolors = true

local function set_transparent() -- set UI component to transparent
    local groups = {
        "Normal",
        "NormalNC",
        "EndOfBuffer",
        "NormalFloat",
        "FloatBorder",
        "SignColumn",
        "StatusLine",
        "StatusLineNC",
        "TabLine",
        "TabLineFill",
        "TabLineSel",
        "ColorColumn",
    }
    for _, g in ipairs(groups) do
        vim.api.nvim_set_hl(0, g, { bg = "none" })
    end
    vim.api.nvim_set_hl(0, "TabLineFill", { bg = "none", fg = "#767676" })
end

set_transparent()

-- ============================================================================
-- AUTOCMDS
-- ============================================================================

local augroup = vim.api.nvim_create_augroup("UserConfig", { clear = true })

-- Markdown constructs that must not be re-wrapped
local nowrap_nodes = {
    fenced_code_block = true,
    indented_code_block = true,
    pipe_table = true,
    html_block = true,
    atx_heading = true,
    setext_heading = true,
    link_reference_definition = true,
    minus_metadata = true,
    plus_metadata = true,
}

local function is_nowrap_line(buf, row, line)
    local col = #(line:match("^%s*") or "")
    local ok, node = pcall(vim.treesitter.get_node, { bufnr = buf, pos = { row, col } })
    if not ok then
        return false
    end
    while node do
        if nowrap_nodes[node:type()] then
            return true
        end
        node = node:parent()
    end
    return false
end

-- Hard-wrap lines longer than 'textwidth' (only buffers that auto-wrap text)
local function wrap_long_lines(buf)
    local tw = vim.bo[buf].textwidth
    if tw <= 0 or not vim.bo[buf].formatoptions:find("t", 1, true) then
        return
    end

    local is_markdown = vim.bo[buf].filetype == "markdown"
    if is_markdown then
        local ok, parser = pcall(vim.treesitter.get_parser, buf, "markdown")
        if ok and parser then
            pcall(parser.parse, parser)
        end
    end

    local rows = {}
    for i, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
        if vim.fn.strdisplaywidth(line) > tw and not (is_markdown and is_nowrap_line(buf, i - 1, line)) then
            table.insert(rows, i)
        end
    end
    if #rows == 0 then
        return
    end

    vim.api.nvim_buf_call(buf, function()
        local view = vim.fn.winsaveview()
        for i = #rows, 1, -1 do                     -- bottom-up so earlier line numbers stay valid
            vim.api.nvim_win_set_cursor(0, { rows[i], 0 })
            vim.cmd("silent keepjumps normal! gww") -- gw ignores formatexpr/formatprg
        end
        vim.fn.winrestview(view)
    end)
end

-- Format on save
vim.api.nvim_create_autocmd("BufWritePre", {
    group = augroup,
    callback = function(args)
        -- avoid formatting non-file buffers (helps prevent weird write prompts)
        if vim.bo[args.buf].buftype ~= "" then
            return
        end
        if not vim.bo[args.buf].modifiable then
            return
        end
        if vim.api.nvim_buf_get_name(args.buf) == "" then
            return
        end

        local ft = vim.bo[args.buf].filetype
        if ft == "markdown" or ft == "text" then
            pcall(wrap_long_lines, args.buf) -- before any formatter runs
        end

        pcall(vim.lsp.buf.format, {
            bufnr = args.buf,
            timeout_ms = 2000,
        })
    end,
})

-- highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
    group = augroup,
    callback = function()
        vim.hl.on_yank()
    end,
})

-- return to last cursor position
vim.api.nvim_create_autocmd("BufReadPost", {
    group = augroup,
    desc = "Restore last cursor position",
    callback = function()
        if vim.o.diff then -- except in diff mode
            return
        end

        local last_pos = vim.api.nvim_buf_get_mark(0, '"') -- {line, col}
        local last_line = vim.api.nvim_buf_line_count(0)

        local row = last_pos[1]
        if row < 1 or row > last_line then
            return
        end

        pcall(vim.api.nvim_win_set_cursor, 0, last_pos)
    end,
})

-- wrap, linebreak and spellcheck on markdown and text files
vim.api.nvim_create_autocmd("FileType", {
    group = augroup,
    pattern = { "markdown", "text", "gitcommit" },
    callback = function()
        vim.opt_local.wrap = true
        vim.opt_local.linebreak = true
        vim.opt_local.spell = true
    end,
})

-- hard-wrap at 80 columns while typing in markdown and text files
vim.api.nvim_create_autocmd("FileType", {
    group = augroup,
    pattern = { "markdown", "text" },
    callback = function()
        vim.opt_local.textwidth = 80
        vim.opt_local.formatoptions:append("t")
    end,
})

require("options")
require("status-line")
require("keymaps")
require("settings")
