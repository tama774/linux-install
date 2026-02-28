#!/bin/bash

# Disable set -e because pyenv init sourcing may return non-zero temporarily
# set -e

source "$(dirname "$0")/common/utils.sh"

PYTHON_VERSION="3.13.12"

install_python() {
    info "Installing Python environment via pyenv..."

    # Install build dependencies
    local distro
    distro=$(detect_distro)
    info "Detected distro: $distro"

    case "$distro" in
        ubuntu|debian)
            info "Installing build dependencies..."
            sudo apt-get update -y
            sudo apt-get install -y \
                build-essential \
                libssl-dev \
                zlib1g-dev \
                libbz2-dev \
                libreadline-dev \
                libsqlite3-dev \
                curl \
                libncurses5-dev \
                libncursesw5-dev \
                xz-utils \
                tk-dev \
                libxml2-dev \
                libxmlsec1-dev \
                libffi-dev \
                liblzma-dev \
                uuid-dev \
                git
            ;;
        fedora|rhel|centos)
            info "Installing build dependencies..."
            sudo dnf install -y \
                gcc \
                zlib-devel \
                bzip2 bzip2-devel \
                readline-devel \
                sqlite sqlite-devel \
                openssl-devel \
                tk-devel \
                libffi-devel \
                xz-devel \
                git
            ;;
        arch)
            info "Installing build dependencies..."
            sudo pacman -S --noconfirm \
                base-devel \
                openssl \
                zlib \
                xz \
                tk \
                git
            ;;
        *)
            warn "Unknown distro '$distro'. Skipping build dependency installation."
            ;;
    esac

    # Install pyenv
    if command -v pyenv &> /dev/null; then
        info "pyenv is already installed ($(pyenv --version))."
    else
        info "Installing pyenv..."
        curl -fsSL https://pyenv.run | bash
    fi

    # Configure shell for pyenv
    local pyenv_init_block
    read -r -d '' pyenv_init_block << 'EOF'

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
EOF

    if [ -f "$HOME/.bashrc" ]; then
        if ! grep -q 'PYENV_ROOT' "$HOME/.bashrc"; then
            info "Configuring .bashrc for pyenv..."
            echo "$pyenv_init_block" >> "$HOME/.bashrc"
        fi
    fi

    if [ -f "$HOME/.zshrc" ]; then
        if ! grep -q 'PYENV_ROOT' "$HOME/.zshrc"; then
            info "Configuring .zshrc for pyenv..."
            echo "$pyenv_init_block" >> "$HOME/.zshrc"
        fi
    fi

    # Load pyenv for the current session
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"

    # Install Python
    if pyenv versions --bare | grep -q "^${PYTHON_VERSION}$"; then
        info "Python ${PYTHON_VERSION} is already installed."
    else
        info "Installing Python ${PYTHON_VERSION} (this may take a while)..."
        pyenv install "${PYTHON_VERSION}"
    fi

    info "Setting Python ${PYTHON_VERSION} as global default..."
    pyenv global "${PYTHON_VERSION}"

    local py_version
    py_version=$(python --version 2>&1)
    info "$py_version is now the global Python."

    # Install Poetry
    if command -v poetry &> /dev/null; then
        info "Poetry is already installed ($(poetry --version))."
    else
        info "Installing Poetry via official installer..."
        curl -sSL https://install.python-poetry.org | python -
    fi

    # Configure shell for Poetry
    local poetry_path_line
    poetry_path_line='export PATH="$HOME/.local/bin:$PATH"'

    if [ -f "$HOME/.bashrc" ]; then
        if ! grep -q '.local/bin' "$HOME/.bashrc"; then
            info "Adding ~/.local/bin to PATH in .bashrc..."
            echo '' >> "$HOME/.bashrc"
            echo '# Poetry' >> "$HOME/.bashrc"
            echo "$poetry_path_line" >> "$HOME/.bashrc"
        fi
    fi

    if [ -f "$HOME/.zshrc" ]; then
        if ! grep -q '.local/bin' "$HOME/.zshrc"; then
            info "Adding ~/.local/bin to PATH in .zshrc..."
            echo '' >> "$HOME/.zshrc"
            echo '# Poetry' >> "$HOME/.zshrc"
            echo "$poetry_path_line" >> "$HOME/.zshrc"
        fi
    fi

    export PATH="$HOME/.local/bin:$PATH"

    local poetry_version
    poetry_version=$(poetry --version 2>&1)
    info "$poetry_version installed successfully."

    info "Python environment setup complete!"
    warn "Please restart your shell or run 'source ~/.bashrc' (or ~/.zshrc) to use pyenv/poetry in all sessions."
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_python
fi
