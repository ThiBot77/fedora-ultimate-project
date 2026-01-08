#!/bin/bash

# Fedora Hyprland Dotfiles - Installation et Mise à Jour
# Ce script installe tous les packages requis et configure les dotfiles
# Peut être utilisé pour une installation initiale ou une mise à jour

set -e  # Arrêter en cas d'erreur

echo "======================================"
echo "  Fedora Hyprland Setup Script"
echo "======================================"
echo ""

# Sauvegarder le répertoire du script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
START_DIR="$SCRIPT_DIR"

# Vérifier si on est sur Fedora
if [ ! -f /etc/fedora-release ]; then
    echo "❌ Ce script est conçu pour Fedora Linux"
    exit 1
fi

# Fonction pour sauvegarder les fichiers existants
backup_file() {
    if [ -f "$1" ]; then
        backup_path="${1}.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$1" "$backup_path"
        echo "💾 Backup: $backup_path"
    fi
}

# Détecter si c'est une première installation ou une mise à jour
HYPRLAND_INSTALLED=false
if command -v hyprctl &> /dev/null || [ -d ~/.config/hypr ]; then
    HYPRLAND_INSTALLED=true
    echo "🔄 Mise à jour détectée (Hyprland déjà présent)"
else
    echo "🆕 Première installation détectée"
fi
echo ""


echo "📦 Installation des packages requis..."
echo ""

# Optimiser DNF
if ! grep -q "max_parallel_downloads" /etc/dnf/dnf.conf; then
    echo "⚡ Optimisation de la configuration DNF..."
    echo 'max_parallel_downloads=10' | sudo tee -a /etc/dnf/dnf.conf
    echo 'fastestmirror=True' | sudo tee -a /etc/dnf/dnf.conf
    echo 'deltarpm=True' | sudo tee -a /etc/dnf/dnf.conf
    echo "✅ DNF optimisé"
else
    echo "✅ DNF déjà optimisé"
fi

# Mise à jour du système (décommenter pour prod)
# echo "🔄 Mise à jour du système..."
# sudo dnf update -y

# Installer Hyprland et dépendances
echo ""
echo "📦 Installation des packages (cela peut prendre un moment)..."
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
    grim \
    slurp \
    wl-clipboard \
    swayidle \
    swaylock \
    xdg-desktop-portal-hyprland \
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
    hyprpaper \
    firefox \
    nwg-look || { echo "❌ Échec de l'installation des packages!"; exit 1; }

echo "✅ Packages installés avec succès"

# Installer Starship (prompt shell moderne)
if ! command -v starship &> /dev/null; then
    echo ""
    echo "⭐ Installation de Starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y
    echo "✅ Starship installé"
else
    echo ""
    echo "✅ Starship déjà installé"
fi

# Installer les polices
echo ""
echo "📝 Installation des polices..."
sudo dnf install -y \
    jetbrains-mono-fonts \
    google-noto-emoji-fonts \
    fontawesome-fonts

# Installer Nerd Fonts
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts

if [ ! -f "JetBrainsMonoNerdFont-Regular.ttf" ]; then
    echo "⬇️  Téléchargement de JetBrains Mono Nerd Font..."
    wget -q https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
    unzip -o JetBrainsMono.zip
    rm JetBrainsMono.zip
    echo "✅ JetBrains Mono Nerd Font installée"
else
    echo "✅ JetBrains Mono Nerd Font déjà installée"
fi

fc-cache -fv > /dev/null 2>&1

# Retourner au répertoire de départ
cd "$START_DIR"

# ========================================
# Configuration Oh-My-Zsh et plugins
# ========================================

echo ""
echo "🐚 Configuration de Zsh et Oh-My-Zsh..."
echo ""

# Installer Oh-My-Zsh si nécessaire
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "📥 Installation de Oh-My-Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    echo "✅ Oh-My-Zsh installé"
else
    echo "✅ Oh-My-Zsh déjà installé"
fi

# Installer/Mettre à jour les plugins Oh-My-Zsh
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

echo "📦 Installation/Mise à jour des plugins Zsh..."

# zsh-autosuggestions
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    echo "✅ zsh-autosuggestions installé"
else
    echo "🔄 Mise à jour de zsh-autosuggestions..."
    cd "$ZSH_CUSTOM/plugins/zsh-autosuggestions" && git pull && cd "$START_DIR"
