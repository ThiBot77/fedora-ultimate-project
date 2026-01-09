#!/bin/bash

#############################################################
# Installation et configuration de Zsh pour Hyprland        #
# Configuration d'un shell moderne et performant           #
#############################################################

# Bannière d'affichage
show_zsh_banner() {
    gum style \
        --border rounded \
        --align center \
        --width 50 \
        --margin "1" \
        --padding "1" \
'
  ____      __  
 /_  /___ _/ /_ 
  / /(_-</ _  /
 /___/___/_//_/ 
                
 Configuration pour Fedora
'
}

clear
show_zsh_banner
echo
echo

# ====================================
# Configuration
# ====================================
readonly SCRIPT_DIR="$(dirname "$(realpath "$0)")"
readonly PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Chargement des fonctions
source "$PROJECT_DIR/interaction_fn.sh"

readonly LOG_DIR="$PROJECT_DIR/Logs"
readonly LOG_FILE="$LOG_DIR/zsh-$(date +%Y%m%d-%H%M%S).log"

# ====================================
# Sauvegarde de la configuration existante
# ====================================
if [[ -d ~/.zsh ]]; then
    log_message warning "Répertoire .zsh existant détecté"
    log_message action "Sauvegarde vers .zsh-backup..."
    mv ~/.zsh ~/.zsh-backup-$(date +%Y%m%d) 2>/dev/null
    log_message done "Sauvegarde terminée"
fi

# ====================================
# Installation de Zsh configuré
# ====================================
log_message action "Téléchargement et installation de Zsh..."

if bash <(curl -s https://raw.githubusercontent.com/shell-ninja/Zsh/main/direct_install.sh) 2>&1 | tee -a "$LOG_FILE"; then
    log_message done "Zsh installé avec succès"
else
    log_message error "Échec de l'installation de Zsh"
fi

sleep 1
clear
