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
  mkOutOfStoreSymlink = config.lib.file.mkOutOfStoreSymlink;
in
{
  imports = [
    ./home/${platform}.nix # platform specific configuration [ nixos, non-nixos, macos ]
    ./neovim
    ./terminal.nix
    ./tmux.nix
  ];
  home.file = {
    ".local/bin/git-stack-commits".source = mkOutOfStoreSymlink ../dot/bin/git-stack-commits;
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
    pipx-stack-pr = lib.hm.dag.entryAfter [ "installPackages" ] ''
      PATH="${pkgs.pipx}/bin:$HOME/.local/bin:$PATH" $DRY_RUN_CMD pipx install stack-pr
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
    #rpi-imager
    nerd-fonts.hack
    nerd-fonts.noto
    nerd-fonts.jetbrains-mono
    nerd-fonts.droid-sans-mono
    pyp.pipx
    sd-mux-ctrl
  ];
}
