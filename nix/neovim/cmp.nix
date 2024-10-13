{ pkgs, ... }:
{

  plugins.friendly-snippets.enable = true;
  plugins.cmp = {
    enable = true;
    autoEnableSources = true;
    settings = {
      sources = [
        { name = "nvim_lsp"; }
        { name = "buffer"; }
        { name = "crates"; }
        { name = "luasnip"; }
      ];
      snippet = {
        expand = "luasnip";
      };
      window = {
        completion = {
          border = "solid";
        };
        documentation = {
          border = "solid";
        };
      };
      mapping = {
        "<esc>" = "cmp.mapping.abort()";
        "<CR>" = "cmp.mapping.confirm({ select = true })";
        "<C-Space>" = "cmp.mapping.complete()";
        "<C-a>" = "cmp.mapping.scroll_docs(-4)";
        "<C-z>" = "cmp.mapping.scroll_docs(4)";
        "<Up>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
        "<Down>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
      };
    };
  };
}
