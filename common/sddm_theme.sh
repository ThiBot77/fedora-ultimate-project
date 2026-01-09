#!/bin/bash

###################################################################
# Installation du thème SDDM personnalisé                         #
# Thème SilentSDDM pour l'écran de connexion                      #
###################################################################

# Bannière d'affichage
show_sddm_theme_banner() {
    gum style \
        --border rounded \
        --align center \
        --width 60 \
        --margin "1" \
        --padding "1" \
'
   _______  ___  __  ___  ________          __                
  / __/ _ \/ _ \/  |/  / /_  __/ /  ___ __ _  ___            
 _\ \/ // / // / /|_/ /   / / / _ \/ -_)  ; \/ -_)           
/___/____/____/_/  /_/   /_/ /_//_/\__/_/_/_/\__/            
                                                              
           Configuration pour Fedora
'
}

clear
show_sddm_theme_banner
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
readonly LOG_FILE="$LOG_DIR/sddm-theme-$(date +%Y%m%d-%H%M%S).log"
readonly CACHE_DIR="$PROJECT_DIR/.cache"

# Répertoires SDDM
readonly SDDM_THEMES_DIR="/usr/share/sddm/themes"
readonly SDDM_CONF_DIR="/etc/sddm.conf.d"

# ====================================
# Téléchargement du thème
# ====================================
log_message action "Téléchargement du thème SDDM..."

readonly THEME_URL="https://github.com/shell-ninja/SilentSDDM/archive/refs/heads/main.zip"
readonly THEME_DIR="$CACHE_DIR/SilentSDDM"
readonly ZIP_FILE="$THEME_DIR.zip"

if curl -L "$THEME_URL" -o "$ZIP_FILE" 2>/dev/null; then
    log_message done "Téléchargement terminé"
else
    log_message error "Échec du téléchargement"
    exit 1
fi

echo

# ====================================
# Extraction du thème
# ====================================
log_message action "Extraction du thème..."

if [[ -f "$ZIP_FILE" ]]; then
    mkdir -p "$THEME_DIR"
    unzip -q "$ZIP_FILE" "SilentSDDM-main/*" -d "$THEME_DIR"
    mv "$THEME_DIR/SilentSDDM-main/"* "$THEME_DIR" && rmdir "$THEME_DIR/SilentSDDM-main" 2>/dev/null
    rm "$ZIP_FILE" 2>/dev/null
    log_message done "Extraction terminée"
fi

# ====================================
# Installation du thème
# ====================================
log_message action "Installation du thème SDDM..."

# Création des répertoires
[[ ! -d "$SDDM_THEMES_DIR" ]] && sudo mkdir -p "$SDDM_THEMES_DIR"
[[ ! -d "$SDDM_CONF_DIR" ]] && sudo mkdir -p "$SDDM_CONF_DIR"

# Déplacement du thème
sudo mv "$THEME_DIR" "$SDDM_THEMES_DIR/" 2>/dev/null

# Installation des polices
mkdir -p ~/.local/share/fonts/sddm-fonts
if [[ -d "$SDDM_THEMES_DIR/SilentSDDM/fonts" ]]; then
    sudo mv "$SDDM_THEMES_DIR/SilentSDDM/fonts/"* ~/.local/share/fonts/sddm-fonts/ 2>/dev/null
fi

# ====================================
# Configuration de SDDM
# ====================================
log_message action "Configuration de SDDM..."

echo -e "[Theme]\nCurrent=SilentSDDM" | sudo tee "$SDDM_CONF_DIR/theme.conf.user" &>/dev/null
echo -e "[General]\nInputMethod=qtvirtualkeyboard" | sudo tee "$SDDM_CONF_DIR/virtualkbd.conf" &>/dev/null

if [[ -d "$SDDM_THEMES_DIR/SilentSDDM" ]]; then
    log_message done "Thème SDDM installé avec succès"
else
    log_message error "Échec de l'installation du thème SDDM"
fi

sleep 1
clear
