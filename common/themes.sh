#!/bin/bash

###################################################################
# Installation des thèmes et icônes pour Hyprland               #
# Thèmes GTK et curseurs pour une interface cohérente           #
###################################################################

# Bannière d'affichage
show_themes_banner() {
    gum style \
        --border rounded \
        --align center \
        --width 55 \
        --margin "1" \
        --padding "1" \
'
  ________          __                
 /_  __/ /  ___ __ _  ___ ___         
  / / / _ \/ -_)  ; \/ -_|_-<         
 /_/ /_//_/\__/_/_/_/\__/___/         
                                      
 Configuration pour Fedora
'
}

clear
show_themes_banner
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
readonly LOG_FILE="$LOG_DIR/themes-$(date +%Y%m%d-%H%M%S).log"
readonly CACHE_DIR="$PROJECT_DIR/.cache"

# ====================================
# Téléchargement des thèmes
# ====================================
log_message action "Téléchargement des thèmes et icônes..."

readonly THEMES_URL="https://github.com/shell-ninja/themes_icons/archive/refs/heads/main.zip"
readonly THEMES_DIR="$CACHE_DIR/themes_icons"
readonly ZIP_FILE="$THEMES_DIR.zip"

if curl -L "$THEMES_URL" -o "$ZIP_FILE" 2>/dev/null; then
    log_message done "Téléchargement terminé"
else
    log_message error "Échec du téléchargement"
    exit 1
fi

echo

# ====================================
# Extraction des thèmes
# ====================================
log_message action "Extraction des thèmes..."

if [[ -f "$ZIP_FILE" ]]; then
    mkdir -p "$THEMES_DIR"
    unzip -q "$ZIP_FILE" "themes_icons-main/*" -d "$THEMES_DIR"
    mv "$THEMES_DIR/themes_icons-main/"* "$THEMES_DIR" && rmdir "$THEMES_DIR/themes_icons-main"
    rm "$ZIP_FILE"
    log_message done "Extraction terminée"
fi

# ====================================
# Installation des thèmes
# ====================================
if [[ -d "$THEMES_DIR" ]]; then
    cd "$THEMES_DIR"
    chmod +x extract.sh
    
    log_message action "Installation des thèmes et icônes..."
    ./extract.sh &>/dev/null
    
    # Copie des icônes dans le répertoire système
    if [[ -d "$HOME/.icons/Bibata-Modern-Ice" ]]; then
        sudo cp -r "$HOME/.icons"/* /usr/share/icons/ &>/dev/null
        log_message done "Icônes installés avec succès"
    fi
fi

log_message done "Installation des thèmes terminée"

sleep 1
clear
