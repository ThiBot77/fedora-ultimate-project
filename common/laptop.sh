#!/bin/bash

###################################################################
# Configuration spécifique pour système portable (Laptop)        #
# Optimisations batterie et écran pour PC portable sous Hyprland #
###################################################################

# Bannière d'affichage
show_laptop_banner() {
    gum style \
        --border rounded \
        --align center \
        --width 55 \
        --margin "1" \
        --padding "1" \
'
   __           __            
  / /  ___ ____/ /____  ___  
 / /__/ _ `/ _  __/ _ \/ _ \
/____/\_,_/ ._/\__/\___/ .__/
         /_/          /_/    
                             
 Configuration Laptop Fedora
'
}

clear
show_laptop_banner
echo
echo

# ====================================
# Configuration
# ====================================
readonly SCRIPT_DIR="$(dirname "$(realpath "$0)")"
readonly PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Chargement des fonctions
source "$PROJECT_DIR/interaction_fn.sh"
source "$PROJECT_DIR/dnf-scripts/1-global_script.sh"

readonly LOG_DIR="$PROJECT_DIR/Logs"
readonly LOG_FILE="$LOG_DIR/laptop-$(date +%Y%m%d-%H%M%S).log"

# ====================================
# Paquets spécifiques Laptop
# ====================================
laptop_packages=(
    brightnessctl
    wlroots
)

log_message note "Système portable détecté"
log_message action "Configuration spécifique Laptop..."

# ====================================
# Installation des paquets
# ====================================
for package in "${laptop_packages[@]}"; do
    install_package "$package"
done

log_message done "Configuration Laptop terminée"
log_message note "brightnessctl permet de contrôler la luminosité de l'écran"

sleep 1
clear
