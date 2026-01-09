#!/bin/bash

###########################################################
# Script global - Fonctions communes pour Fedora         #
# Utilitaires pour l'installation et la gestion des RPM  #
###########################################################

# Définition des couleurs
readonly CLR_ERROR="\e[1;31m"
readonly CLR_SUCCESS="\e[1;32m"
readonly CLR_WARNING="\e[1;33m"
readonly CLR_INFO="\e[1;34m"
readonly CLR_NOTICE="\e[1;35m"
readonly CLR_HIGHLIGHT="\e[1;36m"
readonly CLR_PROMPT="\e[38;5;214m"
readonly CLR_RESET="\e[0m"

# Chemins du projet
readonly SCRIPT_DIR="$(dirname "$(realpath "$0")")"
readonly PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
readonly CACHE_DIR="$PROJECT_DIR/.cache"
readonly PACKAGES_INSTALLED="$CACHE_DIR/installed_packages"

# Charger les fonctions d'interaction
source "$PROJECT_DIR/interaction_fn.sh"

# ====================================
# Fonctions utilitaires
# ====================================

# Vérifie si un paquet est déjà installé
is_package_installed() {
    rpm -q "$1" &>/dev/null
}

# Enregistre un paquet comme installé
mark_as_installed() {
    [[ ! -f "$PACKAGES_INSTALLED" ]] && touch "$PACKAGES_INSTALLED"
    
    if ! grep -qx "$1" "$PACKAGES_INSTALLED"; then
        echo "$1" >> "$PACKAGES_INSTALLED"
    fi
}

# Ignore les paquets déjà installés
skip_if_installed() {
    if is_package_installed "$1"; then
        log_message skip "$1 est déjà installé"
        mark_as_installed "$1"
        return 0
    fi
    return 1
}

# Installe un paquet avec DNF
install_package() {
    local package="$1"
    
    # Vérifie d'abord s'il est installé
    if skip_if_installed "$package"; then
        return 0
    fi
    
    log_message action "Installation de $package..."
    
    if sudo dnf install -y "$package"; then
        log_message done "$package installé avec succès"
        mark_as_installed "$package"
        return 0
    else
        log_message error "Échec de l'installation de $package"
        return 1
    fi
}