#!/bin/bash

source "$(dirname "$0")/common/utils.sh"

install_go() {
    info "Installing Go via goenv..."

    # Install dependencies for goenv/building go (if needed)
    # Usually goenv downloads binaries, so not much needed, but git is required.
    # We assume git is installed via install-cli.sh

    # Clone goenv
    if [ -d "$HOME/.goenv" ]; then
        info "goenv is already installed in ~/.goenv"
    else
        info "Cloning goenv..."
        git clone https://github.com/syndbg/goenv.git "$HOME/.goenv"
    fi

    # Configure shell
    local goenv_root="$HOME/.goenv"
    
    # Check for bash
    if [ -f "$HOME/.bashrc" ]; then
        if ! grep -q "goenv init" "$HOME/.bashrc"; then
            info "Configuring .bashrc..."
            echo '' >> "$HOME/.bashrc"
            echo '# goenv' >> "$HOME/.bashrc"
            echo 'export GOENV_ROOT="$HOME/.goenv"' >> "$HOME/.bashrc"
            echo 'export PATH="$GOENV_ROOT/bin:$PATH"' >> "$HOME/.bashrc"
            echo 'eval "$(goenv init -)"' >> "$HOME/.bashrc"
            echo 'export GOPATH="$HOME/go"' >> "$HOME/.bashrc"
            echo 'export PATH="$GOPATH/bin:$PATH"' >> "$HOME/.bashrc"
        fi
    fi

    # Check for zsh
    if [ -f "$HOME/.zshrc" ]; then
        if ! grep -q "goenv init" "$HOME/.zshrc"; then
            info "Configuring .zshrc..."
            echo '' >> "$HOME/.zshrc"
            echo '# goenv' >> "$HOME/.zshrc"
            echo 'export GOENV_ROOT="$HOME/.goenv"' >> "$HOME/.zshrc"
            echo 'export PATH="$GOENV_ROOT/bin:$PATH"' >> "$HOME/.zshrc"
            echo 'eval "$(goenv init -)"' >> "$HOME/.zshrc"
            echo 'export GOPATH="$HOME/go"' >> "$HOME/.zshrc"
            echo 'export PATH="$GOPATH/bin:$PATH"' >> "$HOME/.zshrc"
        fi
    fi

    # Load goenv for the current session
    export GOENV_ROOT="$HOME/.goenv"
    export PATH="$GOENV_ROOT/bin:$PATH"
    eval "$(goenv init -)"

    info "Installing latest Go..."
    # Get latest version from goenv install -l or just try to find a way to get latest
    # goenv install -l lists all versions.
    # A simple way is to use a specific version or try to grep the list.
    # users often want a specific recent version. Let's try to find the latest version.
    
    # This might show many versions. Let's pick a known recent major version or try to list and sort.
    # "goenv install latest" is supported in some versions but maybe not standard goenv?
    # syndbg/goenv supports 'latest' since 2.0.0beta?
    # Let's try to list and grep.
    
    local latest_version=$(goenv install -l | grep -E "^\s*[0-9]+\.[0-9]+\.[0-9]+$" | tail -1 | tr -d ' ')
    
    if [ -z "$latest_version" ]; then
       # Fallback if list fails or empty
       latest_version="1.22.0" 
       warn "Could not detect latest Go version. Installing fallback: $latest_version"
    else
       info "Detected latest version: $latest_version"
    fi

    if goenv versions | grep -q "$latest_version"; then
        info "Go $latest_version is already installed."
    else
        goenv install "$latest_version"
    fi
    
    goenv global "$latest_version"
    
    # Reload shell changes to get go command
    export PATH="$HOME/.goenv/versions/$latest_version/bin:$PATH"

    info "Installing ghq..."
    if command -v ghq &> /dev/null; then
        info "ghq is already installed."
    else
        go install github.com/x-motemen/ghq@latest
        info "ghq installed."
    fi

    info "Configuring 'g' alias for ghq+fzf..."
    local g_alias="alias g='cd \$(ghq root)/\$(ghq list | fzf)'"
    
    # Check for bash
    if [ -f "$HOME/.bashrc" ]; then
        if ! grep -q "alias g=" "$HOME/.bashrc"; then
            echo '' >> "$HOME/.bashrc"
            echo '# ghq + fzf alias' >> "$HOME/.bashrc"
            echo "$g_alias" >> "$HOME/.bashrc"
            info "Added 'g' alias to .bashrc"
        fi
    fi

    # Check for zsh
    if [ -f "$HOME/.zshrc" ]; then
        if ! grep -q "alias g=" "$HOME/.zshrc"; then
            echo '' >> "$HOME/.zshrc"
            echo '# ghq + fzf alias' >> "$HOME/.zshrc"
            echo "$g_alias" >> "$HOME/.zshrc"
            info "Added 'g' alias to .zshrc"
        fi
    fi

    info "Go and ghq installation complete."
    warn "Please restart your shell to apply changes."
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_go
fi
