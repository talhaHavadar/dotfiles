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
  host.home.applications.kitty.enable = true;
  host.home.windowManagers.hyprland.enable = true;

                home = {
                  username= "benis";
                  homeDirectory = "/home/benis";
                  stateVersion = "24.05";
                };
  imports =
    [
      ./neovim
      ./terminal.nix
      # ./git.nix
      ./tmux.nix
      ./hyprland.nix
    ]
    ++ lib.optionals (isPackagingEnabled) [
      ./packaging
    ];

  home.file =
    {
      ".config/starship.toml".source = mkOutOfStoreSymlink ../dot/starship.toml;
      # "workspace/.gitconfig".source = mkOutOfStoreSymlink ../dot/gitconfig.workspace;
      ".complete_alias".source = mkOutOfStoreSymlink ../dot/complete_alias;
      ".tmux-completion".source = mkOutOfStoreSymlink ../dot/tmux-completion;
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
    nixgl.nixGLMesa
    rpi-imager
    curl
    rustup
    stylua
    tmux
    fzf
    ripgrep
    git
    gcc13Stdenv
    tio
    mtools
    gcc-arm-embedded-13
    dosfstools
    ubuntu_font_family
    google-chrome
    (nerdfonts.override {
      fonts = [
        "DroidSansMono"
        "Hack"
        "JetBrainsMono"
        "Noto"
      ];
    })
    pyp.pipx
    (google-chrome.override {
      commandLineArgs = [
        "--ozone-platform=wayland"
        "--enable-features=VaapiVideoDecoder"
        "--use-gl=egl"
      ];
    })

  ];

}
