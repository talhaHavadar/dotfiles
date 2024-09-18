#!/bin/env bash

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
curl -sS https://starship.rs/install.sh | sh

sudo add-apt-repository ppa:neovim-ppa/stable

sudo apt install fzf sbuild ubuntu-dev-tools apt-cacher-ng piuparts autopkgtest \
    lintian git-buildpackage neovim ripgrep tmux git cmake build-essential

sudo adduser $USER sbuild

git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

sudo tee -a /etc/fstab <<EOF
tmpfs		/var/lib/schroot/union/overlay/		tmpfs	defaults	0	0
EOF
