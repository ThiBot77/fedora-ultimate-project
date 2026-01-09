#!/bin/bash

############################################################
# Installation des polices pour Fedora + Hyprland         #
# Polices système et Nerd Fonts pour un affichage optimal #
############################################################

# Bannière d'affichage
show_fonts_banner() {
    gum style \
        --border rounded \
        --align center \
        --width 50 \
        --margin "1" \
        --padding "1" \
'
   ___       ___                
  / _ \___ _/ (_)________ ___  
 / ___/ _ \/ / / __/ -_|_-<  
/_/   \___/_/_/\__/\__/___/   
                               
    Installation pour Fedora
'
}

clear
show_fonts_banner
echo
echo


# ====================================
# Configuration
# ====================================
readonly SCRIPT_DIR="$(dirname "$(realpath "$0)")"
readonly PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Chargement des fonctions
source "$SCRIPT_DIR/1-global_script.sh"
source "$PROJECT_DIR/interaction_fn.sh"

# Fichiers de cache et logs
readonly CACHE_DIR="$PROJECT_DIR/.cache"
readonly PACKAGES_INSTALLED="$CACHE_DIR/installed_packages"
readonly LOG_DIR="$PROJECT_DIR/Logs"
readonly LOG_FILE="$LOG_DIR/fonts-$(date +%Y%m%d-%H%M%S).log"

# ====================================
# Liste des polices système
# ====================================
system_fonts=(
    fontawesome-fonts-all
    google-noto-sans-cjk-fonts
    google-noto-color-emoji-fonts
    google-noto-emoji-fonts
    jetbrains-mono-fonts
)

# ====================================
# Vérification des polices installées
# ====================================
log_message action "Vérification des polices système..."

for font in "${system_fonts[@]}"; do
    skip_if_installed "$font"
done

fonts_fonts_to_install=($(printf "%s\n" "${system_fonts[@]}" | grep -vxFf "$PACKAGES_INSTALLED"))

echo
echo

# ====================================
# Installation des polices système
# ====================================
if [[ ${#fonts_to_install[@]} -eq 0 ]]; then
    log_message skip "Toutes les polices système sont déjà installées"
else
    log_message action "Installation des polices système..."
    
    for font in "${fonts_to_install[@]}"; do
        install_package "$font"
    done
fi

# ====================================
# Installation JetBrainsMono Nerd Font
# ====================================
log_message action "Vérification de JetBrainsMono Nerd Font..."

if [[ -d ~/.local/share/fonts/JetBrainsMonoNerd ]]; then
    log_message skip "JetBrainsMono Nerd Font déjà installée"
else
    log_message action "Téléchargement de JetBrainsMono Nerd Font..."
    
    readonly JETBRAINS_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz"
    readonly MAX_RETRIES=2
    
    for ((attempt=1; attempt<=MAX_RETRIES; attempt++)); do
        if curl -OL "$JETBRAINS_URL" 2>/dev/null; then
            break
        fi
        if [[ $attempt -lt $MAX_RETRIES ]]; then
            log_message warning "Échec tentative $attempt, nouvelle tentative..."
            sleep 2
        fi
    done
    
    mkdir -p ~/.local/share/fonts/JetBrainsMonoNerd
    tar -xJkf JetBrainsMono.tar.xz -C ~/.local/share/fonts/JetBrainsMonoNerd 2>/dev/null
    rm -f JetBrainsMono.tar.xz
    
    log_message done "JetBrainsMono Nerd Font installée"
fi

# ====================================
# Installation Cascadia Code Nerd Font
# ====================================
log_message action "Vérification de Cascadia Code Nerd Font..."

if [[ -d ~/.local/share/fonts/CascadiaCode ]]; then
    log_message skip "Cascadia Code Nerd Font déjà installée"
else
    log_message action "Téléchargement de Cascadia Code Nerd Font..."
    
    readonly CASCADIA_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/CascadiaCode.tar.xz"
    
    for ((attempt=1; attempt<=MAX_RETRIES; attempt++)); do
        if curl -OL "$CASCADIA_URL" 2>/dev/null; then
            break
        fi
        if [[ $attempt -lt $MAX_RETRIES ]]; then
            log_message warning "Échec tentative $attempt, nouvelle tentative..."
            sleep 2
        fi
    done
    
    mkdir -p ~/.local/share/fonts/CascadiaCode
    tar -xJkf CascadiaCode.tar.xz -C ~/.local/share/fonts/CascadiaCode 2>/dev/null
    rm -f CascadiaCode.tar.xz
    
    log_message done "Cascadia Code Nerd Font installée"
fi

# ====================================
# Mise à jour du cache des polices
# ====================================
log_message action "Mise à jour du cache des polices..."
sudo fc-cache -fv &>/dev/null
log_message done "Cache des polices mis à jour"

sleep 1
clear