#!/bin/bash

###################################################################
# Installation et configuration de Fish Shell pour Hyprland      #
# Shell moderne et convivial avec autosuggestions                #
###################################################################

# Bannière d'affichage
show_fish_banner() {
    gum style \
        --border rounded \
        --align center \
        --width 50 \
        --margin "1" \
        --padding "1" \
'
    ______ __  
   / ____(_)__/ /_ 
  / /_  / (_-<  _/
 / __/ / /___/_/  
/_/   /_/          
                   
 Configuration pour Fedora
'
}

clear
show_fish_banner
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

readonly LOG_DIR="$PROJECT_DIR/Logs"
readonly LOG_FILE="$LOG_DIR/fish-$(date +%Y%m%d-%H%M%S).log"

# ====================================
# Paquets requis pour Fish
# ====================================
fish_packages=(
    bat
    curl
    eza
    fastfetch
    figlet
    fish
    fzf
    git
    rsync
    starship
    zoxide
    thefuck
)

# ====================================
# Installation des paquets
# ====================================
log_message action "Installation de Fish Shell et outils..."

for package in "${fish_packages[@]}"; do
    install_package "$package"
done

log_message done "Paquets Fish installés"

# ====================================
# Configuration de Fish comme shell par défaut
# ====================================
if [[ ! "$SHELL" == "$(which fish)" ]]; then
    log_message action "Configuration de Fish comme shell par défaut..."
    chsh -s "$(which fish)"
    log_message done "Shell modifié avec succès"
fi

sleep 1
clear
