#!/bin/bash

# Fedora Hyprland Dotfiles Installation Script
# This script installs all required packages and sets up the dotfiles

echo "======================================"
echo "  Fedora Hyprland Setup Script"
echo "======================================"
echo ""

# Save the starting directory
START_DIR="$(pwd)"

# Check if running on Fedora
if [ ! -f /etc/fedora-release ]; then
    echo "❌ This script is designed for Fedora Linux"
    exit 1
fi

echo "📦 Installing required packages..."
echo ""

# Speed up DNF
echo "⚡ Optimizing DNF configuration..."
echo 'max_parallel_downloads=10' | sudo tee -a /etc/dnf/dnf.conf
echo 'fastestmirror=True' | sudo tee -a /etc/dnf/dnf.conf
echo 'deltarpm=True' | sudo tee -a /etc/dnf/dnf.conf

# Update system (commented for faster testing - uncomment for production)
# sudo dnf update -y

# Install Hyprland and dependencies
echo "Installing packages (this may take a while)..."
sudo dnf install -y \
    hyprland \
    waybar \
    wofi \
    kitty \
    dunst \
    fastfetch \
    zsh \
    zsh-autosuggestions \
    zsh-syntax-highlighting \
    starship \
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
    firefox || { echo "❌ Package installation failed!"; exit 1; }

echo "✅ Packages installed successfully"

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

# Return to starting directory
cd "$START_DIR"

# Create necessary directories
echo ""
echo "📁 Creating configuration directories..."
mkdir -p ~/.config/{hypr,waybar,wofi,kitty,dunst,fastfetch,gtk-3.0,gtk-4.0}
mkdir -p ~/.config/hypr/scripts
mkdir -p ~/Pictures/Screenshots
mkdir -p ~/.local/share/{themes,icons}

# Copy configuration files
echo ""
echo "📋 Copying configuration files..."
cd "$START_DIR" || exit 1

# Check if .config exists
if [ -d ".config" ]; then
    cp -r .config/* ~/.config/ 2>/dev/null
    echo "✅ Configuration files copied"
else
    echo "⚠️  ERROR: .config not found"
    echo "PWD: $(pwd)"
    ls -la | head -20
    exit 1
fi

# Copy zshrc
if [ -f ".zshrc" ]; then
    cp .zshrc ~/.zshrc
    echo "✅ .zshrc copied"
fi

# Copy gtkrc
if [ -f ".gtkrc-2.0" ]; then
    cp .gtkrc-2.0 ~/.gtkrc-2.0
    echo "✅ GTK 2.0 config copied"
fi
# Copy gtkrc
if [ -f "./.gtkrc-2.0" ] || [ -f "$PWD/.gtkrc-2.0" ]; then
    cp .gtkrc-2.0 ~/.gtkrc-2.0 2>/dev/null || cp "$PWD/.gtkrc-2.0" ~/.gtkrc-2.0
    echo "✅ GTK 2.0 config copied"
fi

# Make scripts executable (only if files exist)
if [ -d ~/.config/hypr/scripts ]; then
    chmod +x ~/.config/hypr/scripts/*.sh 2>/dev/null
    echo "✅ Scripts made executable"
fi

# Install GTK themes (only if script exists)
if [ -f ~/.config/hypr/scripts/install-gtk-theme.sh ]; then
    echo ""
    echo "🎨 Installing GTK themes..."
    bash ~/.config/hypr/scripts/install-gtk-theme.sh
else
    echo "⚠️  GTK theme install script not found, skipping..."
fi

# Install Oh My Zsh (optional, for additional plugins)
echo ""
echo "🐚 Setting up Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Install Oh My Zsh custom plugins
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    echo "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    echo "Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-completions" ]; then
    echo "Installing zsh-completions..."
    git clone https://github.com/zsh-users/zsh-completions "$ZSH_CUSTOM/plugins/zsh-completions"
fi

# Change default shell to zsh
if [ "$SHELL" != "$(which zsh)" ]; then
    echo "Changing default shell to zsh..."
    chsh -s $(which zsh)
    echo "⚠️  You'll need to log out and back in for the shell change to take effect"
fi

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
echo "   SUPER + T            → Open terminal (Kitty)"
echo "   SUPER + A            → Application launcher (Wofi)"
echo "   SUPER + E            → File manager (Thunar)"
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
echo "   Zsh:      ~/.zshrc"
echo "   Starship: ~/.config/starship.toml"
echo "   GTK:      ~/.config/gtk-3.0/settings.ini"
echo ""
echo "5. Theme applied:"
echo "   GTK:    Catppuccin Mocha Mauve"
echo "   Icons:  Papirus Dark"
echo "   Cursor: Catppuccin Mocha Mauve"
echo ""
echo "🎉 Enjoy your new Hyprland setup!"
echo ""

# Check if already on Hyprland and reload
if [ "$XDG_CURRENT_DESKTOP" = "Hyprland" ] || pgrep -x Hyprland > /dev/null; then
    echo "🔄 Detected Hyprland running, reloading configuration..."
    hyprctl reload 2>/dev/null && echo "✅ Configuration reloaded!" || echo "⚠️  Run 'hyprctl reload' manually"
    killall waybar 2>/dev/null; waybar &> /dev/null &
    echo "✅ Waybar restarted!"
else
    echo "⚠️  You need to logout and select 'Hyprland' from your display manager to see changes!"
fi
echo ""
