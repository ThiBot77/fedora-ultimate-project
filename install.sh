#!/bin/bash

# Fedora Hyprland Dotfiles Installation Script
# This script installs all required packages and sets up the dotfiles

echo "======================================"
echo "  Fedora Hyprland Setup Script"
echo "======================================"
echo ""

# Check if running on Fedora
if [ ! -f /etc/fedora-release ]; then
    echo "❌ This script is designed for Fedora Linux"
    exit 1
fi

echo "📦 Installing required packages..."
echo ""

# Update system
sudo dnf update -y

# Install Hyprland and dependencies
sudo dnf install -y \
    hyprland \
    waybar \
    wofi \
    kitty \
    dunst \
    fastfetch \
    polkit-gnome \
    grim \
    slurp \
    wl-clipboard \
    swayidle \
    swaylock \
    xdg-desktop-portal-hyprland \
    qt6ct \
    kvantum \
    pavucontrol \
    network-manager-applet \
    blueman \
    brightnessctl \
    playerctl \
    jq \
    pipewire \
    wireplumber \
    pipewire-alsa \
    pipewire-pulseaudio \
    thunar \
    firefox

# Install fonts
echo ""
echo "📝 Installing fonts..."
sudo dnf install -y \
    jetbrains-mono-fonts \
    google-noto-emoji-fonts \
    fontawesome-fonts

# Install Nerd Fonts
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts

if [ ! -f "JetBrainsMonoNerdFont-Regular.ttf" ]; then
    echo "Downloading JetBrains Mono Nerd Font..."
    wget https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
    unzip -o JetBrainsMono.zip
    rm JetBrainsMono.zip
fi

fc-cache -fv

# Create necessary directories
echo ""
echo "📁 Creating configuration directories..."
mkdir -p ~/.config/{hypr,waybar,wofi,kitty,dunst,fastfetch}
mkdir -p ~/.config/hypr/scripts
mkdir -p ~/Pictures/Screenshots

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Copy configuration files
echo ""
echo "📋 Copying configuration files..."

if [ -d "$SCRIPT_DIR/.config" ]; then
    cp -r "$SCRIPT_DIR/.config/"* ~/.config/
    echo "✅ Configuration files copied"
else
    echo "⚠️  .config directory not found in script location"
    echo "   Please manually copy the .config files"
fi

# Make scripts executable
chmod +x ~/.config/hypr/scripts/*.sh

# Download a sample wallpaper (you should replace this with your own)
echo ""
echo "🖼️  Setting up wallpaper..."
if [ ! -f ~/.config/hypr/wallpaper.jpg ]; then
    echo "⚠️  Please add your wallpaper at: ~/.config/hypr/wallpaper.jpg"
    echo "   You can copy your anime wallpaper there"
fi

# Setup hyprpaper service
echo ""
echo "🎨 Configuring hyprpaper..."
if ! command -v hyprpaper &> /dev/null; then
    sudo dnf install -y hyprpaper
fi

echo ""
echo "======================================"
echo "  ✅ Installation Complete!"
echo "======================================"
echo ""
echo "📝 Next steps:"
echo ""
echo "1. Add your wallpaper:"
echo "   cp /path/to/your/wallpaper.jpg ~/.config/hypr/wallpaper.jpg"
echo ""
echo "2. Logout and select Hyprland from your display manager"
echo ""
echo "3. Useful keybindings:"
echo "   SUPER + Return       → Open terminal (Kitty)"
echo "   SUPER + D            → Application launcher (Wofi)"
echo "   SUPER + Q            → Close window"
echo "   SUPER + M            → Exit Hyprland"
echo "   SUPER + F            → Fullscreen"
echo "   SUPER + V            → Toggle floating"
echo "   SUPER + 1-9          → Switch workspace"
echo "   SUPER + SHIFT + S    → Screenshot"
echo ""
echo "4. Edit configurations:"
echo "   Hyprland: ~/.config/hypr/hyprland.conf"
echo "   Waybar:   ~/.config/waybar/config"
echo "   Wofi:     ~/.config/wofi/config"
echo "   Kitty:    ~/.config/kitty/kitty.conf"
echo ""
echo "🎉 Enjoy your new Hyprland setup!"
echo ""
