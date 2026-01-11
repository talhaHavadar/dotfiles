local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Copilot disable group (detach copilot if .copilot file not found in project)
local copilot_group = augroup("copilot-disable", { clear = true })

autocmd("LspAttach", {
  group = copilot_group,
  callback = vim.schedule_wrap(function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.name == "copilot" then
      local copilot_not_wanted = vim.fs.find(".copilot", { upward = true })[1] == nil
      if copilot_not_wanted then
        vim.cmd("Copilot detach")
      end
    end
  end),
})

-- Highlight on yank
local highlight_group = augroup("YankHighlight", { clear = true })
autocmd("TextYankPost", {
  group = highlight_group,
  callback = function()
    vim.highlight.on_yank()
  end,
})
