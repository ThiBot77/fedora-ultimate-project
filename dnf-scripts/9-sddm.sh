#!/bin/bash

###########################################################
# Installation et configuration de SDDM pour Fedora      #
# Gestionnaire d'affichage pour Hyprland                 #
###########################################################

# Bannière d'affichage
show_sddm_banner() {
    gum style \
        --border rounded \
        --align center \
        --width 50 \
        --margin "1" \
        --padding "1" \
'
   _______  ___  __  ___
  / __/ _ \/ _ \/  |/  /
 _\ \/ // / // / /|_/ / 
/___/____/____/_/  /_/  
                        
 Configuration pour Fedora
'
}

clear
show_sddm_banner
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

# Fichiers de logs
readonly LOG_DIR="$PROJECT_DIR/Logs"
readonly LOG_FILE="$LOG_DIR/sddm-$(date +%Y%m%d-%H%M%S).log"
readonly CACHE_DIR="$PROJECT_DIR/.cache"
readonly PACKAGES_INSTALLED="$CACHE_DIR/installed_packages"

# ====================================
# Paquets SDDM et dépendances
# ====================================
sddm_packages=(
    qt5-qtgraphicaleffects
    qt5-qtquickcontrols
    sddm
    qt6-qt5compat
    qt6-qtdeclarative
    qt6-qtsvg
    qt6-qtvirtualkeyboard
    qt6-qtmultimedia
)

# Gestionnaires d'affichage à désinstaller
old_display_managers=(
    lightdm
    gdm
    lxdm
    lxdm-gtk3
)

# ====================================
# Vérification et installation
# ====================================
log_message action "Vérification des paquets SDDM..."

for package in "${sddm_packages[@]}"; do
    skip_if_installed "$package"
done

packages_to_install=($(printf "%s\n" "${sddm_packages[@]}" | grep -vxFf "$PACKAGES_INSTALLED"))

echo
echo

if [[ ${#packages_to_install[@]} -eq 0 ]]; then
    log_message skip "Tous les paquets SDDM sont déjà installés"
else
    log_message action "Installation des paquets SDDM..."
    
    for package in "${packages_to_install[@]}"; do
        install_package "$package"
    done
    
    log_message done "Installation de SDDM terminée"
fi

# ====================================
# Désactivation des anciens gestionnaires
# ====================================
log_message action "Vérification des anciens gestionnaires d'affichage..."

for old_dm in "${old_display_managers[@]}"; do
    if rpm -q "$old_dm" &>/dev/null && systemctl is-enabled "$old_dm" &>/dev/null; then
        log_message action "Désactivation de $old_dm..."
        sudo systemctl disable "$old_dm" 2>/dev/null
    fi
done

# ====================================
# Activation de SDDM
# ====================================
log_message action "Activation de SDDM..."

sudo systemctl set-default graphical.target 2>/dev/null
if sudo systemctl enable sddm.service 2>/dev/null; then
    log_message done "SDDM activé avec succès"
else
    log_message error "Échec de l'activation de SDDM"
fi

# ====================================
# Configuration du thème SDDM
# ====================================
readonly COMMON_DIR="$PROJECT_DIR/common"
if [[ -f "$COMMON_DIR/sddm_theme.sh" ]]; then
    log_message action "Application du thème SDDM..."
    "$COMMON_DIR/sddm_theme.sh"
fi

sleep 1
clear