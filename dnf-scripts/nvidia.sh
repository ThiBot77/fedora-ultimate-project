#!/bin/bash

###################################################################
# Installation des drivers NVIDIA pour Fedora + Hyprland         #
# Configuration optimale pour cartes graphiques NVIDIA            #
# Script adapté de JaKooLit - github.com/JaKooLit               #
###################################################################

# Bannière d'affichage
show_nvidia_banner() {
    gum style \
        --border rounded \
        --align center \
        --width 55 \
        --margin "1" \
        --padding "1" \
'
   _  ___    _______ ___  _____
  / |/ / |  / /  _/ / _ \\/  _/  __ _
 /    /| | / // // / // // /   / // /
/_/|_/ |_|/_/___/____/___/    \_,_/ 
                                     
    Drivers pour Fedora + Hyprland
'
}

clear
show_nvidia_banner
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
readonly LOG_FILE="$LOG_DIR/nvidia-$(date +%Y%m%d-%H%M%S).log"
readonly CACHE_DIR="$PROJECT_DIR/.cache"
readonly PACKAGES_INSTALLED="$CACHE_DIR/installed_packages"

# ====================================
# Paquets NVIDIA pour Fedora
# ====================================
nvidia_packages=(
    akmod-nvidia
    xorg-x11-drv-nvidia-cuda
    libva
    libva-nvidia-driver
)

# ====================================
# Vérification et installation
# ====================================
log_message action "Vérification des drivers NVIDIA..."

for package in "${nvidia_packages[@]}"; do
    skip_if_installed "$package"
done

packages_to_install=($(printf "%s\n" "${nvidia_packages[@]}" | grep -vxFf "$PACKAGES_INSTALLED"))

echo
echo

if [[ ${#packages_to_install[@]} -eq 0 ]]; then
    log_message skip "Tous les drivers NVIDIA sont déjà installés"
else
    log_message action "Installation des drivers NVIDIA..."
    log_message warning "Cette opération peut prendre plusieurs minutes..."
    
    for package in "${packages_to_install[@]}"; do
        install_package "$package"
    done
    
    log_message done "Installation des drivers NVIDIA terminée"
fi

# ====================================
# Configuration de GRUB
# ====================================
log_message action "Configuration de GRUB pour NVIDIA..."

readonly NVIDIA_PARAMS="rd.driver.blacklist=nouveau modprobe.blacklist=nouveau nvidia-drm.modeset=1"

if grep -q "$NVIDIA_PARAMS" /etc/default/grub; then
    log_message skip "GRUB déjà configuré pour NVIDIA"
else
    log_message action "Ajout des paramètres NVIDIA à GRUB..."
    sudo sed -i "s/GRUB_CMDLINE_LINUX=\"/GRUB_CMDLINE_LINUX=\"$NVIDIA_PARAMS /" /etc/default/grub
    
    log_message action "Mise à jour de la configuration GRUB..."
    sudo grub2-mkconfig -o /boot/grub2/grub.cfg &>/dev/null
    
    log_message done "GRUB configuré avec succès"
fi

echo
log_message warning "Configuration NVIDIA terminée"
log_message note "Un redémarrage est nécessaire pour activer les drivers"

sleep 2
clear

clear