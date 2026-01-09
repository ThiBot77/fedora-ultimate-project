#!/bin/bash

###################################################################
# Installation de la configuration Hyprland                      #
# Dotfiles et configuration pour Hyprland                        #
###################################################################

# Bannière d'affichage
show_dotfiles_banner() {
    gum style \
        --border rounded \
        --align center \
        --width 60 \
        --margin "1" \
        --padding "1" \
'
   ___       __  ____ __      
  / _ \___  / /_/ _(_) /__ ___
 / // / _ \/ __/ _/ / / -_|_-<
/____/\___/\__/_//_/_/\__/___/
                               
    Configuration pour Fedora
'
}

clear
show_dotfiles_banner
echo
echo

# ====================================
# Configuration
# ====================================
readonly SCRIPT_DIR="$(dirname "$(realpath "$0")")"
readonly PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Chargement des fonctions
source "$PROJECT_DIR/interaction_fn.sh"

readonly LOG_DIR="$PROJECT_DIR/Logs"
readonly LOG_FILE="$LOG_DIR/dotfiles-$(date +%Y%m%d-%H%M%S).log"
readonly CACHE_DIR="$PROJECT_DIR/.cache"

# ====================================
# Téléchargement de hyprconf
# ====================================
log_message action "Téléchargement de la configuration Hyprland..."

readonly HYPRCONF_URL="https://github.com/shell-ninja/hyprconf/archive/refs/heads/main.zip"
readonly HYPRCONF_DIR="$CACHE_DIR/hyprconf"
readonly ZIP_FILE="$HYPRCONF_DIR.zip"

if curl -L "$HYPRCONF_URL" -o "$ZIP_FILE" 2>>"$LOG_FILE"; then
    log_message done "Téléchargement terminé"
else
    log_message error "Échec du téléchargement"
    exit 1
fi

echo

# ====================================
# Extraction
# ====================================
log_message action "Extraction des fichiers de configuration..."

if [[ -f "$ZIP_FILE" ]]; then
    mkdir -p "$HYPRCONF_DIR"
    unzip -q "$ZIP_FILE" "hyprconf-main/*" -d "$HYPRCONF_DIR" 2>>"$LOG_FILE"
    mv "$HYPRCONF_DIR/hyprconf-main/"* "$HYPRCONF_DIR" 2>>"$LOG_FILE" && \
        rmdir "$HYPRCONF_DIR/hyprconf-main" 2>>"$LOG_FILE"
    rm "$ZIP_FILE" 2>>"$LOG_FILE"
    log_message done "Extraction terminée"
fi

sleep 1

# ====================================
# Installation de la configuration
# ====================================
if [[ -d "$HYPRCONF_DIR" ]]; then
    log_message action "Installation de la configuration Hyprland..."
    
    cd "$HYPRCONF_DIR" || {
        log_message error "Impossible d'accéder au répertoire $HYPRCONF_DIR"
        exit 1
    }
    
    chmod +x setup.sh
    
    if ./setup.sh 2>>"$LOG_FILE"; then
        log_message done "Configuration installée avec succès"
    else
        log_message error "Échec de l'exécution du script setup.sh"
        exit 1
    fi
fi

# ====================================
# Vérification
# ====================================
if [[ -f "$HOME/.config/hypr/scripts/startup.sh" ]]; then
    log_message done "Dotfiles configurés avec succès"
else
    log_message error "Impossible de configurer les dotfiles"
    exit 1
fi

sleep 1
clear
