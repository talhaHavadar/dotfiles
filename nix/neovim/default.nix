{
  config,
  nixvim,
  lib,
  pkgs,
  specialArgs,
  ...
}:
let
  home_config = config.host.home.applications.neovim;
  home = config.home;
  inputs = specialArgs.inputs;
in
with lib;
{
  imports = [ inputs.nixvim.homeManagerModules.nixvim ];

  options = {
    host.home.applications.neovim = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Text editor";
      };
    };
  };

  config = mkIf home_config.enable {
    programs.nixvim = {
      enable = true;
      package = pkgs.neovim-unwrapped;
      globals.mapleader = " ";

      imports = [
        ./essentials.nix
        ./cosmetics.nix
        ./lsp.nix
        ./cmp.nix
      ];

      opts = {
        nu = true;
        relativenumber = true;
        guicursor = [
          "n-v-c:block-Cursor/lCursor-blinkoff100"
          "i-ci:block-Cursor/lCursor-blinkwait1000-blinkon100-blinkoff100"
          "r:hor50-Cursor/lCursor-blinkwait100-blinkon100-blinkoff100"
        ];
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
    };
  };

}
