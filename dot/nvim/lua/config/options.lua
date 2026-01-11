local opt = vim.opt

-- Line numbers
opt.nu = true
opt.relativenumber = true

-- Cursor
opt.guicursor = {
  "n-v-c:block-Cursor/lCursor-blinkoff100",
  "i-ci:block-Cursor/lCursor-blinkwait1000-blinkon100-blinkoff100",
  "r:hor50-Cursor/lCursor-blinkwait100-blinkon100-blinkoff100",
}

-- Tabs & indentation
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true

-- Line wrapping
opt.wrap = false

-- Backup & undo
opt.swapfile = false
opt.backup = false
opt.undodir = vim.fn.expand("~/.vim/undodir")
opt.undofile = true

-- Search
opt.hlsearch = false
opt.incsearch = true

-- Appearance
opt.termguicolors = true
opt.scrolloff = 8
opt.signcolumn = "yes"
opt.colorcolumn = "80"

-- Behavior
opt.updatetime = 50
opt.autoread = true

-- List chars (show tabs, trailing spaces)
opt.list = true
opt.listchars = "tab:  ,extends:>,precedes:<,trail:·"

-- Folding (treesitter-based)
opt.foldmethod = "expr"
opt.foldexpr = "nvim_treesitter#foldexpr()"
opt.foldlevel = 99
