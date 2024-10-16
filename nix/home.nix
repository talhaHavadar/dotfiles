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
  host.home.applications.neovim.enable = true;

  imports =
    [
      ./terminal.nix
      ./git.nix
      ./tmux.nix
    ]
    ++ lib.optionals (isPackagingEnabled) [
      ./packaging
    ];

  home.file =
    {
      ".config/starship.toml".source = mkOutOfStoreSymlink ../dot/starship.toml;
      "workspace/.gitconfig".source = mkOutOfStoreSymlink ../dot/gitconfig.workspace;
    }
    // lib.optionalAttrs isPackagingEnabled {
      ".devscripts".source = mkOutOfStoreSymlink ../dot/devscripts;
      ".gbp.conf".source = mkOutOfStoreSymlink ../dot/gbp.conf;
      ".mk-sbuild.rc".source = mkOutOfStoreSymlink ../dot/mk-sbuild.rc;
      ".quiltrc-dpkg".source = mkOutOfStoreSymlink ../dot/quiltrc-dpkg;
      ".sbuildrc".source = mkOutOfStoreSymlink ../dot/sbuildrc;
      ".packaging.bashrc".source = mkOutOfStoreSymlink ../dot/packaging.bashrc;
    };

  home.activation = {
    fzf = lib.hm.dag.entryAfter [ "installPackages" ] ''
      $DRY_RUN_CMD mkdir -p ~/.local/share/bash-completion/completions
      PATH="${pkgs.fzf}/bin:$HOME/.local/bin:$PATH" $DRY_RUN_CMD \
          fzf --bash > ~/.local/share/bash-completion/completions/fzf
    '';
    pipx-poetry = lib.hm.dag.entryAfter [ "installPackages" ] ''
      $DRY_RUN_CMD mkdir -p ~/.local/share/bash-completion/completions
      PATH="${pkgs.pipx}/bin:$HOME/.local/bin:$PATH" $DRY_RUN_CMD pipx install poetry
      PATH="${pkgs.pipx}/bin:$HOME/.local/bin:$PATH" $DRY_RUN_CMD poetry completions \
        bash > ~/.local/share/bash-completion/completions/poetry
    '';
    pipx-black = lib.hm.dag.entryAfter [ "installPackages" ] ''
      PATH="${pkgs.pipx}/bin:$HOME/.local/bin:$PATH" $DRY_RUN_CMD pipx install black
    '';
  };
  home.packages = with pkgs; [
    curl
    rustup
    cargo-deb
    stylua
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

}
