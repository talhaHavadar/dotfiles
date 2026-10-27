{ config
, lib
, pkgs
, inputs
, ...
}:
let
  home_config = config.host.features.apps.neovim;
in
with lib;
{
  imports = [
  ];

  config = mkIf home_config.enable {
    home.packages = with pkgs; [
      neovim
      tree-sitter
      mbake
      rustup
      gopls
      go
      nixfmt
    ];
  };

}
