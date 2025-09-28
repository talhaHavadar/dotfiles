{
  config,
  options,
  pkgs,
  lib,
  ...
}:
let
  neovim_option = config.host.features.apps.neovim;
  diffview_option = config.host.features.apps.neovim.diffview;
in
{
  config = lib.mkIf (neovim_option.enable && diffview_option.enable) {
    programs.nixvim = {
      keymaps = [
      ];
      plugins = {
        diffview = {
          enable = true;
        };
      };
    };
  };
}
