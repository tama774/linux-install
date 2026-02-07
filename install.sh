#!/bin/bash

set -e

# Source utility functions
source "$(dirname "$0")/scripts/common/utils.sh"

# Main menu
main() {
    echo -e "${GREEN}Linux Installation Script${NC}"
    echo "-------------------------"

    PS3="Please select an option: "
    options=("Install CLI Tools" "Install Docker" "Install Node.js" "Install Go & ghq" "Install Wine & Winetricks" "Setup Preferences" "Check Hardware" "Quit")
    
    select opt in "${options[@]}"
    do
        case $opt in
            "Install CLI Tools")
                bash "$(dirname "$0")/scripts/install-cli.sh"
                break
                ;;
            "Setup Preferences")
                bash "$(dirname "$0")/scripts/setup-preferences.sh"
                break
                ;;
            "Install Docker")
                bash "$(dirname "$0")/scripts/install-docker.sh"
                break
                ;;
            "Install Node.js")
                bash "$(dirname "$0")/scripts/install-node.sh"
                break
                ;;
            "Install Go & ghq")
                bash "$(dirname "$0")/scripts/install-go.sh"
                break
                ;;
            "Install Go & ghq")
                bash "$(dirname "$0")/scripts/install-go.sh"
                break
                ;;
            "Install Wine & Winetricks")
                bash "$(dirname "$0")/scripts/install-wine.sh"
                break
                ;;
            "Check Hardware")
                bash "$(dirname "$0")/scripts/check-hardware.sh"
                break
                ;;
            "Quit")
                break
                ;;
            *) echo "Invalid option $REPLY";;
        esac
    done
}

main
