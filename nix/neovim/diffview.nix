{
  config,
  options,
  pkgs,
  lib,
  ...
}:
let
  neovim_option = config.host.home.applications.neovim;
  diffview_option = config.host.home.applications.neovim.diffview;
in
{
  config = lib.mkIf (neovim_option.enable && diffview_option.enable) {
    programs.nixvim = {
      keymaps = [
        # {
        #   mode = "n";
        #   key = "<leader>cc";
        #   action = "<CMD>ClaudeCode<CR>";
        # }
        # {
        #   mode = "t";
        #   key = "<C-t><C-t>";
        #   action = "<CMD>ClaudeCode<CR>";
        # }
      ];
      plugins = {
        diffview = {
          enable = true;
        };
      };
    };
  };
}
