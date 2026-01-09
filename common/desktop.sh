#!/bin/bash

###################################################################
# Configuration spécifique pour système Desktop                  #
# Optimisations et outils pour PC de bureau sous Hyprland        #
###################################################################

# Bannière d'affichage
show_desktop_banner() {
    gum style \
        --border rounded \
        --align center \
        --width 55 \
        --margin "1" \
        --padding "1" \
'
   ___          __  __            
  / _ \___  ___/ /_/ /____  ___  
 / // / -_)(_-</  _/ __/ _ \/ _ \
/____/\__//___/\_,\__/\___/ .__/
                         /_/     
 Configuration Desktop Fedora
'
}

clear
show_desktop_banner
echo
echo

# ====================================
# Configuration
# ====================================
readonly SCRIPT_DIR="$(dirname "$(realpath "$0)")"
readonly PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Chargement des fonctions
source "$PROJECT_DIR/interaction_fn.sh"
source "$PROJECT_DIR/dnf-scripts/1-global_script.sh"

readonly LOG_DIR="$PROJECT_DIR/Logs"
readonly LOG_FILE="$LOG_DIR/desktop-$(date +%Y%m%d-%H%M%S).log"

# ====================================
# Paquets spécifiques Desktop
# ====================================
desktop_packages=(
    ddcutil
)

log_message note "Système Desktop détecté"
log_message action "Configuration spécifique Desktop..."

# ====================================
# Installation des paquets
# ====================================
for package in "${desktop_packages[@]}"; do
    install_package "$package"
done

# ====================================
# Configuration du module i2c
# ====================================
log_message action "Activation du module i2c-dev..."

sudo modprobe i2c-dev 2>/dev/null
echo "i2c-dev" | sudo tee /etc/modules-load.d/i2c.conf >/dev/null

readonly CURRENT_USER=$(whoami)
log_message action "Ajout de l'utilisateur au groupe i2c..."
sudo usermod -aG i2c "$CURRENT_USER" 2>/dev/null

# ====================================
# Vérification des périphériques
# ====================================
log_message action "Vérification des périphériques i2c..."

if ls /dev/i2c-* &>/dev/null; then
    log_message done "Périphériques i2c détectés"
    log_message note "Test de ddcutil (peut prendre quelques secondes)..."
    ddcutil detect &>/dev/null && log_message done "ddcutil opérationnel" || log_message warning "Aucun moniteur DDC détecté"
else
    log_message warning "Aucun périphérique i2c trouvé"
fi

log_message done "Configuration Desktop terminée"

sleep 1
clear
    msg dn "/dev/i2c devices detected."
fi

msg act "Detecting DDC/CI capable monitors..."
ddcutil detect || msg err "No monitors detected. Make sure DDC/CI is enabled in your monitor settings."

echo
msg dn "Setup complete."

sleep 1 && clear
