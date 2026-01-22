#!/bin/bash
# ============= ADDON INSTALLER MODULE =============
# This module handles addon/plugin installations
# ==================================================

# Load core functions if not already loaded
if ! type print_success &>/dev/null; then
    source core_setup.sh 2>/dev/null || {
        echo "Error: core_setup.sh not found"
        exit 1
    }
fi

# ========= ADDON INSTALLATION FUNCTIONS =========
install_addon() {
    local addon_name="$1"
    local download_url="$2"
    
    print_info "Installing $addon_name..."
    
    if ! detect_panel_path; then
        return 1
    fi
    
    cd "$PANEL_PATH" || return 1
    
    if safe_download "$download_url" "${addon_name}.blueprint"; then
        if command -v blueprint &>/dev/null; then
            blueprint -install "$addon_name"
            print_success "$addon_name installed successfully"
        else
            print_error "Blueprint not found. Install it first from theme menu."
            return 1
        fi
    else
        print_error "Failed to download $addon_name"
        return 1
    fi
}

# ========= INDIVIDUAL ADDON INSTALLERS =========
install_mcplugins() {
    warning_prompt
    install_addon "mcplugins" "https://github.com/TS-25/SRJ-THEME/releases/latest/download/mcplugins.blueprint"
}

install_subdomain() {
    warning_prompt
    install_addon "subdomains" "https://github.com/TS-25/SRJ-THEME/releases/latest/download/subdomains.blueprint"
}

install_resource_manager() {
    warning_prompt
    install_addon "resourcemanager" "https://github.com/TS-25/SRJ-THEME/releases/download/V1.0.0/resourcemanager.blueprint"
}

install_pull_files() {
    warning_prompt
    install_addon "pullfiles" "https://github.com/TS-25/SRJ-THEME/releases/download/V1.0.0/pullfiles.blueprint"
}

install_player_manager() {
    warning_prompt
    install_addon "minecraftplayermanager" "https://github.com/TS-25/SRJ-THEME/releases/download/V1.0.0/minecraftplayermanager.blueprint"
}

install_huxregister() {
    warning_prompt
    install_addon "huxregister" "https://github.com/TS-25/SRJ-THEME/releases/latest/download/huxregister.blueprint"
}

install_loader() {
    warning_prompt
    install_addon "loader" "https://github.com/TS-25/SRJ-THEME/releases/latest/download/loader.blueprint"
}

install_announce() {
    warning_prompt
    install_addon "announce" "https://github.com/TS-25/SRJ-THEME/releases/latest/download/announce.blueprint"
}

install_minecraftpluginmanager() {
    warning_prompt
    install_addon "minecraftpluginmanager" "https://github.com/TS-25/SRJ-THEME/releases/latest/download/minecraftpluginmanager.blueprint"
}

install_serverbackgrounds() {
    warning_prompt
    install_addon "serverbackgrounds" "https://github.com/TS-25/SRJ-THEME/releases/latest/download/serverbackgrounds.blueprint"
}

install_simplefavicons() {
    warning_prompt
    install_addon "simplefavicons" "https://github.com/TS-25/SRJ-THEME/releases/latest/download/simplefavicons.blueprint"
}

install_startupchanger() {
    warning_prompt
    install_addon "startupchanger" "https://github.com/TS-25/SRJ-THEME/releases/latest/download/startupchanger.blueprint"
}

install_versionchanger() {
    warning_prompt
    install_addon "versionchanger" "https://github.com/TS-25/SRJ-THEME/releases/latest/download/versionchanger.blueprint"
}

# ========= NEW ADDONS =========
install_mclogs() {
    warning_prompt
    install_addon "mclogs" "https://github.com/TS-25/SRJ-THEME/releases/latest/download/mclogs.blueprint"
}

install_bluetables() {
    warning_prompt
    install_addon "bluetables" "https://github.com/TS-25/SRJ-THEME/releases/latest/download/bluetables.blueprint"
}

install_mctools() {
    warning_prompt
    install_addon "mctools" "https://github.com/TS-25/SRJ-THEME/releases/latest/download/mctools.blueprint"
}

install_simplefooters() {
    warning_prompt
    install_addon "simplefooters" "https://github.com/TS-25/SRJ-THEME/releases/latest/download/simplefooters.blueprint"
}

