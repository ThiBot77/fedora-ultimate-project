#!/bin/bash

########################################################
# Installation Hyprland pour Fedora par Thibault     #
# Script de préparation - Installation des prérequis #
########################################################

# Définition des couleurs pour l'affichage
readonly COLOR_INFO="\e[1;36m"    # Cyan pour les informations
readonly COLOR_SUCCESS="\e[1;32m" # Vert pour les succès
readonly COLOR_SKIP="\e[1;35m"    # Magenta pour les étapes sautées
readonly COLOR_RESET="\e[0m"      # Réinitialisation

# Récupération du répertoire du script
readonly SCRIPT_DIR="$(dirname "$(realpath "$0")")"
readonly MAIN_SCRIPT="$SCRIPT_DIR/start.sh"

# Fonction pour afficher un message d'information
print_info() {
    echo -e "${COLOR_INFO}▸${COLOR_RESET} $1"
}

# Fonction pour afficher un message de succès
print_success() {
    echo -e "${COLOR_SUCCESS}✓${COLOR_RESET} $1"
}

# Fonction pour afficher un message de saut
print_skip() {
    echo -e "${COLOR_SKIP}⊳${COLOR_RESET} $1"
}

# Fonction pour vérifier et installer un paquet
check_and_install() {
    local package=$1
    
    if rpm -q "$package" &>/dev/null; then
        print_skip "$package est déjà installé"
        return 0
    fi
    
    print_info "Installation de $package..."
    if sudo dnf install -y "$package" &>/dev/null; then
        print_success "$package installé avec succès"
        return 0
    else
        echo -e "${COLOR_INFO}✗${COLOR_RESET} Échec de l'installation de $package"
        return 1
    fi
}

# Début du script
clear
sleep 0.5

print_info "Installation des dépendances nécessaires..."
echo

# Installation des paquets requis
check_and_install "git"
check_and_install "gum"

echo
print_success "Préparation terminée !"
sleep 1

# Rendre le script principal exécutable et le lancer
chmod +x "$MAIN_SCRIPT"
exec "$MAIN_SCRIPT"
    
