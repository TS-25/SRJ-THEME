#!/bin/bash
set -e

# Download all modules first
echo "Downloading installer modules..."
apt update 
apt install curl -y
curl -s https://raw.githubusercontent.com/TS-25/SRJ-THEME/refs/heads/main/core_setup.sh -o /tmp/core_setup.sh
curl -s https://raw.githubusercontent.com/TS-25/SRJ-THEME/refs/heads/main/panel_installer.sh -o /tmp/panel_installer.sh
curl -s https://raw.githubusercontent.com/TS-25/SRJ-THEME/refs/heads/main/theme_installer.sh -o /tmp/theme_installer.sh
curl -s https://raw.githubusercontent.com/TS-25/SRJ-THEME/refs/heads/main/addon_installer.sh -o /tmp/addon_installer.sh

# Source them
source /tmp/core_setup.sh
source /tmp/panel_installer.sh
source /tmp/theme_installer.sh
source /tmp/addon_installer.sh

# Run main menu
while true; do
    display_header
    show_main_menu
    read -rp "Select option: " main
    
    # ... rest of your main loop
done
