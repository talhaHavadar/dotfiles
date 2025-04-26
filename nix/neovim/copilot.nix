{
  config,
  options,
  pkgs,
  lib,
  ...
}:
let
  neovim_option = config.host.home.applications.neovim;
  copilot_option = config.host.home.applications.neovim.copilot;
in
{
  config = lib.mkIf (neovim_option.enable && copilot_option.enable) {
    programs.nixvim = {
      autoGroups.copilot-disable.clear = true;
      autoCmd = [
        {
          event = "LspAttach";
          group = "copilot-disable";
          callback = {
            __raw = ''
              vim.schedule_wrap(function(args)
                local client = vim.lsp.get_client_by_id(args.data.client_id)
                local copilot_not_wanted = vim.fs.find(".copilot", { upward = true })[1] == nil
                if client.name == "copilot" and copilot_not_wanted then
                  vim.cmd("Copilot detach")
                end
              end)
            '';
          };
        }
      ];

      plugins = {
        copilot-cmp = {
          enable = true;
        };
        cmp = {
          enable = true;
          autoEnableSources = true;
          settings = {
            sources = [
              { name = "copilot"; }
            ];
          };
        };
        copilot-chat.enable = true;
        copilot-lua = {
          enable = true;
          settings = {
            copilot_node_command = lib.getExe pkgs.nodejs_20;
            suggestion = {
              enabled = false;
            };
            panel = {
              enabled = false;
            };
          };
        };
      };
    };
  };
}
