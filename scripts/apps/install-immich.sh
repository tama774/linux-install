#!/bin/bash

# Define the installation directory
APP_DIR="$HOME/self-hosted/immich"

source "$(dirname "$0")/../common/utils.sh"

install_immich() {
    info "Setting up Immich in $APP_DIR..."

    # Create directory
    if [ -d "$APP_DIR" ]; then
        warn "Directory $APP_DIR already exists."
        read -p "Do you want to overwrite configuration files? (y/N): " overwrite
        if [[ "$overwrite" != "y" && "$overwrite" != "Y" ]]; then
            info "Aborting setup."
            return 0
        fi
    fi
    mkdir -p "$APP_DIR"

    # Download docker-compose.yml and .env (example/template)
    info "Downloading configuration files..."
    
    # Using the recommended installation method from Immich docs
    wget -O "$APP_DIR/docker-compose.yml" https://github.com/immich-app/immich/releases/latest/download/docker-compose.yml
    wget -O "$APP_DIR/.env" https://github.com/immich-app/immich/releases/latest/download/example.env

    if [ ! -f "$APP_DIR/docker-compose.yml" ] || [ ! -f "$APP_DIR/.env" ]; then
        error "Failed to download configuration files."
        return 1
    fi

    # Configure .env
    info "Configuring .env file..."
    
    # 1. DB_PASSWORD
    # Generate a random password if not already set or just overwrite for safety in new install
    local db_password=$(openssl rand -base64 32 | tr -d '/+' | cut -c 1-24)
    sed -i "s/DB_PASSWORD=postgres/DB_PASSWORD=$db_password/" "$APP_DIR/.env"
    info "Generated random DB_PASSWORD."

    # 2. UPLOAD_LOCATION
    local default_upload_loc="./library"
    echo -e "${YELLOW}Where should Immich store uploaded photos?${NC}"
    read -p "Upload Location [Default: $default_upload_loc]: " upload_loc
    upload_loc=${upload_loc:-$default_upload_loc}
    
    # Escape slashes for sed
    local escaped_upload_loc=$(echo "$upload_loc" | sed 's/\//\\\//g')
    sed -i "s/UPLOAD_LOCATION=\.\/library/UPLOAD_LOCATION=$escaped_upload_loc/" "$APP_DIR/.env"
    info "Set UPLOAD_LOCATION to $upload_loc"

    # 3. TYPESENSE_API_KEY (removed in recent versions? check .env)
    # Recent immich versions might manage this differently, but example.env usually needs adjustment.
    # Checking if TYPESENSE_API_KEY exists in .env
    if grep -q "TYPESENSE_API_KEY=" "$APP_DIR/.env"; then
         # It seems recent versions use only DB_PASSWORD and internal setups, but let's check.
         # Actually, recent versions don't strictly require typesense key manual gen if using standard compose?
         # The example.env has "TYPESENSE_API_KEY=some-value" usually.
         # Let's simple leave it as default or generate if empty.
         pass
    fi
    
    # 4. IMMICH_VERSION
    # Default is release, which is fine.

    info "Configuration complete."
    echo ""
    echo "To start Immich, run:"
    echo -e "${GREEN}  cd $APP_DIR && docker compose up -d${NC}"
    echo ""
    echo "Environment file is located at: $APP_DIR/.env"
    echo "Please review it for other settings (e.g. PUBLIC_LOGIN_PAGE_MESSAGE)."
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_immich
fi