install_votifiertester() {
    warning_prompt
    print_info "Installing Votifier Tester..."
    
    if ! detect_panel_path; then
        return 1
    fi
    
    cd "$PANEL_PATH" || return 1
    
    # Download the blueprint file
    if safe_download "https://github.com/TS-25/SRJ-THEME/releases/latest/download/votifiertester.blueprint" "votifiertester.blueprint"; then
        if command -v blueprint &>/dev/null; then
            # Install required PHP dependency first
            print_info "Installing Votifier PHP client..."
            composer require leonardorrc/votifier-client-php
            
            # Install the blueprint
            blueprint -install votifiertester
            print_success "Votifier Tester installed successfully"
        else
            print_error "Blueprint not found. Install it first from theme menu."
            return 1
        fi
    else
        print_error "Failed to download Votifier Tester"
        return 1
    fi
}

# ========= ADDON MANAGEMENT FUNCTIONS =========
list_installed_addons() {
    if detect_panel_path; then
        if [ -d "$PANEL_PATH/blueprints" ]; then
            echo -e "\n${CYAN}Installed Addons (Blueprints):${NC}"
            ls -la "$PANEL_PATH/blueprints"/*.blueprint 2>/dev/null | awk -F/ '{print $NF}'
        else
            print_info "No blueprints directory found"
        fi
    fi
}

remove_addon() {
    local addon_name="$1"
    
    if detect_panel_path && command -v blueprint &>/dev/null; then
        print_info "Removing $addon_name..."
        cd "$PANEL_PATH" && blueprint -remove "$addon_name"
        print_success "$addon_name removed"
    fi
}

# ========= ADDON MENU =========
show_addon_menu() {
    echo -e "\n${CYAN}=== ADDON INSTALLATION ===${NC}"
    echo "---- Minecraft Related ----"
    echo "1) MC Plugins"
    echo "2) Player Manager"
    echo "3) Minecraft Plugin Manager"
    echo "4) Version Changer"
    echo "5) MC Logs"
    echo "6) MC Tools"
    echo "7) Votifier Tester"
    
    echo -e "\n---- Server Management ----"
    echo "8) Resource Manager"
    echo "9) Pull Files"
    echo "10) Startup Changer"
    echo "11) Server Backgrounds"
    
    echo -e "\n---- Features ----"
    echo "12) Subdomain"
    echo "13) HuxRegister"
    echo "14) Loader"
    echo "15) Announce"
    echo "16) Simple Favicons"
    echo "17) Simple Footers"
    echo "18) Blue Tables"
    
    echo -e "\n---- Management ----"
    echo "19) List Installed Addons"
    echo "20) Remove Addon"
    echo "21) Back to Main Menu"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

handle_addon_choice() {
    local choice
    read -rp "Select addon option: " choice
    
    case $choice in
        1) install_mcplugins ;;
        2) install_player_manager ;;
        3) install_minecraftpluginmanager ;;
        4) install_versionchanger ;;
        5) install_mclogs ;;
        6) install_mctools ;;
        7) install_votifiertester ;;
        8) install_resource_manager ;;
        9) install_pull_files ;;
        10) install_startupchanger ;;
        11) install_serverbackgrounds ;;
        12) install_subdomain ;;
        13) install_huxregister ;;
        14) install_loader ;;
        15) install_announce ;;
        16) install_simplefavicons ;;
        17) install_simplefooters ;;
        18) install_bluetables ;;
        19) list_installed_addons ;;
        20)
            read -rp "Enter addon name to remove: " addon_name
            remove_addon "$addon_name"
            ;;
        21) return 1 ;;
        *) 
            print_error "Invalid option"
            sleep 1
            ;;
    esac
    return 0
}

# Export addon functions
export -f install_addon
export -f install_mcplugins install_subdomain install_resource_manager install_pull_files
export -f install_player_manager install_huxregister install_loader install_announce
export -f install_minecraftpluginmanager install_serverbackgrounds install_simplefavicons
export -f install_startupchanger install_versionchanger
export -f install_mclogs install_bluetables install_mctools install_simplefooters install_votifiertester
export -f show_addon_menu handle_addon_choice
