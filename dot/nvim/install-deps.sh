#!/usr/bin/env bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Detect OS
detect_os() {
    case "$(uname -s)" in
        Darwin*) echo "macos" ;;
        Linux*)  echo "linux" ;;
        *)       echo "unknown" ;;
    esac
}

# Detect Linux distro
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
    else
        echo "unknown"
    fi
}

# Check if command exists
has_cmd() {
    command -v "$1" &>/dev/null
}

# Install Homebrew packages (macOS)
install_macos() {
    if ! has_cmd brew; then
        error "Homebrew not found. Install it from https://brew.sh"
        exit 1
    fi

    info "Installing macOS dependencies via Homebrew..."

    # Core tools
    local brew_packages=(
        # Formatters (for none-ls)
        "nixfmt"
        "black"
        "prettier"
        "stylua"
        "yamlfmt"

        # Swift development
        "swiftlint"
        "swiftformat"
        "xcode-build-server"
        "coreutils"

        # LSP servers (optional - mason can install these too)
        # "lua-language-server"
        # "gopls"
        # "rust-analyzer"
        # "typescript-language-server"
        # "yaml-language-server"
    )

    for pkg in "${brew_packages[@]}"; do
        if brew list "$pkg" &>/dev/null; then
            info "$pkg already installed"
        else
            info "Installing $pkg..."
            brew install "$pkg" || warn "Failed to install $pkg"
        fi
    done

    # xcp is a cask or might need tap
    if ! has_cmd xcp; then
        info "Installing xcp..."
        brew install xcp || warn "Failed to install xcp"
    fi

    # Python tools via pipx (preferred) or pip
    install_python_tools
}

# Install on Debian/Ubuntu
install_debian() {
    info "Installing Debian/Ubuntu dependencies..."

    sudo apt-get update

    local apt_packages=(
        "black"
        "coreutils"
    )

    for pkg in "${apt_packages[@]}"; do
        info "Installing $pkg..."
        sudo apt-get install -y "$pkg" || warn "Failed to install $pkg"
    done

    # Install via npm
    install_npm_tools

    # Install via pip/pipx
    install_python_tools

    # Install other tools
    install_from_source
}

# Install on Fedora
install_fedora() {
    info "Installing Fedora dependencies..."

    local dnf_packages=(
        "python3-black"
        "coreutils"
    )

    for pkg in "${dnf_packages[@]}"; do
        info "Installing $pkg..."
        sudo dnf install -y "$pkg" || warn "Failed to install $pkg"
    done

    install_npm_tools
    install_python_tools
    install_from_source
}

# Install on Arch
install_arch() {
    info "Installing Arch dependencies..."

    local pacman_packages=(
        "python-black"
        "stylua"
        "prettier"
        "coreutils"
        "yamlfmt"
    )

    for pkg in "${pacman_packages[@]}"; do
        info "Installing $pkg..."
        sudo pacman -S --noconfirm "$pkg" || warn "Failed to install $pkg"
    done

    install_python_tools
    install_from_source
}

# Install npm-based tools
install_npm_tools() {
    if ! has_cmd npm; then
        warn "npm not found, skipping npm-based tools (prettier)"
        return
    fi

    info "Installing npm-based tools..."

    local npm_packages=(
        "prettier"
    )

    for pkg in "${npm_packages[@]}"; do
        if has_cmd "$pkg"; then
            info "$pkg already installed"
        else
            info "Installing $pkg..."
            npm install -g "$pkg" || warn "Failed to install $pkg"
        fi
    done
}

# Install Python-based tools
install_python_tools() {
    # Prefer pipx for isolated environments
    if has_cmd pipx; then
        info "Installing Python tools via pipx..."
        pipx install black 2>/dev/null || true
    elif has_cmd pip3; then
        info "Installing Python tools via pip3..."
        pip3 install --user black || warn "Failed to install black"
    else
        warn "Neither pipx nor pip3 found, skipping Python tools"
    fi

    # GDScript formatter (gdtoolkit)
    if has_cmd pipx; then
        pipx install gdtoolkit 2>/dev/null || warn "gdtoolkit not available"
    elif has_cmd pip3; then
        pip3 install --user gdtoolkit || warn "Failed to install gdtoolkit"
    fi
}

# Install tools from source or other methods
install_from_source() {
    # stylua
    if ! has_cmd stylua; then
        if has_cmd cargo; then
            info "Installing stylua via cargo..."
            cargo install stylua || warn "Failed to install stylua"
        else
            warn "cargo not found, skipping stylua"
        fi
    fi

    # nixfmt (if nix is available)
    if ! has_cmd nixfmt && has_cmd nix-env; then
        info "Installing nixfmt via nix..."
        nix-env -iA nixpkgs.nixfmt || warn "Failed to install nixfmt"
    fi
}

# Main
main() {
    local os=$(detect_os)

    info "Detected OS: $os"
    info "Installing neovim config dependencies..."
    echo

    case "$os" in
        macos)
            install_macos
            ;;
        linux)
            local distro=$(detect_distro)
            info "Detected distro: $distro"
            case "$distro" in
                ubuntu|debian|pop)
                    install_debian
                    ;;
                fedora|rhel|centos)
                    install_fedora
                    ;;
                arch|manjaro|endeavouros)
                    install_arch
                    ;;
                *)
                    warn "Unknown distro: $distro"
                    warn "Installing common tools only..."
                    install_npm_tools
                    install_python_tools
                    install_from_source
                    ;;
            esac
            ;;
        *)
            error "Unknown OS: $os"
            exit 1
            ;;
    esac

    echo
    info "Done! Note: LSP servers will be installed automatically by Mason when you open neovim."
    info "Run :Mason in neovim to see installed servers."
}

main "$@"
