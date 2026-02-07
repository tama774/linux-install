#!/bin/bash

set -e

# Source utility functions
source "$(dirname "$0")/scripts/common/utils.sh"

# Main menu
main() {
    echo -e "${GREEN}Linux Installation Script${NC}"
    echo "-------------------------"

    PS3="Please select an option: "
    options=("Install CLI Tools" "Setup Preferences" "Check Hardware" "Quit")
    
    select opt in "${options[@]}"
    do
        case $opt in
            "Install CLI Tools")
                bash "$(dirname "$0")/scripts/install-cli.sh"
                ;;
            "Setup Preferences")
                bash "$(dirname "$0")/scripts/setup-preferences.sh"
                ;;
            "Check Hardware")
                warn "Hardware check not implemented yet."
                ;;
            "Quit")
                break
                ;;
            *) echo "Invalid option $REPLY";;
        esac
    done
}

main
