{
  pkgs,
  modulesPath,
  ...
}:
{
  imports = [
    ./zen-browser
    ./neovim
    ./ghostty
    ./kitty
    ./zed-editor
  ];
}
