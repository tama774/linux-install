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

    info "Generating configuration files..."

    # Generate random password seed
    local password_seed=$(openssl rand -base64 32 | tr -d '/+' | cut -c 1-32)

    # Create .env
    cat <<EOF > "$APP_DIR/.env"
# Growi Environment Variables
PORT=3000
Start=3000
PASSWORD_SEED=$password_seed
MONGO_URI=mongodb://mongo:27017/growi
ELASTICSEARCH_URI=http://elasticsearch:9200/growi

# Docker Compose Variables
FILE_UPLOAD=local
EOF

    # Create docker-compose.yml
    # Based on official examples, simplified for single-node self-hosted
    cat <<EOF > "$APP_DIR/docker-compose.yml"
services:
  app:
    image: weseek/growi:latest
    ports:
      - 3000:3000
    links:
      - mongo:mongo
      - elasticsearch:elasticsearch
    depends_on:
      - mongo
      - elasticsearch
    environment:
      - MONGO_URI=\${MONGO_URI}
      - ELASTICSEARCH_URI=\${ELASTICSEARCH_URI}
      - PASSWORD_SEED=\${PASSWORD_SEED}
      - FILE_UPLOAD=\${FILE_UPLOAD}
      # - MATHJAX=1             # MathJax support
      # - PLANTUML_URI=http://  # PlantUML support
      # - HACKMD_URI=http://    # HackMD support
    entrypoint: "docker-entrypoint.sh"
    command: ["yarn", "run", "server:prod"]
    restart: unless-stopped
    volumes:
      - growi_data:/data

  mongo:
    image: mongo:6.0
    restart: unless-stopped
    volumes:
      - mongo_configdb:/data/configdb
      - mongo_db:/data/db

  elasticsearch:
    image: weseek/elasticsearch-ik:8.15.3
    restart: unless-stopped
    environment:
      - bootstrap.memory_lock=true
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"  # Adjust heap size as needed
      - discovery.type=single-node
      - xpack.security.enabled=false
    ulimits:
      memlock:
        soft: -1
        hard: -1
    volumes:
      - es_data:/usr/share/elasticsearch/data

volumes:
  growi_data:
  mongo_configdb:
  mongo_db:
  es_data:
EOF

    if [ ! -f "$APP_DIR/docker-compose.yml" ] || [ ! -f "$APP_DIR/.env" ]; then
        error "Failed to create configuration files."
        return 1
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
    echo "Wait a few minutes for the initial startup."
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_growi
fi
