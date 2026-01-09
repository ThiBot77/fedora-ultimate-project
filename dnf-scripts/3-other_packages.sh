#!/bin/bash

################################################################
# Installation des paquets complémentaires pour Fedora        #
# Outils et applications pour environnement Hyprland complet  #
################################################################

# Bannière d'affichage
show_packages_banner() {
    gum style \
        --border rounded \
        --align center \
        --width 50 \
        --margin "1" \
        --padding "1" \
'   ____                  _             
  / __ \____  ___  _____(_)___  ____ ____ 
 / / / / __ \/ _ \/ ___/ / __ \/ __ `/ __ \
/ /_/ / /_/ /  __/ /  / / / / / /_/ / / / /
\____/ .___/\___/_/  /_/_/ /_/\__,_/_/ /_/ 
    /_/      Configuration pour Fedora
'
}

clear
show_packages_banner
echo
echo

# ====================================
# Configuration
# ====================================
readonly SCRIPT_DIR="$(dirname "$(realpath "$0")")"
readonly PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Chargement des fonctions
source "$SCRIPT_DIR/1-global_script.sh"
source "$PROJECT_DIR/interaction_fn.sh"

# Fichiers de cache et logs
readonly CACHE_DIR="$PROJECT_DIR/.cache"
readonly PACKAGES_INSTALLED="$CACHE_DIR/installed_packages"
readonly LOG_DIR="$PROJECT_DIR/Logs"
readonly LOG_FILE="$LOG_DIR/packages-$(date +%Y%m%d-%H%M%S).log"

# ====================================
# Liste des paquets à installer
# ====================================

# Paquets essentiels
essential_packages=(
    curl
    fastfetch
    ffmpeg-free
    git
    grim
    ImageMagick
    jq
    kitty
    kvantum
    kvantum-qt5
    less
    libX11-devel
    libXext-devel
    lxappearance
    make
    network-manager-applet
    NetworkManager-tui
    nodejs
    nodejs-npm
    neovim
    nvtop
    pamixer
    parallel
    pciutils
    pavucontrol
    pipewire-alsa
    pipewire-utils
    pipewire-pulse
    power-profiles-daemon
    pulseaudio-utils
    python3-requests
    python3-devel
    python3-gobject
    python3-pip
    python3-pillow
    python3-pyquery
    qt5ct
    qt6ct-kde
    qt6-qtsvg
    ripgrep
    rofi-wayland
    slurp
    SwayNotificationCenter
    satty
    tar
    unzip
    waybar
    wget2
    wl-clipboard
    xdg-utils
    xfce-polkit
    yazi
)

# Paquets additionnels
additional_packages=(
    btop
    cava
    cliphist
    kde-partitionmanager
    mpv
    mpv-mpris
    nwg-look
    swww
    wlogout
)

# Gestionnaire de fichiers et outils KDE
kde_tools=(
    ark
    crudini
    dolphin
    gwenview
    okular
)

# ====================================
# Filtre des paquets déjà installés
# ====================================
log_message action "Vérification des paquets déjà installés..."

for package in "${essential_packages[@]}" "${additional_packages[@]}" "${kde_tools[@]}"; do
    skip_if_installed "$package"
done

# Création des listes de paquets à installer
packages_to_install_essential=($(printf "%s\n" "${essential_packages[@]}" | grep -vxFf "$PACKAGES_INSTALLED"))
packages_to_install_additional=($(printf "%s\n" "${additional_packages[@]}" | grep -vxFf "$PACKAGES_INSTALLED"))
packages_to_install_kde=($(printf "%s\n" "${kde_tools[@]}" | grep -vxFf "$PACKAGES_INSTALLED"))

echo
echo

# ====================================
# Installation des paquets
# ====================================
log_message action "Installation des paquets complémentaires..."

for package in "${packages_to_install_essential[@]}" "${packages_to_install_additional[@]}" "${packages_to_install_kde[@]}"; do
    install_package "$package"
done

# ====================================
# Installation de Grimblast
# ====================================
log_message action "Vérification de Grimblast..."

if [[ -f '/usr/local/bin/grimblast' ]]; then
    log_message skip "Grimblast est déjà installé"
else
    log_message action "Installation de Grimblast depuis GitHub..."
    
    readonly GRIMBLAST_URL="https://github.com/hyprwm/contrib.git"
    readonly GRIMBLAST_DIR="$CACHE_DIR/grimblast"
    
    git clone --depth=1 "$GRIMBLAST_URL" "$GRIMBLAST_DIR/" &>/dev/null
    cd "$GRIMBLAST_DIR/grimblast"
    
    make &>/dev/null && sudo make install &>/dev/null
    
    cd "$PROJECT_DIR"
    rm -rf "$GRIMBLAST_DIR"
    
    if [[ -f '/usr/local/bin/grimblast' ]]; then
        log_message done "Grimblast installé avec succès"
    else
        log_message error "Échec de l'installation de Grimblast"
    fi
fi

sleep 1
clear

# ====================================
# Installation de Pywal
# ====================================
if [[ -f "$SCRIPT_DIR/pywal.sh" ]]; then
    "$SCRIPT_DIR/pywal.sh"
fi