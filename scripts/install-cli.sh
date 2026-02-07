#!/bin/bash

source "$(dirname "$0")/common/utils.sh"

install_cli_tools() {
    local distro=$(detect_distro)
    local packages="git curl wget vim emacs htop tmux zsh smartmontools tlp imagemagick"

    info "Detected distribution: $distro"
    info "Installing CLI tools: $packages"

    case "$distro" in
        ubuntu|debian|linuxmint)
            sudo apt update
            sudo apt install -y $packages
            ;;
        arch)
            sudo pacman -Syu --noconfirm $packages
            ;;
        *)
            error "Unsupported distribution: $distro"
            exit 1
            ;;
    esac

    info "CLI tools installation complete."
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_cli_tools
fi
