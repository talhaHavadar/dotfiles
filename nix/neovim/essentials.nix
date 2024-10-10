{ pkgs, ... }:
{
  plugins = {
    lazy.enable = true;
    commentary.enable = true;
    undotree.enable = true;
    fidget.enable = true;
    treesitter = {
      enable = true;
      grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
        lua
        javascript
        yaml
        c
        html
        rust
        bash
        css
        go
        nix
        make
        markdown
        perl
        python
        svelte
        toml
      ];
      settings = {
        indent.enable = true;
        highlight.enable = true;
        rainbow = {
          enable = true;
          extended_mode = true;
          max_file_lines = null;
        };
      };
    };
    telescope = {
      enable = true;
      settings = {
        defaults = {
          file_ignore_patterns = [
            "^.git/"
            "node_modules"
            "target"
            "^.mypy_cache/"
            "^__pycache__/"
            "^output/"
            "^data/"
            "%.ipynb"
          ];
        };
      };
      keymaps = {
        "<leader>fg" = "live_grep";
        "<C-f>" = "grep_string";
      };
      extensions = {
        ui-select.enable = true;
      };
    };
  };
}
