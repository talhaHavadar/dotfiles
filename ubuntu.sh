set -ex

packages=(
    sbuild
    ubuntu-dev-tools
    apt-cacher-ng
    autopkgtest
    lintian
    git-buildpackage
    config-package-dev
    lxc-templates
    dh-sequence-gir
    pcscd
    sssd
    libpam-sss
    scdaemon
    yubikey-manager
    libpam-u2f
# https://raw.githubusercontent.com/Yubico/libfido2/refs/heads/main/udev/70-u2f.rules
    libfido2-dev
    python3-venv
    btop
    tree
    ripgrep
    flatpak
)

snaps=(
    "ghostty --classic"
    glow
    "git-ubuntu --classic"
    lxd
    "snapcraft --classic"
    "rustup --classic"
)

for snap in "${snaps[@]}"; do
	sudo snap install ${snap}
done

sudo apt update -y
sudo apt install -y "${packages[@]}"
# use pamu2fcfg > ~/.config/Yubico/u2f_keys to setup keys
# update /etc/pam.d/{sudo,gdm-password,swaylock} with "auth required pam_u2f.so"

flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

sudo adduser $USER sbuild

mkdir -p $HOME/sbuild/build
mkdir -p $HOME/sbuild/logs
mkdir -p $HOME/sbuild/scratch

source ~/.packaging.bashrc

setup-packaging-environment

source /etc/profile
source ~/.profile
source ~/.bashrc