fi

# zsh-syntax-highlighting
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    echo "✅ zsh-syntax-highlighting installé"
else
    echo "🔄 Mise à jour de zsh-syntax-highlighting..."
    cd "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" && git pull && cd "$START_DIR"
fi

# zsh-completions
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-completions" ]; then
    git clone https://github.com/zsh-users/zsh-completions "$ZSH_CUSTOM/plugins/zsh-completions"
    echo "✅ zsh-completions installé"
else
    echo "🔄 Mise à jour de zsh-completions..."
    cd "$ZSH_CUSTOM/plugins/zsh-completions" && git pull && cd "$START_DIR"
fi

# ========================================
# Création des répertoires et copie des dotfiles
# ========================================

echo ""
echo "📁 Création des répertoires de configuration..."
mkdir -p ~/.config/{hypr,waybar,wofi,kitty,dunst,fastfetch,gtk-3.0,gtk-4.0}
mkdir -p ~/.config/hypr/scripts
mkdir -p ~/Pictures/Screenshots
mkdir -p ~/.local/share/{themes,icons}

# Copier les fichiers de configuration
echo ""
echo "📋 Copie des fichiers de configuration..."
cd "$START_DIR" || exit 1

# Vérifier que .config existe
if [ ! -d ".config" ]; then
    echo "❌ ERREUR: .config non trouvé dans $START_DIR"
    ls -la | head -20
    exit 1
fi

