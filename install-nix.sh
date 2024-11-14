#!/bin/env bash
#set -x

while [ $# -gt 0 ]; do
    case $1 in
        -p|--with-packaging)
            INCLUDE_PACKAGING="true"
            ;;
        -c|--headless)
            HEADLESS_INSTANCE="true"
            ;;
        *)
            echo "Unknown argument $1"
            ;;
    esac
    shift
done

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
    echo "is_macos=$is_macos is_linux=$is_linux"
    if [ -n "$is_macos" ]; then
        echo "Detected a macos system..."
        if ! command -v nix &>/dev/null
        then
            curl -L https://nixos.org/nix/install | sh
        fi
    elif [ -n "$is_linux" ]; then
        echo "Detected a linux system..."
        if ! command -v nix &>/dev/null
        then
            curl -L https://nixos.org/nix/install | sh -s -- --daemon
        fi
    fi
    mkdir -p ~/.config/nix
    ln -s $DOTFILES_DIR/nix.conf ~/.config/nix/nix.conf &>/dev/null
    source /etc/profile
else
    echo "nix is already installed skipping the installation step for nix"
fi

if [ -n "$is_linux" ]; then
    # export NIX_SYSTEM="$(uname -i)-$(uname -s | awk '{print tolower($0)}')"
    if ! command -v home-manager &>/dev/null
    then
        if [ "$HEADLESS_INSTANCE" = "true" ]; then
            INCLUDE_PACKAGING="$INCLUDE_PACKAGING" nix run home-manager -- init --switch "$HOME"/.config/dotfiles/nix#ubuntu-headless --impure -b backup
        else
            INCLUDE_PACKAGING="$INCLUDE_PACKAGING" nix run home-manager -- init --switch "$HOME"/.config/dotfiles/nix#linux --impure -b backup
        fi
    else
        echo "home-manager is already activated so no need for nix run."
        if [ "$HEADLESS_INSTANCE" = "true" ]; then
            INCLUDE_PACKAGING="$INCLUDE_PACKAGING" home-manager init --switch $DOTFILES_DIR/nix#ubuntu-headless --show-trace --impure -b backup
        else
            INCLUDE_PACKAGING="$INCLUDE_PACKAGING" home-manager init --switch $DOTFILES_DIR/nix#linux --show-trace --impure -b backup
        fi
    fi

    if [ "$INCLUDE_PACKAGING" = "true" ]; then
        echo "Packaging tools installation is enabled. Installing packaging tools..."

        packaging_related_apt_tools=(
            sbuild
            ubuntu-dev-tools
            apt-cacher-ng
            autopkgtest
            lintian
            git-buildpackage
            config-package-dev
        )

        sudo apt update
        # https://raw.githubusercontent.com/Yubico/libfido2/refs/heads/main/udev/70-u2f.rules
        sudo apt install swaylock  "${packaging_related_apt_tools[@]}" \
                pcscd sssd libpam-sss scdaemon yubikey-manager libpam-u2f libfido2-dev
        # use pamu2fcfg > ~/.config/Yubico/u2f_keys to setup keys
        # update /etc/pam.d/{sudo,gdm-password,swaylock} with "auth required pam_u2f.so"


        sudo adduser $USER sbuild

        mkdir -p $HOME/sbuild/build
        mkdir -p $HOME/sbuild/log
        mkdir -p $HOME/sbuild/scratch

        sudo tee -a /etc/schroot/sbuild/fstab <<EOF
$HOME/sbuild/scratch  /scratch          none  rw,bind  0  0
EOF

        sudo tee -a /etc/fstab <<EOF
tmpfs		/var/lib/schroot/union/overlay/		tmpfs	defaults	0	0
EOF
        source ~/.packaging.bashrc

        setup-packaging-environment
    fi

    source /etc/profile
    source ~/.profile
    source ~/.bashrc
fi

