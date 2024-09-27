#!/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
curl -sS https://starship.rs/install.sh | sh

sudo add-apt-repository ppa:neovim-ppa/stable

sudo apt install fzf sbuild ubuntu-dev-tools apt-cacher-ng autopkgtest \
    lintian git-buildpackage neovim ripgrep tmux git cmake build-essential tio \
    mtools gcc-arm-none-eabi dosfstools python3-venv python3-dev

sudo adduser $USER sbuild

# configure tmux
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
ln -s $SCRIPT_DIR/.tmux.conf ~/.tmux.conf

# configure git
ln -s $SCRIPT_DIR/.gitconfig ~/.gitconfig
mkdir -p ~/workspace
mkdir -p ~/projects
ln -s $SCRIPT_DIR/.gitconfig.workspace ~/workspace/.gitconfig

# configure nvim
git clone git@github.com:talhaHavadar/nvim-config.git nvim
mv ~/.config/nvim ~/.config/nvim.bak
ln -s $SCRIPT_DIR/nvim ~/.config/nvim

# configure packaging tools
ln -s $SCRIPT_DIR/.devscripts ~/.devscripts
ln -s $SCRIPT_DIR/.gbp.conf ~/.gbp.conf
ln -s $SCRIPT_DIR/.mk-sbuild.rc ~/.mk-sbuild.rc
ln -s $SCRIPT_DIR/.quiltrc-dpkg ~/.quiltrc-dpkg
ln -s $SCRIPT_DIR/.sbuildrc ~/.sbuildrc

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

source ~/.bashrc

cargo install cargo-deb

setup-packaging-environment

