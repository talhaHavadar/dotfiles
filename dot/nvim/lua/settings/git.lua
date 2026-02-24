require("neogit").setup({})
vim.keymap.set("n", "<leader>gg", "<cmd>Neogit<cr>", { desc = "Open Neogit UI" })

require("gitsigns").setup({
    signs = {
        add = { text = "\u{2590}" },          -- ▏
        change = { text = "\u{2590}" },       -- ▐
        delete = { text = "\u{2590}" },       -- ◦
        topdelete = { text = "\u{25e6}" },    -- ◦
        changedelete = { text = "\u{25cf}" }, -- ●
        untracked = { text = "\u{25cb}" },    -- ○
    },
    signcolumn = true,
    current_line_blame = true,
})

vim.keymap.set("n", "<leader>gh", "<cmd>Gitsigns preview_hunk_inline<CR>")
vim.keymap.set("n", "<leader>ga", "<cmd>Gitsigns stage_buffer<CR>")
vim.keymap.set("n", "<leader>gsh", "<cmd>Gitsigns stage_hunk<cr>")
vim.keymap.set("n", "<leader>guh", "<cmd>Gitsigns undo_stage_hunk<cr>")
vim.keymap.set("v", "<leader>gsh", "<cmd>Gitsigns stage_hunk<CR>")
