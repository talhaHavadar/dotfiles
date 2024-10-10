{
  config,
  inputs,
  lib,
  pkgs,
  specialArgs,
  ...
}:
let
  home = config.home;
in
with lib;
{
  imports = [
    inputs.nixvim.homeManagerModules.nixvim
  ];
  config.programs.nixvim = {
    enable = true;
    package = pkgs.neovim-unwrapped;

    imports = [
      ./lsp.nix
      ./cmp.nix
    ];

    opts = {
      nu = true;
      relativenumber = true;
      mouse = "";
      tabstop = 4;
      softtabstop = 4;
      shiftwidth = 4;
      expandtab = true;
      smartindent = true;
      wrap = false;
      swapfile = false;
      backup = false;
      undodir = "${home.homeDirectory}/.vim/undodir";
      undofile = true;
      hlsearch = false;
      incsearch = true;
      termguicolors = true;
      scrolloff = 8;
      signcolumn = "yes";
      updatetime = 50;
      colorcolumn = "80";
      autoread = true;
      list = true;
      listchars = "tab:  ,extends:>,precedes:<,trail:·";
    };
    globals.mapleader = " ";

    keymaps = [
      {
        mode = "n";
        key = "Y";
        action = "yg$";
      }
      {
        mode = "n";
        key = "n";
        action = "nzzzv";
      }
      {
        mode = "n";
        key = "N";
        action = "Nzzzv";
      }
      {
        mode = "v";
        key = "J";
        action = ":m '>+1<CR>gv=gv";
      }
      {
        mode = "v";
        key = "K";
        action = ":m '<-2<CR>gv=gv";
      }
      {
        mode = "n";
        key = "<C-d>";
        action = "<C-d>zz";
      }
      {
        mode = "n";
        key = "<C-u>";
        action = "<C-u>zz";
      }
      {
        mode = "x";
        key = "<leader>p";
        action = "\"_dP";
      }
      {
        mode = "n";
        key = "<leader>s";
        action = ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>";
      }
      {
        mode = "i";
        key = "<C-r>";
        action = "<esc>:%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>";
      }
      {
        mode = "n";
        key = "<leader>x";
        action = "<cmd>!chmod +x %<CR>";
        options = {
          silent = true;
        };
      }

      {
        mode = "n";
        key = "<C-q>n";
        action = "<cmd>cnext<cr>";
      }
      {
        mode = "n";
        key = "<C-q>p";
        action = "<cmd>cprev<cr>";
      }
      {
        mode = "n";
        key = "<C-q>q";
        action = "<cmd>cquit<cr>";
      }
      {
        mode = "n";
        key = "<C-b>";
        action = "<cmd>Ex<cr>";
      }
      {
        mode = "n";
        key = "<C-h>";
        action = "<cmd>UndotreeToggle<cr><cmd>UndotreeFocus<cr>";
      }
      {
        mode = "n";
        key = "<C-p>";
        action.__raw = ''
          function()
              require("telescope.builtin").find_files({ hidden = true, no_ignore = true })
          end
        '';
      }
    ];

    colorschemes.catppuccin.enable = true;
    colorschemes.catppuccin.settings = {
      flavour = "latte";
      integrations = {
        cmp = true;
        gitsigns = true;
        treesitter = true;
      };
      term_colors = true;
    };

    plugins = {
      lazy.enable = true;
      commentary.enable = true;
      lualine.enable = true;
      fidget.enable = true;
      lualine.settings = {
        theme = "dracula";
      };

      cloak = {
        enable = true;
        settings = {
          enabled = true;
          cloak_character = "*";
          cloak_length = null;
          cloak_telescope = true;
          patterns = [
            {
              cloak_pattern = "=.+";
              replace = null;
              file_pattern = [
                ".env*"
                "Rocket.toml"
              ];
            }
          ];
        };
      };

      undotree.enable = true;
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

      web-devicons.enable = true;
      barbar = {
        enable = true;
        keymaps = {
          next = {
            mode = "n";
            key = "<Tab><Tab>";
          };
          previous = {
            mode = "n";
            key = "<Tab>p";
          };
          close = {
            mode = "n";
            key = "<Tab>c";
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

      vim-surround.enable = true;
      nvim-autopairs.enable = true;

    };

  };
}
