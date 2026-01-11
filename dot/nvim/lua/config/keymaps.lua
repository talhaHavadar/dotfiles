local keymap = vim.keymap.set

-- Better yank to end of line
keymap("n", "Y", "yg$")

-- Center after search
keymap("n", "n", "nzzzv")
keymap("n", "N", "Nzzzv")

-- Move lines in visual mode
keymap("v", "J", ":m '>+1<CR>gv=gv")
keymap("v", "K", ":m '<-2<CR>gv=gv")

-- Half page jump + center
keymap("n", "<C-d>", "<C-d>zz")
keymap("n", "<C-u>", "<C-u>zz")

-- Paste without overwriting register
keymap("x", "<leader>p", '"_dP')

-- Search and replace word under cursor
keymap("n", "<leader>s", ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>")

-- Make file executable
keymap("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

-- Quickfix navigation
keymap("n", "<C-q>n", "<cmd>cnext<cr>")
keymap("n", "<C-q>p", "<cmd>cprev<cr>")
keymap("n", "<C-q>q", "<cmd>cquit<cr>")

-- File explorer (netrw)
keymap("n", "<C-b>", "<cmd>Ex<cr>")
