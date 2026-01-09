#!/bin/bash

###################################################################
# Application du thème VS Code personnalisé                       #
# Configuration et plugins pour Visual Studio Code               #
###################################################################

# ====================================
# Configuration
# ====================================
readonly SCRIPT_DIR="$(dirname "$(realpath "$0)")"
readonly PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Chargement des fonctions
source "$PROJECT_DIR/interaction_fn.sh"

readonly LOG_DIR="$PROJECT_DIR/Logs"
readonly LOG_FILE="$LOG_DIR/vscode-theme-$(date +%Y%m%d-%H%M%S).log"
readonly ASSETS_DIR="$PROJECT_DIR/assets"

# Répertoires VS Code
readonly VSCODE_CONFIG="$HOME/.config/Code"
readonly VSCODE_PLUGINS="$HOME/.vscode"

# ====================================
# Sauvegarde de la configuration existante
# ====================================
log_message action "Configuration du thème VS Code..."

if [[ -d "$VSCODE_CONFIG" ]]; then
    log_message warning "Configuration VS Code existante détectée"
    log_message action "Sauvegarde vers .config/Code-backup..."
    mv "$VSCODE_CONFIG" "${VSCODE_CONFIG}-backup-$(date +%Y%m%d)" 2>/dev/null
fi

if [[ -d "$VSCODE_PLUGINS" ]]; then
    log_message action "Sauvegarde des plugins vers .vscode-backup..."
    mv "$VSCODE_PLUGINS" "${VSCODE_PLUGINS}-backup-$(date +%Y%m%d)" 2>/dev/null
fi

# ====================================
# Application du thème
# ====================================
if [[ -d "$ASSETS_DIR/Code" ]]; then
    log_message action "Application de la configuration..."
    cp -r "$ASSETS_DIR/Code" "$HOME/.config/" 2>/dev/null
    log_message done "Configuration copiée"
fi

if [[ -d "$ASSETS_DIR/.vscode" ]]; then
    log_message action "Installation des plugins..."
    cp -r "$ASSETS_DIR/.vscode" "$HOME/" 2>/dev/null
    log_message done "Plugins installés"
fi

log_message done "Thème VS Code appliqué avec succès"

sleep 1
clear
