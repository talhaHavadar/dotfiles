local prettier_d = require("efmls-configs.formatters.prettier_d")
local eslint_d = require("efmls-configs.linters.eslint_d")

local fixjson = require("efmls-configs.formatters.fixjson")

local shellcheck = require("efmls-configs.linters.shellcheck")
local shfmt = require("efmls-configs.formatters.shfmt")

local checkmake = require("efmls-configs.linters.checkmake")
local mbake = require("settings.efm-configs.formatters.mbake")

vim.lsp.config("efm", {
    init_options = { documentFormatting = true },
    settings = {
        languages = {
            css = { prettier_d },
            html = { prettier_d },
            javascript = { eslint_d, prettier_d },
            javascriptreact = { eslint_d, prettier_d },
            json = { eslint_d, fixjson },
            jsonc = { eslint_d, fixjson },
            markdown = { prettier_d },
            sh = { shellcheck, shfmt },
            typescript = { eslint_d, prettier_d },
            typescriptreact = { eslint_d, prettier_d },
            vue = { eslint_d, prettier_d },
            svelte = { eslint_d, prettier_d },
            make = {
                checkmake,
                mbake,
            }
        },
    },
})
