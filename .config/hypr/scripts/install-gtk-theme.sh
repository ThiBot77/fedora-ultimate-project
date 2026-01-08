#!/bin/bash

# GTK Theme Installation Script
# Installs Vanta-Black GTK theme, Papirus icons, and Bibata cursors

echo "🎨 Installing GTK themes..."

TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Check if Vanta-Black theme is already installed
echo "📦 Checking Vanta-Black GTK theme..."
if [ -d "$HOME/.local/share/themes/Vanta-Black" ]; then
    echo "✅ Vanta-Black GTK theme already installed"
else
    echo "⚠️  Vanta-Black theme not found - should be installed by main install.sh script"
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

# Apply theme with gsettings
echo "🎨 Applying GTK theme settings..."
gsettings set org.gnome.desktop.interface gtk-theme 'Vanta-Black' 2>/dev/null
gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark' 2>/dev/null
gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Ice' 2>/dev/null
echo "✅ Theme settings applied!"

echo ""
echo "Theme applied:"
echo "  - GTK: Vanta-Black"
echo "  - Icons: Papirus Dark"
echo "  - Cursor: Bibata Modern Ice"
