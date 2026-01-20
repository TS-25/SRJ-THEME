#!/bin/bash
set -e

# ========= COLORS =========
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
PURPLE='\033[1;35m'
CYAN='\033[1;36m'
NC='\033[0m'

clear

echo "  _______               _      "
echo " |__   __|             (_)     "
echo "    | | __ _ _ ____   ___ _ __ "
echo "    | |/ _\` | '_ \\ \\ / / | '__|"
echo "    | | (_| | | | \\ V /| | |   "
echo "    |_|\\__,_|_| |_|\\_/ |_|_|   "
echo "                               "
echo "         Installer Script      "
echo "==============================="
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# ========= WARNING =========
warning() {
    echo -e "${RED}⚠ WARNING ⚠${NC}"
    echo -e "${YELLOW}This installation may overwrite panel files."
    echo -e "Your panel may become FRESH/RESET."
    echo -e "Please ensure you have a FULL BACKUP.${NC}"
    echo
    read -rp "Continue? (yes/no): " c
    case $c in
        yes|y|Y) ;;
        *) echo -e "${RED}Cancelled.${NC}"; exit 1 ;;
    esac
}

# ========= PANEL PATH AUTO DETECT =========
detect_panel_path() {
    if [ -d "/var/www/pterodactyl" ]; then
        PANEL_PATH="/var/www/pterodactyl"
    elif [ -d "/var/www/reviactyl" ]; then
        PANEL_PATH="/var/www/reviactyl"
    else
        echo -e "${RED}❌ No valid panel path found.${NC}"
        exit 1
    fi
    echo -e "${GREEN}✔ Panel detected at: ${PANEL_PATH}${NC}"
}

# ========= PANELS =========
install_reviactyl() {
    bash <(curl -s https://raw.githubusercontent.com/TS-25/SRJ-THEME/refs/heads/main/reviactyl)
}

# ========= BLUEPRINT =========
install_blueprint() {
    warning
    apt install curl git -y
    bash <(curl -s https://raw.githubusercontent.com/TS-25/SRJ-THEME/refs/heads/main/blueprint)
}

# ========= ADDON HELPER =========
install_addon() {
    detect_panel_path
    cd "$PANEL_PATH"
    wget -O "$1.blueprint" "$2"
    blueprint -install "$1"
}

# ========= ADDONS =========
install_mclogs() {
    install_addon "mclogs" "https://github.com/TS-25/SRJ-THEME/releases/latest/download/mclogs.blueprint"
}

install_bluetables() {
    install_addon "bluetables" "https://github.com/TS-25/SRJ-THEME/releases/latest/download/bluetables.blueprint"
}

install_mctools() {
    install_addon "mctools" "https://github.com/TS-25/SRJ-THEME/releases/latest/download/mctools.blueprint"
}

install_tsimplefooters() {
    install_addon "tsimplefooters" "https://github.com/TS-25/SRJ-THEME/releases/latest/download/tsimplefooters.blueprint"
}

install_votifiertester() {
    warning
    detect_panel_path
    cd "$PANEL_PATH"
    composer require leonardorrc/votifier-client-php
    wget -O votifiertester.blueprint https://github.com/TS-25/SRJ-THEME/releases/latest/download/votifiertester.blueprint
    blueprint -install votifiertester
}

# ========= MENU =========
while true; do
    echo ""
    echo "1) Install Panels"
    echo "2) Install Blueprint"
    echo "3) Install Addons"
    echo "4) Exit"
    read -rp "Select option: " main

    case $main in
        1)
            echo "1) Install Reviactyl"
            read -rp "Choose panel: " p
            case $p in
                1) install_reviactyl ;;
            esac
            ;;
        2) install_blueprint ;;
        3)
            echo "---- ADDONS ----"
            echo "1) MC Logs"
            echo "2) Blue Tables"
            echo "3) MC Tools"
            echo "4) TSimple Footers"
            echo "5) Votifier Tester"
            read -rp "Choose addon: " a
            case $a in
                1) install_mclogs ;;
                2) install_bluetables ;;
                3) install_mctools ;;
                4) install_tsimplefooters ;;
                5) install_votifiertester ;;
            esac
            ;;
        4) exit 0 ;;
    esac
done
