{
  config,
  lib,
  pkgs,
  username,
  platform,
  ...
}:
let
  pyp = pkgs.python312Packages;
  isPackagingEnabled = (builtins.getEnv "INCLUDE_PACKAGING") == "true";
  mkOutOfStoreSymlink = config.lib.file.mkOutOfStoreSymlink;
in
{

  imports = [
    ./home/${platform}.nix # platform specific configuration [ nixos, non-nixos, macos ]
    ./home/${username} # user specific configuration
    ./neovim
    ./terminal.nix
    ./tmux.nix
  ];

  host.home.applications.neovim.enable = true;
  host.home.applications.kitty.enable = true;
  host.home.windowManagers.hyprland.enable = true;

  home.file = {
    ".config/starship.toml".source = mkOutOfStoreSymlink ../dot/starship.toml;
    ".complete_alias".source = mkOutOfStoreSymlink ../dot/complete_alias;
    ".tmux-completion".source = mkOutOfStoreSymlink ../dot/tmux-completion;
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
    stylua
    tmux
    fzf
    ripgrep
    git
    tio
    dosfstools
    ubuntu-classic
    rpi-imager
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
    sd-mux-ctrl
  ];

}
