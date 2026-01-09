#!/bin/bash

#############################################################
# Configuration avancée de Bash pour Hyprland              #
# Amélioration du shell par défaut                          #
#############################################################

# Bannière d'affichage
show_bash_banner() {
    gum style \
        --border rounded \
        --align center \
        --width 50 \
        --margin "1" \
        --padding "1" \
'
   ___           __  
  / _ )___ ____ / /  
 / _  / _ `(_-</ _ \
/____/\_,_/___/_//_/
                     
 Configuration pour Fedora
'
}

clear
show_bash_banner
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
readonly LOG_FILE="$LOG_DIR/bash-$(date +%Y%m%d-%H%M%S).log"

# ====================================
# Sauvegarde de la configuration existante
# ====================================
if [[ -d ~/.bash ]]; then
    log_message warning "Répertoire .bash existant détecté"
    log_message action "Sauvegarde vers .bash-backup..."
    mv ~/.bash ~/.bash-backup-$(date +%Y%m%d) 2>/dev/null
    log_message done "Sauvegarde terminée"
fi

# ====================================
# Installation de Bash configuré
# ====================================
log_message action "Téléchargement et installation de Bash amélioré..."

if bash <(curl -s https://raw.githubusercontent.com/shell-ninja/Bash/main/direct_install.sh) 2>&1 | tee -a "$LOG_FILE"; then
    log_message done "Bash configuré avec succès"
else
    log_message error "Échec de la configuration de Bash"
fi

sleep 1
clear
