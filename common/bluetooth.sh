#!/bin/bash

###########################################################
# Configuration Bluetooth pour Fedora + Hyprland         #
# Installation et activation des services Bluetooth      #
###########################################################

# Bannière d'affichage
show_bluetooth_banner() {
    gum style \
        --border rounded \
        --align center \
        --width 60 \
        --margin "1" \
        --padding "1" \
'
   ___  __         __            __  __ 
  / _ )/ /_ _____ / /____  ___  / /_/ / 
 / _  / / // / -_) __/ _ \/ _ \/ __/ _ \
/____/_/\_,_/\__/\__/\___/\___/\__/_//_/
     Configuration pour Fedora                                  
'
}

clear
show_bluetooth_banner
echo
echo

# ====================================
# Configuration
# ====================================
readonly SCRIPT_DIR="$(dirname "$(realpath "$0")")"
readonly PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Chargement des fonctions
source "$PROJECT_DIR/interaction_fn.sh"
source "$PROJECT_DIR/dnf-scripts/1-global_script.sh"

# Fichiers de logs
readonly LOG_DIR="$PROJECT_DIR/Logs"
readonly LOG_FILE="$LOG_DIR/bluetooth-$(date +%Y%m%d-%H%M%S).log"

# ====================================
# Paquets Bluetooth pour Fedora
# ====================================
bluetooth_packages=(
    bluez
    bluez-tools
    blueman
    python3-cairo
)

# ====================================
# Installation des paquets Bluetooth
# ====================================
log_message action "Installation des paquets Bluetooth..."

for package in "${bluetooth_packages[@]}"; do
    install_package "$package"
done

# ====================================
# Activation du service Bluetooth
# ====================================
log_message action "État du service Bluetooth..."

if sudo systemctl enable --now bluetooth.service 2>/dev/null; then
    log_message done "Service Bluetooth activé avec succès"
else
    log_message error "Échec de l'activation du service Bluetooth"
fi

sleep 1
clear
