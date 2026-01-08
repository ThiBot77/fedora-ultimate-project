#!/bin/bash

# =============================================================================
# Fedora Ultimate Project - Installation Script
# =============================================================================
# This script installs all necessary packages for Hyprland environment
# Note: Hyprland is assumed to be already installed

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored messages
print_msg() {
    echo -e "${BLUE}==>${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}!${NC} $1"
}

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
    print_error "Ne pas exécuter ce script en tant que root"
    exit 1
fi

print_msg "Début de l'installation des paquets pour Hyprland..."

# =============================================================================
# Update system
# =============================================================================
print_msg "Mise à jour du système (optionnel)..."
read -p "Voulez-vous mettre à jour le système? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo dnf update -y
    print_success "Système mis à jour"
else
    print_success "Mise à jour ignorée"
fi

# =============================================================================
# Check and install missing packages
# =============================================================================
print_msg "Vérification des paquets installés..."

PACKAGES=(
    "waybar"
    "dunst"
    "rofi"
    "grim"
    "slurp"
    "wl-clipboard"
    "brightnessctl"
    "pipewire-utils"
    "xdg-desktop-portal-hyprland"
    "kitty"
    "nautilus"
    "pavucontrol"
    "network-manager-applet"
)

MISSING_PACKAGES=()
for pkg in "${PACKAGES[@]}"; do
    if ! dnf list installed "$pkg" &> /dev/null; then
        MISSING_PACKAGES+=("$pkg")
    fi
done

if [ ${#MISSING_PACKAGES[@]} -eq 0 ]; then
    print_success "Tous les paquets sont déjà installés"
else
    print_msg "Paquets à installer: ${MISSING_PACKAGES[*]}"
    sudo dnf install -y "${MISSING_PACKAGES[@]}"
    print_success "Paquets installés"
fi

# =============================================================================
# Install Nerd Fonts
# =============================================================================
print_msg "Installation des Nerd Fonts..."

FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"

# Download and install CaskaydiaCove Nerd Font
FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/CascadiaCode.zip"
TEMP_DIR=$(mktemp -d)

print_msg "Téléchargement de CaskaydiaCove Nerd Font..."
wget -q --show-progress "$FONT_URL" -O "$TEMP_DIR/CascadiaCode.zip"

print_msg "Extraction de la police..."
unzip -q "$TEMP_DIR/CascadiaCode.zip" -d "$TEMP_DIR/CascadiaCode"

# Copy only the regular font files (no Windows compatible versions)
cp "$TEMP_DIR/CascadiaCode/"*.ttf "$FONT_DIR/" 2>/dev/null || true

# Update font cache
fc-cache -f "$FONT_DIR"

# Cleanup
rm -rf "$TEMP_DIR"

print_success "CaskaydiaCove Nerd Font installée"

# =============================================================================
# Copy configuration files
# =============================================================================
print_msg "Copie des fichiers de configuration..."

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Create config directories if they don't exist
mkdir -p "$HOME/.config/hypr"
mkdir -p "$HOME/.config/kitty"

# Copy Hyprland config
if [ -f "$SCRIPT_DIR/.config/hypr/hyprland.conf" ]; then
    cp -r "$SCRIPT_DIR/.config/hypr/"* "$HOME/.config/hypr/"
    print_success "Configuration Hyprland copiée"
else
    print_warning "Fichier de configuration Hyprland non trouvé dans $SCRIPT_DIR/.config/hypr/"
fi

# Copy Kitty config
if [ -f "$SCRIPT_DIR/.config/kitty/kitty.conf" ]; then
    cp -r "$SCRIPT_DIR/.config/kitty/"* "$HOME/.config/kitty/"
    print_success "Configuration Kitty copiée"
else
    print_warning "Fichier de configuration Kitty non trouvé dans $SCRIPT_DIR/.config/kitty/"
fi

# =============================================================================
# Optional: Install additional tools
# =============================================================================
print_msg "Installation d'outils supplémentaires (optionnel)..."
read -p "Voulez-vous installer des outils supplémentaires? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo dnf install -y \
        htop \
        neofetch \
        git \
        vim \
        wget \
        curl \
        unzip
    print_success "Outils supplémentaires installés"
fi

# =============================================================================
# Final steps
# =============================================================================
print_msg "Vérification de l'installation..."

# Check if required binaries are available
REQUIRED_BINS=(
    "waybar"
    "dunst"
    "rofi"
    "kitty"
    "grim"
    "slurp"
    "wl-copy"
    "brightnessctl"
)

MISSING_BINS=()
for bin in "${REQUIRED_BINS[@]}"; do
    if ! command -v "$bin" &> /dev/null; then
        MISSING_BINS+=("$bin")
    fi
done

if [ ${#MISSING_BINS[@]} -eq 0 ]; then
    print_success "Tous les paquets requis sont installés"
else
    print_warning "Paquets manquants: ${MISSING_BINS[*]}"
fi

# =============================================================================
# Completion message
# =============================================================================
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Installation terminée avec succès!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Pour démarrer Hyprland:"
echo "  1. Déconnectez-vous de votre session actuelle"
echo "  2. Sélectionnez 'Hyprland' dans le menu de connexion"
echo "  3. Connectez-vous"
echo ""
echo "Raccourcis clavier principaux:"
echo "  SUPER + RETURN  : Ouvrir Kitty"
echo "  SUPER + A       : Lancer Rofi"
echo "  SUPER + Q       : Fermer la fenêtre"
echo "  SUPER + [1-9]   : Changer d'espace de travail"
echo ""
print_success "Profitez de votre nouvel environnement Hyprland!"
