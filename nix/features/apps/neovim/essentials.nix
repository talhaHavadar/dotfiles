{ pkgs, ... }:
{
  plugins = {
    trouble = {
      enable = true;
      settings = {
        auto_preview = true;
        auto_refresh = false;
        indent_guides = true;
        preview = {
          scratch = true;
          type = "main";
        };
      };
    };
    lint.enable = true;
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
        gdscript
        zig
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
        "<C-p>" = "git_files";
        "<leader>fg" = "live_grep";
        "<C-f>" = "grep_string";
      };
      extensions = {
        ui-select.enable = true;
      };
    };
  };
}
