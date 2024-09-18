#!/bin/env bash

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
curl -sS https://starship.rs/install.sh | sh

sudo add-apt-repository ppa:neovim-ppa/stable

sudo apt install fzf sbuild ubuntu-dev-tools apt-cacher-ng piuparts autopkgtest \
    lintian git-buildpackage neovim ripgrep tmux git cmake build-essential

sudo adduser $USER sbuild

# configure tmux
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
cp .tmux.conf ~/

# configure git
cp .gitconfig ~/
mkdir -p ~/workspace
mkdir -p ~/projects
cp .gitconfig.workspace ~/workspace/.gitconfig

# configure nvim
git clone git@github.com:talhaHavadar/nvim-config.git nvim
mv ~/.config/nvim ~/.config/nvim.bak
ln -s ~/.config/dotfiles/nvim ~/.config/nvim

# configure packaging tools
cp .devscripts ~/
cp .gbp.conf ~/
cp .mk-sbuild.rc ~/
cp .quiltrc-dpkg ~/
cp .sbuildrc ~/

mkdir -p $HOME/sbuild/build
mkdir -p $HOME/sbuild/log
mkdir -p $HOME/sbuild/scratch

sudo tee -a /etc/schroot/sbuild/fstab <<EOF
$HOME/sbuild/scratch  /scratch          none  rw,bind  0  0
EOF

sg sbuild

sudo tee -a /etc/fstab <<EOF
tmpfs		/var/lib/schroot/union/overlay/		tmpfs	defaults	0	0
EOF




tee -a ~/.bashrc <<EOF

. ~/.config/dotfiles/.bashrc

EOF

setup-packaging-environment

