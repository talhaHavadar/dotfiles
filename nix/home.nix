{
  config,
  lib,
  pkgs,
  specialArgs,
  ...
}:
let
  pyp = pkgs.python312Packages;
  isPackagingEnabled = (builtins.getEnv "INCLUDE_PACKAGING") == "true";
  mkOutOfStoreSymlink = config.lib.file.mkOutOfStoreSymlink;
in
{
  imports =
    [
      ./terminal.nix
      ./git.nix
      ./tmux.nix
    ]
    ++ lib.optionals (isPackagingEnabled) [
      ./packaging
    ];

  home.file = {
    "workspace/.gitconfig".source = mkOutOfStoreSymlink ../dot/gitconfig.workspace;
  };

  home.packages = with pkgs; [
    rustup
    cargo-deb
    tmux
    fzf
    ripgrep
    git
    cmake
    gcc13Stdenv
    tio
    mtools
    gcc-arm-embedded-13
    dosfstools
    ubuntu_font_family
    (nerdfonts.override {
      fonts = [
        "DroidSansMono"
        "Hack"
        "JetBrainsMono"
        "Noto"
      ];
    })
    pyp.pipx
  ];

  host.home.applications.neovim.enable = true;
}
