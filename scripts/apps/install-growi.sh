#!/bin/bash

APP_DIR="$HOME/self-hosted/growi"

source "$(dirname "$0")/../common/utils.sh"

install_growi() {
    info "Setting up Growi in $APP_DIR..."

    if [ -d "$APP_DIR" ]; then
        warn "Directory $APP_DIR already exists."
        read -p "Do you want to overwrite configuration files? (y/N): " overwrite
        if [[ "$overwrite" != "y" && "$overwrite" != "Y" ]]; then
            info "Aborting setup."
            return 0
        fi
    fi
    mkdir -p "$APP_DIR"

    info "Cloning official Growi Docker Compose repository..."
    if ! git clone https://github.com/growilabs/growi-docker-compose.git "$APP_DIR"; then
        error "Failed to clone repository."
        return 1
    fi

    info "Configuring Growi..."
    
    # modify docker-compose.yml to listen on all interfaces (remove 127.0.0.1 if present)
    # The official repo might set ports: - 127.0.0.1:3000:3000
    # We want ports: - 3000:3000
    if [ -f "$APP_DIR/docker-compose.yml" ]; then
        sed -i 's/127.0.0.1:3000:3000/3000:3000/g' "$APP_DIR/docker-compose.yml"
        info "Updated docker-compose.yml to allow external access."
    fi

    # Check for max_map_count for Elasticsearch
    local current_max_map_count=$(sysctl -n vm.max_map_count)
    if [ "$current_max_map_count" -lt 262144 ]; then
        warn "Elasticsearch requires vm.max_map_count to be at least 262144."
        warn "Current value: $current_max_map_count"
        warn "Please run 'sudo sysctl -w vm.max_map_count=262144' and add it to /etc/sysctl.conf"
    fi

    info "Growi Setup complete."
    info "Directory: $APP_DIR"
    echo ""
    echo "To start Growi, run:"
    echo -e "${GREEN}  cd $APP_DIR && docker compose up -d${NC}"
    echo ""
    echo "Then access: http://localhost:3000"
    echo "Wait a few minutes for the initial startup (Elasticsearch build may take time)."
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_growi
fi
