#!/bin/bash

##########################################################
# Installation de Hyprland pour Fedora                  #
# Script d'installation du compositeur Wayland Hyprland #
##########################################################

# Bannière d'affichage
show_hyprland_banner() {
    gum style \
        --border rounded \
        --align center \
        --width 60 \
        --margin "1" \
        --padding "1" \
'
   __ __              __             __
  / // /_ _____  ____/ /__ ____  ___/ /
 / _  / // / _ \/ __/ / _ `/ _ \/ _  / 
/_//_/\_, / .__/_/ /_/\_,_/_//_/\_,_/  
     /___/_/                           
     Installation pour Fedora
'
}

clear
show_hyprland_banner
echo
echo

# ====================================
# Configuration
# ====================================
readonly SCRIPT_DIR="$(dirname "$(realpath "$0")")"
readonly PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Chargement des fonctions globales
source "$SCRIPT_DIR/1-global_script.sh"
source "$PROJECT_DIR/interaction_fn.sh"

# Fichiers de cache et logs
readonly CACHE_DIR="$PROJECT_DIR/.cache"
readonly PACKAGES_INSTALLED="$CACHE_DIR/installed_packages"
readonly LOG_DIR="$PROJECT_DIR/Logs"
readonly LOG_FILE="$LOG_DIR/hyprland-$(date +%Y%m%d-%H%M%S).log"

# ====================================
# Liste des composants Hyprland
# ====================================
hyprland_components=(
    hyprland
    hyprlock
    hypridle
    hyprcursor
    hyprsunset
    pyprland
)

# ====================================
# Vérification des paquets installés
# ====================================
log_message action "Vérification des composants Hyprland..."

for component in "${hyprland_components[@]}"; do
    skip_if_installed "$component"
done

components_to_install=($(printf "%s\n" "${hyprland_components[@]}" | grep -vxFf "$PACKAGES_INSTALLED"))

echo
echo

# ====================================
# Installation de Hyprland
# ====================================
if [[ ${#components_to_install[@]} -eq 0 ]]; then
    log_message skip "Tous les composants Hyprland sont déjà installés"
else
    log_message action "Installation des composants Hyprland..."
    
    for component in "${components_to_install[@]}"; do
        install_package "$component"
    done
    
    log_message done "Installation de Hyprland terminée"
fi

sleep 1
clear