#!/bin/bash

###################################################################
# Script d'installation et configuration Hyprland pour Fedora    #
# Développé par Thibault                                          #
# Installation automatisée de l'environnement de bureau Hyprland #
###################################################################

# ====================================
# Configuration des constantes
# ====================================

# Couleurs pour l'affichage terminal
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
readonly INSTALL_SCRIPTS="$SCRIPT_DIR/dnf-scripts"
readonly COMMON_SCRIPTS="$SCRIPT_DIR/common"

# Fichiers de cache et logs
readonly CACHE_DIR="$SCRIPT_DIR/.cache"
readonly USER_PREFS="$CACHE_DIR/preferences"
readonly SHELL_CHOICE="$CACHE_DIR/shell-selection"
readonly LOG_DIR="$SCRIPT_DIR/Logs"
readonly LOG_FILE="$LOG_DIR/installation-$(date +%Y%m%d-%H%M%S).log"

# ====================================
# Chargement des fonctions
# ====================================
source "$SCRIPT_DIR/interaction_fn.sh"

# Création des répertoires nécessaires
mkdir -p "$LOG_DIR" "$CACHE_DIR"

# ====================================
# Fonction : Affichage du logo
# ====================================
show_banner() {
    cat << "EOF"     
   ___           __        ____       __  _           
  /   |  _______/ /_      / __/__  __/ /_(_)_  _____ 
 / /| | / ___/ __  /     / /_/  \/ / __/ / | |/ / _ \
/ ___ |/ /  / /_/ /     / __/ /\  / /_/ /| |  /  __/
/_/  |_/_/   \__,_/     /_/ /_/ /_/\__/_/ |___/\___/ 
                                                      
     Configuration Hyprland pour Fedora
EOF
}

# ====================================

# ====================================
# Fonction : Enregistrement des logs
# ====================================
log_output() {
    sed 's/\x1B\[[0-9;]*[JKmsu]//g' >> "$LOG_FILE"
}

# ====================================
# Fonction : Exécuter un script
# ====================================
run_script() {
    local script_path="$1"
    if [[ -x "$script_path" ]]; then
        "$script_path" 2>&1 | tee -a >(log_output)
    else
        log_message error "Script introuvable : $script_path"
    fi
}

# ====================================
# Initialisation
# ====================================
clear
show_welcome
sleep 0.5

# ====================================
# Gestion du cache utilisateur
# ====================================
if [[ -f "$USER_PREFS" ]]; then
    source "$USER_PREFS"
    
    # Vérification de la validité du cache
    if [[ -z "$drivers_nvidia" ]]; then
        log_message error "Cache corrompu. Veuillez relancer le script."
        
        prompt_confirm "Voulez-vous redémarrer le script ?" "Oui" "Non, quitter"
        
        if [[ $? -eq 0 ]]; then
            gum spin --spinner dot --title "Redémarrage..." -- sleep 2
            rm -f "$USER_PREFS"
            exec "$0"
        else
            exit_script "Arrêt du script"
        fi
    else
        log_message skip "Utilisation des préférences existantes..."
        sleep 1
    fi
else
    # Première exécution : demander les préférences
    log_message warning "Configuration des préférences d'installation"
    echo
    select_features
    
    echo
    echo
    
    log_message warning "Choix du shell"
    select_shell
fi

# Chargement des préférences
source "$USER_PREFS"
source "$SHELL_CHOICE"

# ====================================

