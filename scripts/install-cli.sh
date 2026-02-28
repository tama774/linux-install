#!/bin/bash

source "$(dirname "$0")/common/utils.sh"

install_cli_tools() {
    local distro=$(detect_distro)
    local packages="git curl wget vim emacs htop tmux zsh smartmontools tlp imagemagick fzf jq xclip build-essential"

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

    info "Configuring pbcopy/pbpaste aliases..."
    local pbcopy_alias="alias pbcopy='xclip -selection clipboard'"
    local pbpaste_alias="alias pbpaste='xclip -selection clipboard -o'"

    # Check for bash
    if [ -f "$HOME/.bashrc" ]; then
        if ! grep -q "alias pbcopy=" "$HOME/.bashrc"; then
            echo '' >> "$HOME/.bashrc"
            echo '# pbcopy/pbpaste aliases' >> "$HOME/.bashrc"
            echo "$pbcopy_alias" >> "$HOME/.bashrc"
            echo "$pbpaste_alias" >> "$HOME/.bashrc"
            info "Added pbcopy/pbpaste aliases to .bashrc"
        fi
    fi

    # Check for zsh
    if [ -f "$HOME/.zshrc" ]; then
        if ! grep -q "alias pbcopy=" "$HOME/.zshrc"; then
            echo '' >> "$HOME/.zshrc"
            echo '# pbcopy/pbpaste aliases' >> "$HOME/.zshrc"
            echo "$pbcopy_alias" >> "$HOME/.zshrc"
            echo "$pbpaste_alias" >> "$HOME/.zshrc"
            info "Added pbcopy/pbpaste aliases to .zshrc"
        fi
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_cli_tools
fi
