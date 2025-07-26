{
  config,
  options,
  pkgs,
  lib,
  ...
}:
let
  neovim_option = config.host.home.applications.neovim;
  claude_code_option = config.host.home.applications.neovim.copilot;
in
{
  config = lib.mkIf (neovim_option.enable && claude_code_option.enable) {
    programs.nixvim = {
      extraPackages = [
        (pkgs.claude-code.overrideAttrs (oldAttrs: {
          version = "1.0.61";
          src = pkgs.fetchurl {
            url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-1.0.61.tgz";
            sha256 = "sha256-CWZMiIFmWGZeSyAfwM25T2Zs6Rr2k4pGdFmN9d7Nx0A=";
          };
        }))
      ];
      extraPlugins = [
        (pkgs.vimUtils.buildVimPlugin {
          name = "claude-code-nvim";
          src = pkgs.fetchFromGitHub {
            owner = "greggh";
            repo = "claude-code.nvim";
            rev = "main";
            sha256 = "sha256-ZEIPutxhgyaAhq+fJw1lTO781IdjTXbjKy5yKgqSLjM=";
          };
        })
        pkgs.vimPlugins.plenary-nvim
      ];
      keymaps = [
        {
          mode = "n";
          key = "<leader>cc";
          action = "<CMD>ClaudeCode<CR>";
        }
        {
          mode = "t";
          key = "<C-t><C-t>";
          action = "<CMD>ClaudeCode<CR>";
        }
      ];
      extraConfigLua = ''
        -- Setup claude-code plugin
        require("claude-code").setup({
          window = {
            split_ratio = 0.3,
            position = "vertical",
            enter_insert = true,
            hide_numbers = true,
            hide_signcolumn = true,
          }
        })
      '';
    };
  };
}
