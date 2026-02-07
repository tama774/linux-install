#!/bin/bash

source "$(dirname "$0")/common/utils.sh"

REPORT_DIR="hardware_reports"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
REPORT_FILE="$REPORT_DIR/report_$TIMESTAMP.txt"

check_hardware() {
    mkdir -p "$REPORT_DIR"
    
    info "Starting hardware check..."
    info "Report will be saved to: $REPORT_FILE"

    {
        echo "=========================================="
        echo " Hardware Report - $TIMESTAMP"
        echo "=========================================="
        echo ""
        
        echo "--- System Information ---"
        hostnamectl || echo "hostnamectl not available"
        echo ""

        echo "--- CPU Information ---"
        lscpu | grep -E 'Model name|Socket|Thread|Core|MHz' || echo "lscpu not available"
        echo ""

        echo "--- Memory Information ---"
        free -h
        echo ""

        echo "--- Disk Usage ---"
        df -h
        echo ""

        echo "--- Block Devices ---"
        lsblk -o NAME,MODEL,SIZE,TYPE,FSTYPE
        echo ""

        echo "--- Network Devices ---"
        ip -br addr || ip addr
        echo ""

        echo "--- PCI Devices (VGA/Network) ---"
        lspci | grep -E 'VGA|Network|Ethernet' || echo "lspci not available"
        echo ""

        if command -v sensors &> /dev/null; then
            echo "--- Temperatures (sensors) ---"
            sensors
            echo ""
        fi

        if command -v smartctl &> /dev/null; then
            echo "--- SMART Status (sda) ---"
            sudo smartctl -H /dev/sda || echo "smartctl failed for /dev/sda"
            echo ""
            # Add more drives as loop if needed
        else
            echo "--- SMART Status ---"
            echo "smartmontools not installed. Install it to check drive health."
        fi

        echo "=========================================="
        echo " End of Report"
        echo "=========================================="

    } | tee "$REPORT_FILE"

    info "Hardware check complete. Report saved."
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    check_hardware
fi
