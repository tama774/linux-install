#!/bin/bash

APP_DIR="$HOME/self-hosted/wordpress"

source "$(dirname "$0")/../common/utils.sh"

install_wordpress() {
    info "Setting up WordPress in $APP_DIR..."

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

    # Generate random passwords
    local db_root_password=$(openssl rand -base64 32 | tr -d '/+' | cut -c 1-24)
    local db_password=$(openssl rand -base64 32 | tr -d '/+' | cut -c 1-24)
    local db_user="wordpress"
    local db_name="wordpress"

    # Create .env
    cat <<EOF > "$APP_DIR/.env"
# WordPress Environment Variables
WORDPRESS_DB_HOST=db
WORDPRESS_DB_USER=$db_user
WORDPRESS_DB_PASSWORD=$db_password
WORDPRESS_DB_NAME=$db_name
WORDPRESS_PORT=8080

# Database Environment Variables
MYSQL_ROOT_PASSWORD=$db_root_password
MYSQL_DATABASE=$db_name
MYSQL_USER=$db_user
MYSQL_PASSWORD=$db_password
EOF

    # Create docker-compose.yml
    cat <<EOF > "$APP_DIR/docker-compose.yml"
services:
  wordpress:
    image: wordpress:latest
    restart: always
    ports:
      - "\${WORDPRESS_PORT}:80"
    environment:
      WORDPRESS_DB_HOST: \${WORDPRESS_DB_HOST}
      WORDPRESS_DB_USER: \${WORDPRESS_DB_USER}
      WORDPRESS_DB_PASSWORD: \${WORDPRESS_DB_PASSWORD}
      WORDPRESS_DB_NAME: \${WORDPRESS_DB_NAME}
    volumes:
      - wp_data:/var/www/html
    depends_on:
      - db

  db:
    image: mariadb:latest
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: \${MYSQL_ROOT_PASSWORD}
      MYSQL_DATABASE: \${MYSQL_DATABASE}
      MYSQL_USER: \${MYSQL_USER}
      MYSQL_PASSWORD: \${MYSQL_PASSWORD}
    volumes:
      - db_data:/var/lib/mysql

volumes:
  wp_data:
  db_data:
EOF

    if [ ! -f "$APP_DIR/docker-compose.yml" ] || [ ! -f "$APP_DIR/.env" ]; then
        error "Failed to create configuration files."
        return 1
    fi

    info "WordPress Setup complete."
    info "Directory: $APP_DIR"
    echo ""
    echo "To start WordPress, run:"
    echo -e "${GREEN}  cd $APP_DIR && docker compose up -d${NC}"
    echo ""
    echo "Then access: http://localhost:8080"
    echo "Database Password and other settings are in: $APP_DIR/.env"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_wordpress
fi
