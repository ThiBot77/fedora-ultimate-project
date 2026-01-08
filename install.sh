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
mkdir -p ~/.config/{hypr,waybar,wofi,kitty,dunst,fastfetch}
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

# Copier .zshrc et forcer le shell par défaut
backup_file "$HOME/.zshrc"
if [ -f ".zshrc" ]; then
    cp .zshrc "$HOME/.zshrc"
    echo "✅ .zshrc copié"
    # Forcer le shell par défaut si besoin
    if [ "$SHELL" != "$(which zsh)" ]; then
        chsh -s "$(which zsh)" "$USER"
        echo "⚠️  Déconnecte-toi/reconnecte-toi pour activer zsh par défaut."
    fi
fi


# Rendre les scripts exécutables
if [ -d "$HOME/.config/hypr/scripts" ]; then
    find "$HOME/.config/hypr/scripts" -type f -name '*.sh' -exec chmod +x {} +
    echo "✅ Scripts rendus exécutables"
fi


# ========================================
# Configuration finale
# ========================================

# Installer des icônes et thèmes additionnels si demandé

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

# Check if already on Hyprland and reload
if [ "$XDG_CURRENT_DESKTOP" = "Hyprland" ] || pgrep -x Hyprland > /dev/null; then
    echo "🔄 Hyprland détecté en cours d'exécution..."
    echo "   Rechargement de la configuration..."
    hyprctl reload 2>/dev/null && echo "✅ Hyprland rechargé!" || echo "⚠️  Lance 'hyprctl reload' manuellement"
    
    echo "   Redémarrage de Waybar..."
    killall waybar 2>/dev/null || true
    sleep 1
    waybar &> /dev/null & disown
    echo "✅ Waybar redémarré!"
    
    echo ""
    echo "💡 Pour appliquer complètement le thème GTK, redémarre tes applications"
else
    echo "⚠️  Déconnecte-toi et sélectionne 'Hyprland' depuis ton gestionnaire de session!"
fi

echo ""
echo "🔍 Vérification:"
echo "   - Thème GTK actuel: $(gsettings get org.gnome.desktop.interface gtk-theme 2>/dev/null || echo 'N/A')"
echo "   - .zshrc modifié: $(stat -c %y ~/.zshrc 2>/dev/null || echo 'N/A')"
echo "   - Thème Vanta-Black: $([ -d ~/.local/share/themes/Vanta-Black ] && echo 'INSTALLÉ' || echo 'MANQUANT')"
echo ""
echo "🎉 Profite de ton setup Hyprland!"
echo ""

# Vérification post-installation
echo "==============================="
echo "🔍 Vérification post-installation :"
if command -v gsettings &> /dev/null; then
    echo "- Thème GTK actuel : $(gsettings get org.gnome.desktop.interface gtk-theme 2>/dev/null || echo 'N/A')"
    echo "- Icônes actuelles : $(gsettings get org.gnome.desktop.interface icon-theme 2>/dev/null || echo 'N/A')"
    echo "- Curseur actuel   : $(gsettings get org.gnome.desktop.interface cursor-theme 2>/dev/null || echo 'N/A')"
else
    echo "- gsettings non disponible (pas d'environnement GNOME/Cinnamon)"
fi
echo "- Fichier GTK 3 : $(grep gtk-theme-name ~/.config/gtk-3.0/settings.ini 2>/dev/null | cut -d'=' -f2)"
echo "- Fichier GTK 4 : $(grep gtk-theme-name ~/.config/gtk-4.0/settings.ini 2>/dev/null | cut -d'=' -f2)"
echo "- Fichier GTK 2 : $(grep gtk-theme-name ~/.gtkrc-2.0 2>/dev/null | cut -d'=' -f2 | tr -d '"')"
echo "- Shell par défaut : $SHELL"
echo "==============================="
