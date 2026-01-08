#!/usr/bin/env bash
#|---/ /+--------------------------------------+---/ /|#
#|--/ /-| Global Functions & Variables        |--/ /-|#
#|-/ /--| Fedora Hyprland Setup               |-/ /---|#
#|/ /---+--------------------------------------+/ /---|#

# Colors
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export PURPLE='\033[0;35m'
export CYAN='\033[0;36m'
export NC='\033[0m' # No Color

# Script directory
export scrDir="$(dirname "$(realpath "$0")")"
export cloneDir="$(dirname "${scrDir}")"

# Functions
print_step() {
    echo -e "${BLUE}==>${NC} ${GREEN}$1${NC}"
}

print_info() {
    echo -e "${YELLOW}==>${NC} $1"
}

print_error() {
    echo -e "${RED}ERROR:${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

check_root() {
    if [ "$EUID" -eq 0 ]; then
        print_error "Ne pas exécuter ce script en root!"
        exit 1
    fi
}

check_fedora() {
    if ! grep -q "Fedora" /etc/os-release; then
        print_error "Ce script est conçu pour Fedora uniquement"
        exit 1
    fi
    print_step "Détection: Fedora $(rpm -E %fedora)"
}

pkg_installed() {
    rpm -q "$1" &>/dev/null
}

enable_copr() {
    local repo="$1"
    if ! dnf copr list | grep -q "$repo"; then
        print_info "Activation du repository COPR: $repo"
        sudo dnf copr enable -y "$repo"
    fi
}
