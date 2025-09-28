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
  ];
}