# ====================================
# Préparation des scripts
# ====================================
chmod +x "$INSTALL_SCRIPTS"/* 2>&1 | log_output
chmod +x "$COMMON_SCRIPTS"/* 2>&1 | log_output

clear
show_banner
sleep 1

# ====================================
# Installation des paquets principaux
# ====================================
log_message action "Début de l'installation de Hyprland et des composants essentiels..."
echo

run_script "$INSTALL_SCRIPTS/2-hyprland.sh"
run_script "$INSTALL_SCRIPTS/3-other_packages.sh"
run_script "$INSTALL_SCRIPTS/6-fonts.sh"

# ====================================
# Installation du navigateur (optionnel)
# ====================================
if [[ "$installer_navigateur" =~ ^(oui|O|y|Y)$ ]]; then
    log_message question "Sélection du navigateur web :"
    browser_choice=$(gum choose \
        --cursor.foreground "$HEX_CYAN" \
        --item.foreground "#fff" \
        --selected.foreground "$HEX_GREEN" \
        "Brave" "Google_Chrome" "Chromium" "Firefox" "Zen Browser" "Ignorer"
    )
    echo "$browser_choice" > "$CACHE_DIR/browser"
    run_script "$INSTALL_SCRIPTS/7-browser.sh"
else
    log_message skip "Installation du navigateur ignorée"
fi

# ====================================
# Installation des composants système
# ====================================
run_script "$INSTALL_SCRIPTS/9-sddm.sh"
run_script "$INSTALL_SCRIPTS/10-xdg_dp.sh"

# ====================================
# Installations conditionnelles
# ====================================

# VS Code
if [[ "$installer_vscode" =~ ^(oui|O|y|Y)$ ]]; then
    run_script "$INSTALL_SCRIPTS/8-vs_code.sh"
fi

# Drivers NVIDIA
if [[ "$drivers_nvidia" =~ ^(oui|O|y|Y)$ ]]; then
    run_script "$INSTALL_SCRIPTS/nvidia.sh"
fi

# Bluetooth
if [[ "$configuration_bluetooth" =~ ^(oui|O|y|Y)$ ]]; then
    run_script "$COMMON_SCRIPTS/bluetooth.sh"
fi

# Configuration du shell
if [[ "$installer_zsh" =~ ^(oui|O|y|Y)$ ]]; then
    run_script "$COMMON_SCRIPTS/zsh.sh"
elif [[ "$configurer_bash" =~ ^(oui|O|y|Y)$ ]]; then
    run_script "$COMMON_SCRIPTS/bash.sh"
elif [[ "$installer_fish" =~ ^(oui|O|y|Y)$ ]]; then
    run_script "$COMMON_SCRIPTS/fish.sh"
fi

# ====================================
# Nettoyage des paquets inutiles
# ====================================
run_script "$INSTALL_SCRIPTS/11-uninstall.sh"

# ====================================

# ====================================
# Configuration des thèmes et dotfiles
# ====================================
clear

log_message question "Sélectionnez la configuration Hyprland :"
echo
log_message warning "→ hyprconf : Couleurs dynamiques avec pywal (inspiré de JaKooLit)"
log_message warning "→ hyprconf-v2 : Thèmes préconfigurés (inspiré de HyDE)"
echo

config_choice=$(gum choose \
    --limit=1 \
    --cursor.foreground "$HEX_CYAN" \
    --item.foreground "#fff" \
    --selected.foreground "$HEX_GREEN" \
    "hyprconf" "hyprconf-v2"
)

echo "$config_choice" > "$CACHE_DIR/dotfiles"
sleep 1
clear

run_script "$COMMON_SCRIPTS/themes.sh"
run_script "$COMMON_SCRIPTS/${config_choice}.sh"

# ====================================
# Configuration du clavier
# ====================================
current_layout=$(localectl status | grep "Keymap" | awk '{print $3}')
log_message note "Configuration clavier actuelle : $current_layout"

prompt_confirm "Cette configuration vous convient-elle ?" "Oui, conserver" "Non, modifier"

if [[ $? -eq 1 ]]; then
    new_layout=$(localectl list-x11-keymap-layouts \
        | gum filter \
        --height 15 \
        --prompt="Rechercher : " \
        --cursor-text.foreground "$HEX_CYAN" \
        --indicator.foreground "$HEX_CYAN" \
        --placeholder "Tapez pour rechercher un layout..."
    )
    layout_to_apply="$new_layout"
else
    layout_to_apply="$current_layout"
fi

log_message done "Layout sélectionné : $layout_to_apply"

# Application de la configuration clavier
if [[ -d "$HOME/.config/hypr/confs" ]]; then
    config_file="$HOME/.config/hypr/confs/settings.conf"
elif [[ -d "$HOME/.config/hypr/configs" ]]; then
    config_file="$HOME/.config/hypr/configs/settings.conf"
fi

if [[ -f "$config_file" ]]; then
    sed -i "s/kb_layout = .*/kb_layout = $layout_to_apply/g" "$config_file"
    log_message done "Configuration clavier appliquée avec succès"
fi

sleep 1
clear

# ====================================
# Détection du type de système
# ====================================
if [[ -d "/sys/class/power_supply/BAT0" ]]; then
    system_type="laptop"
    log_message note "Système portable détecté"
else
    system_type="desktop"
    log_message note "Système de bureau détecté"
fi

run_script "$COMMON_SCRIPTS/${system_type}.sh"

sleep 1
clear

# ====================================
# Vérification finale
# ====================================
gum spin --spinner dot --title "Vérification finale du système..." -- sleep 3
clear

run_script "$INSTALL_SCRIPTS/12-final.sh"

# ====================================
# Redémarrage du système
# ====================================
echo
log_message done "Installation terminée avec succès !"
sleep 2
log_message warning "Un redémarrage est nécessaire pour activer Hyprland"
echo

prompt_confirm "Voulez-vous redémarrer maintenant ?" "Redémarrer" "Plus tard"

if [[ $? -eq 0 ]]; then
    clear
    for countdown in 3 2 1; do
        printf "${CLR_INFO}▸${CLR_RESET} Redémarrage dans ${countdown}s...\n"
        sleep 1
        clear
    done
    systemctl reboot
else
    log_message note "N'oubliez pas de redémarrer votre système !"
    log_message done "À bientôt !"
    exit 0
fi

# ====================================
# Fin du script
# ====================================