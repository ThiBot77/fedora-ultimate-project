#!/bin/bash

################################################################
# Installation de navigateurs web pour Fedora                 #
# Support de Brave, Chrome, Chromium, Firefox et Zen Browser  #
################################################################

# Bannière d'affichage
show_browser_banner() {
    gum style \
        --border rounded \
        --align center \
        --width 55 \
        --margin "1" \
        --padding "1" \
'
   _  __           _            __                
  / |/ /__ __  __(_)__ ____ _ / /______ __ __ ___
 /    / _ `/ |/ / / _ `/ _ `// __/ -_) // // __/
/_/|_/\_,_/|___/_/\_, /\_,_/ \__/\__/\_,_//_/   
                 /___/                           
      Installation pour Fedora
'
}

clear
show_browser_banner
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
readonly LOG_FILE="$LOG_DIR/browser-$(date +%Y%m%d-%H%M%S).log"
readonly CACHE_DIR="$PROJECT_DIR/.cache"

# Lecture du choix du navigateur
readonly BROWSER_CHOICE=$(cat "$CACHE_DIR/browser" 2>/dev/null)

# ====================================
# Fonction : Instructions Wayland pour navigateurs Chromium
# ====================================
show_wayland_instructions() {
    log_message warning "Configuration requise pour Wayland :"
    echo
    echo "  1. Ouvrez le navigateur"
    echo "  2. Dans la barre d'adresse, tapez 'chrome://flags'"
    echo "  3. Recherchez 'Ozone platform'"
    echo "  4. Sélectionnez 'Wayland' et redémarrez le navigateur"
    echo
    sleep 5
}

# ====================================
# Installation selon le choix
# ====================================
# ====================================
# Installation selon le choix
# ====================================
case "$BROWSER_CHOICE" in
    "Brave")
        log_message action "Vérification de Brave..."
        if command -v brave-browser &>/dev/null; then
            log_message skip "Brave est déjà installé"
        else
            log_message action "Installation de Brave..."
            if curl -fsS https://dl.brave.com/install.sh | sh; then
                log_message done "Brave installé avec succès"
                show_wayland_instructions
            else
                log_message error "Échec de l'installation de Brave"
            fi
        fi
        ;;
        
    "Google_Chrome")
        log_message action "Vérification de Google Chrome..."
        if command -v google-chrome-stable &>/dev/null; then
            log_message skip "Google Chrome est déjà installé"
        else
            log_message action "Configuration du dépôt Google Chrome..."
            install_package fedora-workstation-repositories
            sudo dnf config-manager setopt google-chrome.enabled=1 &>/dev/null
            
            log_message action "Installation de Google Chrome..."
            install_package google-chrome-stable
            
            if command -v google-chrome-stable &>/dev/null; then
                log_message done "Google Chrome installé avec succès"
                show_wayland_instructions
            else
                log_message error "Échec de l'installation de Google Chrome"
            fi
        fi
        ;;
        
    "Chromium")
        log_message action "Vérification de Chromium..."
        if command -v chromium &>/dev/null; then
            log_message skip "Chromium est déjà installé"
        else
            log_message action "Installation de Chromium..."
            install_package chromium
            
            if command -v chromium &>/dev/null; then
                log_message done "Chromium installé avec succès"
                show_wayland_instructions
            else
                log_message error "Échec de l'installation de Chromium"
            fi
        fi
        ;;
        
    "Firefox")
        log_message action "Vérification de Firefox..."
        if command -v firefox &>/dev/null; then
            log_message skip "Firefox est déjà installé"
        else
            log_message action "Installation de Firefox..."
            install_package firefox
            
            if command -v firefox &>/dev/null; then
                log_message done "Firefox installé avec succès"
            else
                log_message error "Échec de l'installation de Firefox"
            fi
        fi
        ;;
        
    "Zen Browser")
        log_message action "Vérification de Zen Browser..."
        if command -v zen-browser &>/dev/null; then
            log_message skip "Zen Browser est déjà installé"
        else
            log_message action "Installation de Zen Browser..."
            log_message note "Activation du dépôt COPR..."
            
            sudo dnf copr enable sneexy/zen-browser -y &>/dev/null
            sudo wget -q "https://copr.fedorainfracloud.org/coprs/sneexy/zen-browser/repo/fedora-$(rpm -E %fedora)/sneexy-zen-browser-fedora-$(rpm -E %fedora).repo" \
                -O "/etc/yum.repos.d/_copr_sneexy-zen-browser.repo"
            
            sudo dnf install zen-browser-avx2 -y
            
            if command -v zen-browser &>/dev/null; then
                log_message done "Zen Browser installé avec succès"
            else
                log_message error "Échec de l'installation de Zen Browser"
            fi
        fi
        ;;
        
    "Ignorer"|"Skip")
        log_message skip "Aucun navigateur ne sera installé"
        ;;
        
    *)
        log_message error "Choix invalide : $BROWSER_CHOICE"
        ;;
esac

sleep 1
clear