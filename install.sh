#!/bin/bash

set -e

# Source utility functions
source "$(dirname "$0")/scripts/common/utils.sh"

# Main menu
main() {
    echo -e "${GREEN}Linux Installation Script${NC}"
    echo "-------------------------"

    PS3="Please select an option: "
    options=("Install CLI Tools" "Install Docker" "Install Node.js" "Install Python" "Install Go & ghq" "Install Wine & Winetricks" "Install Self-Hosted Apps" "Setup Preferences" "Check Hardware" "Quit")
    
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
            "Install Python")
                bash "$(dirname "$0")/scripts/install-python.sh"
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
            "Install Self-Hosted Apps")
                echo "Select an app to install:"
                app_options=("Immich" "WordPress" "Growi" "Back")
                select app_opt in "${app_options[@]}"
                do
                    case $app_opt in
                        "Immich")
                            bash "$(dirname "$0")/scripts/apps/install-immich.sh"
                            break
                            ;;
                        "WordPress")
                            bash "$(dirname "$0")/scripts/apps/install-wordpress.sh"
                            break
                            ;;
                        "Growi")
                            bash "$(dirname "$0")/scripts/apps/install-growi.sh"
                            break
                            ;;
                        "Back")
                            break
                            ;;
                        *) echo "Invalid option $REPLY";;
                    esac
                done
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
