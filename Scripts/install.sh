#!/usr/bin/env bash
#|---/ /+--------------------------------------+---/ /|#
#|--/ /-| Main Installation Script            |--/ /-|#
#|-/ /--| Fedora Hyprland Setup               |-/ /---|#
#|/ /---+--------------------------------------+/ /---|#

cat <<"EOF"

-------------------------------------------------
    ___        _                ___        _         
   | __>___ __| | ___  _ _ ___ | . \ _ __ <_> ___  _ 
   | _>/ ._> _` |/ . \| '_> _ \|   /| | | | |/ ._>| |
   |_| \___.|___|\___/|_| \__,|_\_\ `___|_|\___.|_|
                                                     
    Fedora Workstation + Hyprland Ultimate Setup
-------------------------------------------------

EOF

# Import functions
scrDir="$(dirname "$(realpath "$0")")"
source "${scrDir}/global_fn.sh"

# Parse options
flg_Install=0
flg_Restore=0

while getopts "irh" opt; do
    case $opt in
        i) flg_Install=1 ;;
        r) flg_Restore=1 ;;
        h)
            cat <<HELP
Usage: $0 [options]
    -i : [i]nstall packages
    -r : [r]estore configurations
    -h : show this [h]elp

NOTE:
    Sans arguments = -i -r (installation complète)

HELP
            exit 0
            ;;
        *)
            echo "Option invalide. Utilise -h pour l'aide"
            exit 1
            ;;
    esac
done

# Default: full install
if [ $OPTIND -eq 1 ]; then
    flg_Install=1
    flg_Restore=1
fi

main() {
    check_root
    check_fedora
    
    print_step "Début de l'installation Fedora Ultimate Hyprland"
    echo
    
    # Install packages
    if [ $flg_Install -eq 1 ]; then
        source "${scrDir}/install_pkg.sh"
    fi
    
    # Restore configs
    if [ $flg_Restore -eq 1 ]; then
        source "${scrDir}/restore_cfg.sh"
    fi
    
    echo
    print_success "Installation terminée!"
    echo
    print_info "Pour démarrer Hyprland:"
    print_info "  1. Déconnecte-toi (logout)"
    print_info "  2. Sélectionne 'Hyprland' dans GDM"
    print_info "  3. Connecte-toi"
    echo
    print_info "Raccourcis principaux:"
    print_info "  SUPER + T = Terminal (Kitty + zsh)"
    print_info "  SUPER + A = Lanceur d'apps"
    print_info "  SUPER + & é \" ' ( - è _ ç à = Workspaces 1-10"
    echo
    print_info "Config dans ~/.config/hypr/"
    echo
}

main "$@"
