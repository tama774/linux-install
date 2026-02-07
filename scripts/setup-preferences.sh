#!/bin/bash

source "$(dirname "$0")/common/utils.sh"

setup_preferences() {
    info "Setting up user preferences..."

    # Swap Caps Lock and Control
    if grep -q "setxkbmap -option \"ctrl:swapcaps\"" "$HOME/.profile"; then
        info "Caps Lock/Control swap already configured in ~/.profile"
    else
        info "Configuring Caps Lock/Control swap in ~/.profile"
        echo '' >> "$HOME/.profile"
        echo '# Swap Caps Lock and Control' >> "$HOME/.profile"
        echo '/usr/bin/setxkbmap -option "ctrl:swapcaps"' >> "$HOME/.profile"
        info "Added setxkbmap to ~/.profile"
    fi

    info "User preferences setup complete."
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_preferences
fi
