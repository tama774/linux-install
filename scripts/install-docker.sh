#!/bin/bash

set -e

source "$(dirname "$0")/common/utils.sh"

install_docker() {
    local distro=$(detect_distro)
    
    info "Detected distribution: $distro"

    if [[ "$distro" != "ubuntu" && "$distro" != "debian" && "$distro" != "linuxmint" ]]; then
        error "Docker installation script currently supports Ubuntu, Debian, and Linux Mint only."
        return 1
    fi

    info "Installing Docker prerequisites..."
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl gnupg

    info "Adding Docker's official GPG key..."
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg

    info "Setting up the repository..."
    # Linux Mint is based on Ubuntu, so we use the ubuntu codename (focal, jammy, noble, etc.)
    # However, /etc/os-release on Mint gives UBUNTU_CODENAME which is what we need.
    # For pure Debian/Ubuntu, VERSION_CODENAME is usually what we want.
    
    source /etc/os-release
    local codename="$VERSION_CODENAME"
    
    if [[ "$distro" == "linuxmint" ]]; then
        codename="$UBUNTU_CODENAME"
    fi
    
    if [[ -z "$codename" ]]; then
         error "Could not determine distribution codename."
         return 1
    fi

    echo \
      "deb [arch=\"$(dpkg --print-architecture)\" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $codename stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    info "Installing Docker Engine..."
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    info "Adding user to docker group..."
    sudo usermod -aG docker "$USER"
    
    info "Docker installation complete."
    warn "You need to log out and log back in for group changes to take effect."
    warn "Or run 'newgrp docker' to activate the changes in the current shell."
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_docker
fi
