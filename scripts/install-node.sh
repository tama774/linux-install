#!/bin/bash

# set -e  # Disable set -e because fnm installation might return non-zero if already installed or sourcing fails temporarily

source "$(dirname "$0")/common/utils.sh"

install_node() {
    info "Installing Node.js via fnm (Fast Node Manager)..."

    # Install fnm
    if command -v fnm &> /dev/null; then
        info "fnm is already installed."
    else
        info "Installing fnm..."
        curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell
    fi

    # Configure shell
    local fnm_dir="$HOME/.local/share/fnm"
    local shell_config=""
    
    # Check for bash
    if [ -f "$HOME/.bashrc" ]; then
        if ! grep -q "fnm env" "$HOME/.bashrc"; then
            info "Configuring .bashrc..."
            echo '' >> "$HOME/.bashrc"
            echo '# fnm' >> "$HOME/.bashrc"
            echo 'export PATH="'"$HOME"/.local/share/fnm:$PATH'"' >> "$HOME/.bashrc"
            echo 'eval "`fnm env`"' >> "$HOME/.bashrc"
        fi
    fi

    # Check for zsh
    if [ -f "$HOME/.zshrc" ]; then
        if ! grep -q "fnm env" "$HOME/.zshrc"; then
            info "Configuring .zshrc..."
            echo '' >> "$HOME/.zshrc"
            echo '# fnm' >> "$HOME/.zshrc"
            echo 'export PATH="'"$HOME"/.local/share/fnm:$PATH'"' >> "$HOME/.zshrc"
            echo 'eval "`fnm env`"' >> "$HOME/.zshrc"
        fi
    fi

    # Load fnm for the current session to install node
    export PATH="$HOME/.local/share/fnm:$PATH"
    eval "$(fnm env)"

    info "Installing Node.js LTS..."
    fnm install --lts
    fnm use --lts
    
    local node_version=$(node -v)
    info "Node.js $node_version installed successfully."
    
    warn "Please restart your shell or run 'source ~/.bashrc' (or ~/.zshrc) to use fnm/node in the current session."
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_node
fi
