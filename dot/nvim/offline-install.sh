#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "==> Installing nvim offline package..."

# Install binary
echo "==> Installing nvim binary to /usr/local/bin..."
sudo mkdir -p /usr/local/bin
sudo cp "$SCRIPT_DIR/bin/nvim" /usr/local/bin/
sudo chmod +x /usr/local/bin/nvim

# Install runtime (if present)
if [ -d "$SCRIPT_DIR/share/nvim" ]; then
    echo "==> Installing nvim runtime to /usr/local/share..."
    sudo mkdir -p /usr/local/share
    sudo rm -rf /usr/local/share/nvim
    sudo cp -r "$SCRIPT_DIR/share/nvim" /usr/local/share/
fi

# Install user config
echo "==> Installing nvim config to ~/.config/nvim..."
mkdir -p "$HOME/.config"
rm -rf "$HOME/.config/nvim"
cp -r "$SCRIPT_DIR/config" "$HOME/.config/nvim"

# Install user data (plugins, parsers, mason)
echo "==> Installing plugins and data to ~/.local/share/nvim..."
mkdir -p "$HOME/.local/share/nvim"

if [ -d "$SCRIPT_DIR/data/site" ]; then
    rm -rf "$HOME/.local/share/nvim/site"
    cp -r "$SCRIPT_DIR/data/site" "$HOME/.local/share/nvim/"
fi

if [ -d "$SCRIPT_DIR/data/mason" ]; then
    rm -rf "$HOME/.local/share/nvim/mason"
    cp -r "$SCRIPT_DIR/data/mason" "$HOME/.local/share/nvim/"
fi

if [ -f "$SCRIPT_DIR/data/nvim-pack-lock.json" ]; then
    cp "$SCRIPT_DIR/data/nvim-pack-lock.json" "$HOME/.local/share/nvim/"
fi

echo "==> Done! Run 'nvim' to start."
