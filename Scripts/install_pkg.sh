#!/usr/bin/env bash
#|---/ /+--------------------------------------+---/ /|#
#|--/ /-| Package Installation Script         |--/ /-|#
#|-/ /--| Fedora Hyprland Setup               |-/ /---|#
#|/ /---+--------------------------------------+/ /---|#

source "${scrDir}/global_fn.sh"

install_vscode() {
    if ! pkg_installed code; then
        print_info "Installation de VS Code..."
        sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
        sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
        sudo dnf install -y code
        print_success "VS Code installé"
    fi
}

install_chrome() {
    if ! pkg_installed google-chrome-stable; then
        print_info "Installation de Google Chrome..."
        sudo dnf install -y fedora-workstation-repositories
        sudo dnf config-manager --set-enabled google-chrome
        sudo dnf install -y google-chrome-stable
        print_success "Chrome installé"
    fi
}

install_flatpak_apps() {
    print_step "Installation des applications Flatpak..."
    
    local flatpak_file="${scrDir}/pkg_flatpak.lst"
    if [ ! -f "$flatpak_file" ]; then
        print_info "Aucune app Flatpak à installer"
        return 0
    fi
    
    # Read flatpak list
    while IFS= read -r app || [ -n "$app" ]; do
        # Skip comments and empty lines
        [[ "$app" =~ ^#.*$ ]] && continue
        [[ -z "$app" ]] && continue
        
        local app_name=$(echo "$app" | awk -F'.' '{print $NF}')
        if ! flatpak list | grep -q "$app"; then
            print_info "Installation de $app_name..."
            flatpak install -y flathub "$app"
            print_success "$app_name installé"
        else
            print_info "$app_name déjà installé"
        fi
    done < "$flatpak_file"
}

install_third_party() {
    print_step "Installation des applications tierces..."
    install_vscode
    install_chrome
    install_flatpak_apps
}

install_packages() {
    print_step "Installation des packages..."
    
    # Enable COPR for Hyprland
    enable_copr "solopasha/hyprland"
    
    # Enable Flatpak
    if ! command -v flatpak &>/dev/null; then
        print_info "Installation de Flatpak..."
        sudo dnf install -y flatpak
        flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    fi
    
    # Read package list
    local pkg_file="${scrDir}/pkg_core.lst"
    if [ ! -f "$pkg_file" ]; then
        print_error "Fichier $pkg_file introuvable"
        return 1
    fi
    
    # Filter out comments and empty lines
    local packages=$(grep -v '^#' "$pkg_file" | grep -v '^$' | tr '\n' ' ')
    
    print_info "Installation de $(echo "$packages" | wc -w) packages..."
    sudo dnf install -y $packages
    
    print_success "Packages installés"
}

install_multimedia() {
    print_step "Installation des codecs multimédia..."
    
    # RPM Fusion
    if ! pkg_installed rpmfusion-free-release; then
        print_info "Activation de RPM Fusion..."
        sudo dnf install -y \
            "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
            "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
    fi
    
    sudo dnf install -y \
        ffmpeg \
        gstreamer1-plugins-{bad-\*,good-\*,base} \
        gstreamer1-plugin-openh264 \
        gstreamer1-libav \
        lame\* \
        --exclude=gstreamer1-plugins-bad-free-devel
    
    sudo dnf group install -y multimedia || true
    
    print_success "Codecs multimédia installés"
}

install_nvidia() {
    print_step "Détection de carte NVIDIA..."
    
    if lspci | grep -i nvidia &>/dev/null; then
        print_info "Carte NVIDIA détectée!"
        read -p "Installer les drivers NVIDIA? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            sudo dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda
            print_success "Drivers NVIDIA installés - Redémarrage requis"
        fi
    else
        print_info "Aucune carte NVIDIA détectée"
    fi
}

main() {
    check_root
    check_fedora
    
    # System update
    print_step "Mise à jour du système..."
    sudo dnf update -y
    
    install_packages
    install_multimedia
    install_nvidia
    
    print_success "Installation des packages terminée"
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
    main "$@"
fi
