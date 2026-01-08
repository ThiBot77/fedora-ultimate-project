#!/bin/bash

# GTK Theme Installation Script
# Installs Vanta-Black GTK theme, Papirus icons, and Bibata cursors

echo "🎨 Installing GTK themes..."

# Get the project root directory (3 levels up from the script location)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
THEME_SOURCE="$PROJECT_ROOT/themes/Vanta-Black"

TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Install Vanta-Black GTK Theme (from local themes folder)
echo "📦 Installing Vanta-Black GTK theme..."
if [ ! -d "$HOME/.local/share/themes/Vanta-Black" ]; then
    if [ -d "$THEME_SOURCE" ]; then
        mkdir -p "$HOME/.local/share/themes"
        cp -r "$THEME_SOURCE" "$HOME/.local/share/themes/"
        echo "✅ Vanta-Black GTK theme installed from local source"
    else
        echo "⚠️  Vanta-Black theme not found in $THEME_SOURCE"
    fi
else
    echo "✅ Vanta-Black GTK theme already installed"
fi

cd "$TEMP_DIR"

# Install Papirus Icon Theme
echo "📦 Installing Papirus icon theme..."
if ! [ -d "$HOME/.local/share/icons/Papirus-Dark" ]; then
    wget -qO- https://git.io/papirus-icon-theme-install | DESTDIR="$HOME/.local/share/icons" sh
    echo "✅ Papirus icon theme installed"
else
    echo "✅ Papirus icon theme already installed"
fi

# Install Bibata Cursors
echo "📦 Installing Bibata cursors..."
if [ ! -d "$HOME/.local/share/icons/Bibata-Modern-Ice" ]; then
    cd "$TEMP_DIR"
    wget https://github.com/ful1e5/Bibata_Cursor/releases/latest/download/Bibata-Modern-Ice.tar.xz
    mkdir -p "$HOME/.local/share/icons"
    tar -xf Bibata-Modern-Ice.tar.xz -C "$HOME/.local/share/icons/"
    echo "✅ Bibata cursors installed"
else
    echo "✅ Bibata cursors already installed"
fi

# Cleanup
cd ~
rm -rf "$TEMP_DIR"

echo ""
echo "✅ GTK themes installation complete!"
echo ""
echo "Theme applied:"
echo "  - GTK: Vanta-Black"
echo "  - Icons: Papirus Dark"
echo "  - Cursor: Bibata Modern Ice"
