{
  config,
  options,
  pkgs,
  lib,
  ...
}:
let
  neovim_option = config.host.features.apps.neovim;
  claude_code_option = neovim_option.claude-code;
in
{
  config = lib.mkIf (neovim_option.enable && claude_code_option.enable) {
    programs.nixvim = {
      extraPackages = [
        (pkgs.claude-code.overrideAttrs (oldAttrs: {
          version = "1.0.119";
          src = pkgs.fetchurl {
            url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-1.0.119.tgz";
            sha256 = "sha256-xAqdGLJrJVPGyhrYZen8iNCSbSLa76iodxjhQnCQp6Q=";
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
            position = "float",
            enter_insert = true,
            hide_numbers = true,
            hide_signcolumn = true,
          }
        })
      '';
    };
  };
}
