#!/bin/bash

##############################################################
# Installation de Visual Studio Code pour Fedora            #
# Configuration de l'éditeur avec thèmes personnalisés     #
##############################################################

# Bannière d'affichage
show_vscode_banner() {
    gum style \
        --border rounded \
        --align center \
        --width 50 \
        --margin "1" \
        --padding "1" \
'
  _   ______   ______        __   
 | | / / __/  / ___/__  ___/ /__ 
 | |/ /\ \   / /__/ _ \/ _  / -_)
 |___/___/   \___/\___/\_,_/\__/ 
                                  
    Installation pour Fedora
'
}

clear
show_vscode_banner
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
readonly LOG_FILE="$LOG_DIR/vscode-$(date +%Y%m%d-%H%M%S).log"

# ====================================
# Vérification et installation
# ====================================
log_message action "Vérification de Visual Studio Code..."

if is_package_installed "code"; then
    log_message skip "Visual Studio Code est déjà installé"
else
    log_message action "Installation de Visual Studio Code..."
    
    # Ajout du dépôt Microsoft
    log_message note "Configuration du dépôt Microsoft..."
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc 2>/dev/null
    
    sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo' 2>/dev/null
    
    # Installation de VS Code
    sudo dnf install code -y
    
    if is_package_installed "code"; then
        log_message done "Visual Studio Code installé avec succès"
        
        # Application du thème personnalisé
        readonly COMMON_DIR="$PROJECT_DIR/common"
        if [[ -f "$COMMON_DIR/vs_code_theme.sh" ]]; then
            log_message action "Application du thème personnalisé..."
            "$COMMON_DIR/vs_code_theme.sh"
        fi
    else
        log_message error "Échec de l'installation de Visual Studio Code"
    fi
fi

sleep 1
clear