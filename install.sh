#!/bin/bash

set -e

# Source utility functions
source "$(dirname "$0")/scripts/common/utils.sh"

# Main menu
main() {
    echo -e "${GREEN}Linux Installation Script${NC}"
    echo "-------------------------"

    PS3="Please select an option: "
    options=("Install CLI Tools" "Install Docker" "Setup Preferences" "Check Hardware" "Quit")
    
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
