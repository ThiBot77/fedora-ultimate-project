#!/usr/bin/env bash
#|---/ /+--------------------------------------+---/ /|#
#|--/ /-| Configuration Restore Script        |--/ /-|#
#|-/ /--| Fedora Hyprland Setup               |-/ /---|#
#|/ /---+--------------------------------------+/ /---|#

source "${scrDir}/global_fn.sh"

restore_configs() {
    print_step "Restauration des configurations..."
    
    local cfg_src="${cloneDir}/Configs/.config"
    
    if [ ! -d "$cfg_src" ]; then
        print_error "Dossier Configs introuvable: $cfg_src"
        return 1
    fi
    
    # Create config directories
    mkdir -p ~/.config/{hypr,waybar,rofi,dunst,kitty,swappy}
    mkdir -p ~/.local/share/wallpapers
    mkdir -p ~/Pictures/Screenshots
    
    # Copy configs
    print_info "Copie des configurations..."
    
    if [ -d "$cfg_src/hypr" ]; then
        cp -r "$cfg_src/hypr/"* ~/.config/hypr/
        print_success "Config Hyprland copiée"
    fi
    
    if [ -d "$cfg_src/waybar" ]; then
        cp -r "$cfg_src/waybar/"* ~/.config/waybar/
        print_success "Config Waybar copiée"
    fi
    
    if [ -d "$cfg_src/kitty" ]; then
        cp -r "$cfg_src/kitty/"* ~/.config/kitty/
        print_success "Config Kitty copiée"
    fi
    
    print_success "Configurations restaurées"
}

setup_shell() {
    print_step "Configuration du shell..."
    
    # Set zsh as default shell
    if [ "$SHELL" != "$(which zsh)" ]; then
        print_info "Changement du shell par défaut vers ZSH..."
        chsh -s "$(which zsh)"
        print_success "Shell changé vers ZSH"
    else
        print_info "ZSH déjà configuré comme shell par défaut"
    fi
}

setup_gdm() {
    print_step "Configuration de GDM pour Hyprland..."
    
    sudo tee /usr/share/wayland-sessions/hyprland.desktop > /dev/null << 'EOF'
[Desktop Entry]
Name=Hyprland
Comment=An intelligent dynamic tiling Wayland compositor
Exec=uwsm start hyprland-uwsm.desktop
Type=Application
DesktopNames=Hyprland
EOF
    
    print_success "Session Hyprland configurée dans GDM"
}

main() {
    check_root
    
    restore_configs
    setup_shell
    setup_gdm
    
    print_success "Restauration des configurations terminée"
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
    main "$@"
fi
