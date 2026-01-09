#!/bin/bash
#######################################################
# Fonctions d'interaction utilisateur pour Hyprland  #
# Configuration spécifique Fedora par Thibault       #
#######################################################

# Définition des couleurs
readonly CLR_ERROR="\e[1;31m"
readonly CLR_SUCCESS="\e[1;32m"
readonly CLR_WARNING="\e[1;33m"
readonly CLR_INFO="\e[1;34m"
readonly CLR_NOTICE="\e[1;35m"
readonly CLR_HIGHLIGHT="\e[1;36m"
readonly CLR_PROMPT="\e[38;5;214m"
readonly CLR_RESET="\e[0m"

# Définition des couleurs hexadécimales pour gum
readonly HEX_CYAN="#00FFFF"
readonly HEX_GREEN="#00FF00"
readonly HEX_ORANGE="#ff8700"

# Chemins de configuration
readonly SCRIPT_DIR="$(dirname "$(realpath "$0")")"
readonly CACHE_DIR="$SCRIPT_DIR/.cache"
readonly USER_PREFS="$CACHE_DIR/preferences"
readonly SHELL_CHOICE="$CACHE_DIR/shell-selection"

# Création du répertoire cache si nécessaire
[[ ! -d "$CACHE_DIR" ]] && mkdir -p "$CACHE_DIR"

# ============================================
# Fonctions d'interface utilisateur
# ============================================

# ============================================
# Fonctions d'interface utilisateur
# ============================================

# Affiche un message de bienvenue stylisé
show_welcome() {
    gum style \
        --foreground "$HEX_CYAN" \
        --border-foreground "$HEX_CYAN" \
        --border rounded \
        --align center \
        --width 90 \
        --margin "1 2" \
        --padding "1 2" \
    "Bienvenue dans le script" "d'installation Hyprland pour Fedora" "par" '
   _______ __     _ __                  __ __ 
  /_  __// /_   (_)/ /_   ____ _ __  __/ // /_
   / /  / __ \ / // __ \ / __ `// / / / // __/
  / /  / / / // // /_/ // /_/ // /_/ / // /_  
 /_/  /_/ /_//_//_.___/ \__,_/ \__,_/_/ \__/  
'
}

# Demande confirmation à l'utilisateur
prompt_confirm() {
    gum confirm "$1" \
        --prompt.foreground "$HEX_ORANGE" \
        --affirmative "${2:-Oui}" \
        --selected.background "$HEX_CYAN" \
        --selected.foreground "#000" \
        --negative "${3:-Non}"
}

# Affiche un message et quitte le script
exit_script() {
    gum spin --spinner line \
        --spinner.foreground "#FF0000" \
        --title "$1" \
        --title.foreground "#FF0000" -- \
        sleep 1
    exit 1
}

# Demande à l'utilisateur de sélectionner les options d'installation
select_features() {
    # Définition des options disponibles
    declare -gA feature_options=(
        ["configuration_bluetooth"]=""
        ["installer_vscode"]=""
        ["installer_navigateur"]=""
        ["drivers_nvidia"]=""
    )
    
    # Utilise gum pour capturer les sélections
    local selection
    selection=$(gum choose \
        --header "Sélectionnez avec la barre espace, validez avec Entrée" \
        --no-limit \
        --cursor.foreground "$HEX_CYAN" \
        --item.foreground "#fff" \
        --selected.foreground "$HEX_GREEN" \
        "${!feature_options[@]}")
    
    # Réinitialise toutes les options à 'non' par défaut
    for key in "${!feature_options[@]}"; do
        feature_options[$key]="non"
    done
    
    # Met à jour les options sélectionnées à 'oui'
    for key in $selection; do
        feature_options[$key]="oui"
    done
    
    # Sauvegarde les préférences dans le fichier cache
    > "$USER_PREFS"
    for key in "${!feature_options[@]}"; do
        echo "$key='${feature_options[$key]}'" >> "$USER_PREFS"
    done
}

# Demande à l'utilisateur de choisir son shell préféré
select_shell() {
    declare -gA shell_options=(
        ["installer_fish"]=""
        ["installer_zsh"]=""
        ["configurer_bash"]=""
    )
    
    local selection
    selection=$(gum choose \
        --header "Choisissez votre shell (un seul)" \
        --limit=1 \
        --cursor.foreground "$HEX_CYAN" \
        --item.foreground "#fff" \
        --selected.foreground "$HEX_GREEN" \
        "${!shell_options[@]}")
    
    # Réinitialise toutes les options
    for key in "${!shell_options[@]}"; do
        shell_options[$key]="non"
    done
    
    # Définit l'option sélectionnée
    for key in $selection; do
        shell_options[$key]="oui"
    done
    
    # Sauvegarde dans le fichier cache
    > "$SHELL_CHOICE"
    for key in "${!shell_options[@]}"; do
        echo "$key='${shell_options[$key]}'" >> "$SHELL_CHOICE"
    done
}

# Fonction d'affichage de messages formatés
log_message() {
    local type="$1"
    local message="$2"
    
    case "$type" in
        action)
            printf "${CLR_SUCCESS}▸${CLR_RESET} $message\n"
            ;;
        question)
            printf "${CLR_PROMPT}?${CLR_RESET} $message\n"
            ;;
        done)
            printf "${CLR_HIGHLIGHT}✓${CLR_RESET} $message\n\n"
            ;;
        warning)
            printf "${CLR_WARNING}!${CLR_RESET} $message\n"
            ;;
        note)
            printf "${CLR_INFO}ℹ${CLR_RESET} $message\n"
            ;;
        skip)
            printf "${CLR_NOTICE}⊳${CLR_RESET} $message\n"
            ;;
        error)
            printf "${CLR_ERROR}✗ Erreur :${CLR_RESET} $message\n"
            sleep 1
            ;;
        *)
            printf "$message\n"
            ;;
    esac
}