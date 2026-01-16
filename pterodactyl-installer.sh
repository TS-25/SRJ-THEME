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

warning() {
    echo -e "${RED}⚠ WARNING ⚠${NC}"
    echo -e "${YELLOW}This installation may overwrite panel files."
    echo -e "Your Pterodactyl panel may become FRESH/RESET."
    echo -e "Please ensure you have a FULL BACKUP.${NC}"
    echo
    read -rp "Continue? (yes/no): " c
    case $c in
        yes|y|Y) ;;
        *) echo -e "${RED}Cancelled.${NC}"; exit 1 ;;
    esac
}

# -------- PANELS --------
install_reviactyl() {
    warning
    bash <(curl -s https://raw.githubusercontent.com/TS-25/SRJ-THEME/refs/heads/main/reviactyl)
}

# -------- BLUEPRINT --------
install_blueprint() {
    warning
    apt install curl git -y
    bash <(curl -s https://raw.githubusercontent.com/TS-25/SRJ-THEME/refs/heads/main/blueprint)
}

# -------- THEMES --------
install_nebula() {
    warning
    cd /var/www/pterodactyl || exit 1
    wget -O nebula.blueprint https://github.com/TS-25/SRJ-THEME/releases/latest/download/nebula.blueprint
    blueprint -install nebula
}

install_euphoria() {
    warning
    cd /var/www/pterodactyl || exit 1
    wget -O euphoriatheme.blueprint https://github.com/TS-25/SRJ-THEME/releases/latest/download/euphoriatheme.blueprint
    blueprint -install euphoriatheme
}

install_revix() {
    warning
    bash <(curl -s https://raw.githubusercontent.com/TS-25/SRJ-THEME/refs/heads/main/revix-theme)
}

install_arix() {
    echo -e "${GREEN}Installing ARIX Theme v1.3.1...${NC}"
    bash <(curl -s https://raw.githubusercontent.com/TS-25/arix/refs/heads/main/arix)
}

install_reviactyl_blueprint() {
    warning
    bash <(curl -s https://raw.githubusercontent.com/TS-25/SRJ-THEME/refs/heads/main/reviactyl-blueprint)
}

# -------- ADDONS --------
install_mcplugins() {
    cd /var/www/pterodactyl || exit 1
    wget -O mcplugins.blueprint https://github.com/TS-25/SRJ-THEME/releases/latest/download/mcplugins.blueprint
    blueprint -install mcplugins
}

install_subdomain() {
    cd /var/www/pterodactyl || exit 1
    wget -O subdomains.blueprint https://github.com/TS-25/SRJ-THEME/releases/latest/download/subdomains.blueprint
    blueprint -install subdomains
}

install_resource_manager() {
    cd /var/www/pterodactyl || exit 1
    wget -O resourcemanager.blueprint https://github.com/TS-25/SRJ-THEME/releases/download/V1.0.0/resourcemanager.blueprint
    blueprint -install resourcemanager
}

install_pull_files() {
    cd /var/www/pterodactyl || exit 1
    wget -O pullfiles.blueprint https://github.com/TS-25/SRJ-THEME/releases/download/V1.0.0/pullfiles.blueprint
    blueprint -install pullfiles
}

install_player_manager() {
    cd /var/www/pterodactyl || exit 1
    wget -O minecraftplayermanager.blueprint https://github.com/TS-25/SRJ-THEME/releases/download/V1.0.0/minecraftplayermanager.blueprint
    blueprint -install minecraftplayermanager
}

install_huxregister() {
    cd /var/www/pterodactyl || exit 1
    wget -O huxregister.blueprint https://github.com/TS-25/SRJ-THEME/releases/latest/download/huxregister.blueprint
    blueprint -install huxregister
}

install_loader() {
    cd /var/www/pterodactyl || exit 1
    wget -O loader.blueprint https://github.com/TS-25/SRJ-THEME/releases/latest/download/loader.blueprint
    blueprint -install loader
}

install_announce() {
    cd /var/www/pterodactyl || exit 1
    wget -O announce.blueprint https://github.com/TS-25/SRJ-THEME/releases/latest/download/announce.blueprint
    blueprint -install announce
}

install_minecraftpluginmanager() {
    cd /var/www/pterodactyl || exit 1
    wget -O minecraftpluginmanager.blueprint https://github.com/TS-25/SRJ-THEME/releases/latest/download/minecraftpluginmanager.blueprint
    blueprint -install minecraftpluginmanager
}

install_serverbackgrounds() {
    cd /var/www/pterodactyl || exit 1
    wget -O serverbackgrounds.blueprint https://github.com/TS-25/SRJ-THEME/releases/latest/download/serverbackgrounds.blueprint
    blueprint -install serverbackgrounds
}

install_simplefavicons() {
    cd /var/www/pterodactyl || exit 1
    wget -O simplefavicons.blueprint https://github.com/TS-25/SRJ-THEME/releases/latest/download/simplefavicons.blueprint
    blueprint -install simplefavicons
}

install_startupchanger() {
    cd /var/www/pterodactyl || exit 1
    wget -O startupchanger.blueprint https://github.com/TS-25/SRJ-THEME/releases/latest/download/startupchanger.blueprint
    blueprint -install startupchanger
}

install_versionchanger() {
    cd /var/www/pterodactyl || exit 1
    wget -O versionchanger.blueprint https://github.com/TS-25/SRJ-THEME/releases/latest/download/versionchanger.blueprint
    blueprint -install versionchanger
}

while true; do
    echo ""
    echo "1) Install Panels"
    echo "2) Install Themes"
    echo "3) Install Addons (blueprint)"
    echo "4) Exit"
    read -rp "Select option: " main

    case $main in
        1)
            echo "---- PANELS ----"
            echo "1) Install Reviactyl"
            read -rp "Choose panel: " p
            case $p in
                1) install_reviactyl ;;
            esac
            ;;
        2)
            echo "---- THEMES ----"
            echo "1) Blueprint"
            echo "2) Nebula (blueprint)"
            echo "3) Euphoria (blueprint)"
            echo "4) Revix/Reviactyl (without blueprint)"
            echo "5) Arix theme v1.3.1"
            echo "6) Reviactyl Blueprint"
            read -rp "Choose theme: " t
            case $t in
                1) install_blueprint ;;
                2) install_nebula ;;
                3) install_euphoria ;;
                4) install_revix ;;
                5) install_arix ;;
                6) install_reviactyl_blueprint ;;
            esac
            ;;
        3)
            echo "---- ADDONS (blueprint) ----"
            echo "1) MC Plugins"
            echo "2) Subdomain"
            echo "3) Resource Manager"
            echo "4) Pull Files"
            echo "5) Player Manager"
            echo "6) HuxRegister"
            echo "7) Loader"
            echo "8) Announce"
            echo "9) Minecraft Plugin Manager"
            echo "10) Server Backgrounds"
            echo "11) Simple Favicons"
            echo "12) Startup Changer"
            echo "13) Version Changer"
            read -rp "Choose addon: " a
            case $a in
                1) install_mcplugins ;;
                2) install_subdomain ;;
                3) install_resource_manager ;;
                4) install_pull_files ;;
                5) install_player_manager ;;
                6) install_huxregister ;;
                7) install_loader ;;
                8) install_announce ;;
                9) install_minecraftpluginmanager ;;
                10) install_serverbackgrounds ;;
                11) install_simplefavicons ;;
                12) install_startupchanger ;;
                13) install_versionchanger ;;
            esac
            ;;
        4) exit 0 ;;
    esac
done