# Copier tous les dotfiles .config
cp -r .config/* ~/.config/ 2>/dev/null
echo "✅ Fichiers de configuration copiés"

# Copier .zshrc
backup_file ~/.zshrc
if [ -f ".zshrc" ]; then
    cp .zshrc ~/.zshrc
    echo "✅ .zshrc copié"
fi

# Copier les fichiers de configuration GTK
echo ""
echo "🎨 Configuration du thème GTK..."

backup_file ~/.gtkrc-2.0
backup_file ~/.config/gtk-3.0/settings.ini
backup_file ~/.config/gtk-4.0/settings.ini

if [ -f ".gtkrc-2.0" ]; then
    cp .gtkrc-2.0 ~/.gtkrc-2.0
    echo "✅ Configuration GTK 2.0 copiée"
fi

if [ -f ".config/gtk-3.0/settings.ini" ]; then
    cp .config/gtk-3.0/settings.ini ~/.config/gtk-3.0/settings.ini
    echo "✅ Configuration GTK 3.0 copiée"
fi

if [ -f ".config/gtk-4.0/settings.ini" ]; then
    cp .config/gtk-4.0/settings.ini ~/.config/gtk-4.0/settings.ini
    echo "✅ Configuration GTK 4.0 copiée"
fi

# Rendre les scripts exécutables
if [ -d ~/.config/hypr/scripts ]; then
    chmod +x ~/.config/hypr/scripts/*.sh 2>/dev/null
    echo "✅ Scripts rendus exécutables"
fi

# ========================================
# Installation du thème GTK Vanta-Black
# ========================================

echo ""
echo "📦 Installation du thème Vanta-Black..."
if [ -d "$START_DIR/themes/Vanta-Black" ]; then
    mkdir -p ~/.local/share/themes
    cp -r "$START_DIR/themes/Vanta-Black" ~/.local/share/themes/
    echo "✅ Thème Vanta-Black installé"
else
    echo "⚠️  Thème Vanta-Black non trouvé dans $START_DIR/themes/"
fi

# Appliquer le thème GTK via gsettings
if command -v gsettings &> /dev/null; then
    echo "🎨 Application du thème GTK..."
    gsettings set org.gnome.desktop.interface gtk-theme "Vanta-Black" 2>/dev/null || true
    gsettings set org.gnome.desktop.interface icon-theme "Tela-circle-black" 2>/dev/null || true
    gsettings set org.gnome.desktop.interface cursor-theme "Bibata-Modern-Ice" 2>/dev/null || true
    echo "✅ Thème GTK appliqué via gsettings"
fi

# Installer les icônes et curseurs si nécessaire
echo ""
echo "🎨 Vérification des icônes et curseurs..."
echo "💡 Pour installer Tela icons: https://github.com/vinceliuice/Tela-icon-theme"
echo "💡 Pour installer Bibata cursors: sudo dnf install bibata-cursor-themes"

# ========================================
# Configuration finale
# ========================================

# Installer des icônes et thèmes additionnels si demandé
if [ -f ~/.config/hypr/scripts/install-gtk-theme.sh ]; then
    echo ""
    echo "🎨 Exécution du script d'installation de thèmes GTK..."
    bash ~/.config/hypr/scripts/install-gtk-theme.sh
fi

# Configuration du wallpaper
echo ""
echo "🖼️  Configuration du fond d'écran..."
if [ ! -f ~/.config/hypr/wallpaper.jpg ]; then
    echo "⚠️  Wallpaper non trouvé"
    echo "   Ajoute ton wallpaper à: ~/.config/hypr/wallpaper.jpg"
else
    echo "✅ Wallpaper configuré"
fi

# Changer le shell par défaut vers zsh
if [ "$SHELL" != "$(which zsh)" ]; then
    echo ""
    echo "🐚 Changement du shell par défaut vers zsh..."
    chsh -s $(which zsh)
    echo "⚠️  Tu dois te déconnecter et te reconnecter pour que le changement de shell prenne effet"
fi

# ========================================
# Rechargement de l'environnement
# ========================================

echo ""
echo "======================================"
echo "  ✅ Installation/Mise à jour terminée!"
echo "======================================"
echo ""
echo "📝 Prochaines étapes:"
echo ""
echo "1. 🖼️  Ajouter ton wallpaper:"
echo "   cp /chemin/vers/ton/wallpaper.jpg ~/.config/hypr/wallpaper.jpg"
echo ""
echo "2. 🚪 Déconnexion et sélectionne Hyprland depuis ton gestionnaire de session"
echo ""
echo "3. ⌨️  Raccourcis clavier principaux:"
echo "   SUPER + Return       → Terminal (Kitty)"
echo "   SUPER + T            → Terminal (Kitty)"
echo "   SUPER + A            → Lanceur d'applications (Wofi)"
echo "   SUPER + E            → Gestionnaire de fichiers (Thunar)"
echo "   SUPER + Q            → Fermer la fenêtre"
echo "   SUPER + M            → Quitter Hyprland"
echo "   SUPER + F            → Plein écran"
echo "   SUPER + V            → Basculer en mode flottant"
echo "   SUPER + 1-9          → Changer d'espace de travail"
echo "   SUPER + SHIFT + S    → Capture d'écran"
echo ""
echo "4. 📝 Fichiers de configuration principaux:"
echo "   Hyprland: ~/.config/hypr/hyprland.conf"
echo "   Waybar:   ~/.config/waybar/config"
echo "   Wofi:     ~/.config/wofi/config"
echo "   Kitty:    ~/.config/kitty/kitty.conf"
echo "   Zsh:      ~/.zshrc"
echo "   Starship: ~/.config/starship.toml"
echo "   GTK:      ~/.config/gtk-3.0/settings.ini"
echo ""
echo "5. 🎨 Thème installé:"
echo "   GTK:    Vanta-Black"
echo "   Icons:  Tela-circle-black (à installer)"
echo "   Cursor: Bibata-Modern-Ice (installer avec: sudo dnf install bibata-cursor-themes)"
echo ""
echo "6. 🔧 Outils utiles:"
echo "   nwg-look: Interface graphique pour configurer les thèmes GTK"
echo "   Usage: nwg-look"
echo ""

# Check if already on Hyprland and reload
if [ "$XDG_CURRENT_DESKTOP" = "Hyprland" ] || pgrep -x Hyprland > /dev/null; then
    echo "🔄 Hyprland détecté en cours d'exécution..."
    echo "   Rechargement de la configuration..."
    hyprctl reload 2>/dev/null && echo "✅ Hyprland rechargé!" || echo "⚠️  Lance 'hyprctl reload' manuellement"
    
    echo "   Redémarrage de Waybar..."
    killall waybar 2>/dev/null
    waybar &> /dev/null & disown
    echo "✅ Waybar redémarré!"
    
    echo ""
    echo "💡 Pour appliquer complètement le thème GTK, redémarre tes applications"
else
    echo "⚠️  Déconnecte-toi et sélectionne 'Hyprland' depuis ton gestionnaire de session!"
fi

echo ""
echo "🎉 Profite de ton setup Hyprland!"
echo ""
