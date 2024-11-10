{ pkgs, ... }:
{

  colorschemes.catppuccin.enable = true;
  colorschemes.catppuccin.settings = {
    flavour = "frappe";
    integrations = {
      cmp = true;
      gitsigns = true;
      treesitter = true;
    };
    term_colors = true;
  };

  plugins = {
    lualine = {
      enable = true;
      settings = {
        theme = "dracula";
      };
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

    vim-surround.enable = true;
    nvim-autopairs.enable = true;

  };

}
