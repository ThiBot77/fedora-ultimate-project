#!/bin/bash

# GTK Theme Installation Script
# Installs Catppuccin GTK themes, Papirus icons, and cursors

echo "🎨 Installing GTK themes..."

TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Install Catppuccin GTK Theme
echo "📦 Installing Catppuccin GTK theme..."
if [ ! -d "$HOME/.local/share/themes/Catppuccin-Mocha-Standard-Mauve-Dark" ]; then
    git clone https://github.com/catppuccin/gtk.git catppuccin-gtk
    cd catppuccin-gtk
    mkdir -p "$HOME/.local/share/themes"
    cp -r themes/* "$HOME/.local/share/themes/"
    echo "✅ Catppuccin GTK theme installed"
else
    echo "✅ Catppuccin GTK theme already installed"
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

# Install Catppuccin Cursors
echo "📦 Installing Catppuccin cursors..."
if [ ! -d "$HOME/.local/share/icons/Catppuccin-Mocha-Mauve-Cursors" ]; then
    cd "$TEMP_DIR"
    git clone https://github.com/catppuccin/cursors.git catppuccin-cursors
    cd catppuccin-cursors
    mkdir -p "$HOME/.local/share/icons"
    cp -r cursors/Catppuccin-Mocha-Mauve-Cursors "$HOME/.local/share/icons/"
    echo "✅ Catppuccin cursors installed"
else
    echo "✅ Catppuccin cursors already installed"
fi

# Cleanup
cd ~
rm -rf "$TEMP_DIR"

echo ""
echo "✅ GTK themes installation complete!"
echo ""
echo "Theme applied:"
echo "  - GTK: Catppuccin Mocha Mauve"
echo "  - Icons: Papirus Dark"
echo "  - Cursor: Catppuccin Mocha Mauve"
