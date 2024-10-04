#!/bin/env bash
set -x

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--with-packaging)
            INCLUDE_PACKAGING="true"
            ;;
        *)
            echo "Unknown argument $1"
            ;;
    esac
    shift
done

! command -v rustup     2>&1 >/dev/null && curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
! command -v zoxide     2>&1 >/dev/null && curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
! command -v starship   2>&1 >/dev/null && curl -sS https://starship.rs/install.sh | sh

packaging_related_apt_tools=()
if [ "$INCLUDE_PACKAGING" = "true" ]; then
    packaging_related_apt_tools=(
        sbuild
        ubuntu-dev-tools
        apt-cacher-ng
        autopkgtest
        lintian
        git-buildpackage
        )

fi

sudo add-apt-repository ppa:neovim-ppa/stable

sudo apt install fzf neovim ripgrep tmux git cmake build-essential tio \
    mtools gcc-arm-none-eabi dosfstools python3-venv python3-dev pipx \
    "${packaging_related_apt_tools[@]}"

pipx install poetry
pipx install black
poetry completions bash >> ~/.bash_completion

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

. "$HOME/.cargo/env"

cargo install cargo-deb
cargo install stylua

if [ "$INCLUDE_PACKAGING" = "true" ]; then
    sudo adduser $USER sbuild

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

. $SCRIPT_DIR/.packaging.bashrc

EOF

    source $SCRIPT_DIR/.packaging.bashrc

    setup-packaging-environment
fi

source ~/.bashrc

if [ "$DOTFILES_BASH_SOURCED" = "true" ];

    tee -a ~/.bashrc <<EOF

. $SCRIPT_DIR/.bashrc

EOF
    . $SCRIPT_DIR/.bashrc

fi



