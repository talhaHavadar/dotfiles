-- Metadata
-- languages: make
-- url: https://github.com/EbodShojaei/bake

local sourceText = require('efmls-configs.utils').sourceText
local fs = require('efmls-configs.fs')

local formatter = 'mbake'
local command =
    string.format('%s format --stdin', fs.executable(formatter))

return {
    prefix = formatter,
    formatSource = sourceText(formatter),
    formatCommand = command,
    formatStdin = true,
    rootMarkers = {},
}
