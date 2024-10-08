#!/bin/sh
#set -x

dotfiles_version=`cat ./.version`
echo "Dotfiles version $dotfiles_version"
if [ -d ~/.config/dotfiles ]; then
    config_dotfiles_version=`cat ~/.config/dotfiles/.version`
    if [ "$dotfiles_version" != "$config_dotfiles_version" ]; then
	echo "Make sure you are executing this script from ~/.config/dotfiles"
        exit 1
    fi
else
    echo "There is no ~/.config/dotfiles make sure you cloned the dotfiles repo in ~/.config directory"
    exit 1
fi

cd ~/.config/dotfiles
DOTFILES_DIR=~/.config/dotfiles
nix_version=`which nix`
is_macos=`uname -a | grep Darwin`
is_linux=`uname -a | grep Linux`
if [ -z "$nix_version" ]; then
    if [ -n "$is_macos" -a ! command -v nix ]; then
        echo "Detected a macos system..."
        curl -L https://nixos.org/nix/install | sh
    elif [ -n "$is_linux" -a ! command -v nix ]; then
        echo "Detected a linux system..."
        curl -L https://nixos.org/nix/install | sh -s -- --daemon
    fi
    ln -s $DOTFILES_DIR/nix.conf ~/.config/nix/nix.conf
else
    echo "nix is already installed skipping the installation step for nix"
fi

