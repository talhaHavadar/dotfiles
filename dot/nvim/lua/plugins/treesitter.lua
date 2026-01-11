return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
        ensure_installed = {
            "lua",
            "javascript",
            "yaml",
            "c",
            "html",
            "rust",
            "bash",
            "css",
            "go",
            "nix",
            "make",
            "markdown",
            "perl",
            "python",
            "svelte",
            "toml",
            "gdscript",
            "zig",
            "swift",
        },
        highlight = {
            enable = true,
        },
        indent = {
            enable = true,
        },
    },
}
