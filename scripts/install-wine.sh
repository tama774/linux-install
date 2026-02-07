#!/bin/bash

source "$(dirname "$0")/common/utils.sh"

install_wine() {
    local distro=$(detect_distro)
    info "Detected distribution: $distro"

    if [[ "$distro" != "ubuntu" && "$distro" != "debian" && "$distro" != "linuxmint" ]]; then
        error "Wine installation script currently supports Ubuntu, Debian, and Linux Mint only."
        return 1
    fi

    info "Enabling 32-bit architecture..."
    sudo dpkg --add-architecture i386

    info "Downloading and keying WineHQ repository key..."
    sudo mkdir -pm755 /etc/apt/keyrings
    sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key

    info "Adding WineHQ repository..."
    # Determine the correct version/codename for the repository
    local version_codename=""
    
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        if [[ "$distro" == "linuxmint" ]]; then
            version_codename="$UBUNTU_CODENAME"
        elif [[ "$distro" == "ubuntu" ]]; then
             version_codename="$VERSION_CODENAME"
        elif [[ "$distro" == "debian" ]]; then
             version_codename="$VERSION_CODENAME"
        fi
    fi
    
    if [ -z "$version_codename" ]; then
        error "Could not determine distribution codename for WineHQ repository."
        return 1
    fi

    info "Using codename: $version_codename"
    sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/$version_codename/winehq-$version_codename.sources
    
    # Check if download was successful, if not try simple method or warn
    if [ ! -f "/etc/apt/sources.list.d/winehq-$version_codename.sources" ]; then
         warn "Standard sources file download failed. Attempting to generate one manually."
         echo "Types: deb" | sudo tee /etc/apt/sources.list.d/winehq.sources
         echo "URIs: https://dl.winehq.org/wine-builds/ubuntu" | sudo tee -a /etc/apt/sources.list.d/winehq.sources
         echo "Suites: $version_codename" | sudo tee -a /etc/apt/sources.list.d/winehq.sources
         echo "Components: main" | sudo tee -a /etc/apt/sources.list.d/winehq.sources
         echo "Architectures: amd64 i386" | sudo tee -a /etc/apt/sources.list.d/winehq.sources
         echo "Signed-By: /etc/apt/keyrings/winehq-archive.key" | sudo tee -a /etc/apt/sources.list.d/winehq.sources
    fi

    info "Updating package database..."
    sudo apt-get update

    info "Installing Wine Stable..."
    sudo apt-get install -y --install-recommends winehq-stable

    info "Installing Winetricks..."
    if command -v winetricks &> /dev/null; then
        info "winetricks is already installed."
    else
        # sudo apt install -y winetricks # Repo version might be old
        # Recommend downloading latest script
        sudo wget -O /usr/local/bin/winetricks https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
        sudo chmod +x /usr/local/bin/winetricks
        sudo apt-get install -y cabextract # Dependency for some verbs
    fi
    
    info "Installing Japanese fonts (cjkfonts) via Winetricks (Silent)..."
    # This might take a while and might require X server or valid WINEPREFIX
    # Running in headless mode might be tricky for wine, but winetricks -q should try silent
    
    winetricks -q cjkfonts
    
    info "Wine and Winetricks installation complete."
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_wine
fi
