#!/bin/bash
# ============= THEME INSTALLER MODULE =============
# This module handles theme installations
# ==================================================

# Load core functions if not already loaded
if ! type print_success &>/dev/null; then
    source core_setup.sh 2>/dev/null || {
        echo "Error: core_setup.sh not found"
        exit 1
    }
fi

# ========= THEME INSTALLATION FUNCTIONS =========
install_blueprint() {
    print_info "Installing Blueprint..."
    warning_prompt
    
    check_dependencies
    bash <(curl -s https://raw.githubusercontent.com/TS-25/SRJ-THEME/main/blueprint)
}

install_nebula() {
    print_info "Installing Nebula Theme..."
    warning_prompt
    
    if detect_panel_path; then
        cd "$PANEL_PATH" || return 1
        
        if safe_download "https://github.com/TS-25/SRJ-THEME/releases/latest/download/nebula.blueprint" "nebula.blueprint"; then
            if command -v blueprint &>/dev/null; then
                blueprint -install nebula
                print_success "Nebula theme installed"
            else
                print_error "Blueprint not found. Install it first from theme menu."
            fi
        fi
    fi
}

install_euphoria() {
    print_info "Installing Euphoria Theme..."
    warning_prompt
    
    if detect_panel_path; then
        cd "$PANEL_PATH" || return 1
        
        if safe_download "https://github.com/TS-25/SRJ-THEME/releases/latest/download/euphoriatheme.blueprint" "euphoriatheme.blueprint"; then
            if command -v blueprint &>/dev/null; then
                blueprint -install euphoriatheme
                print_success "Euphoria theme installed"
            else
                print_error "Blueprint not found"
            fi
        fi
    fi
}

install_revix() {
    print_info "Installing Revix Theme..."
    warning_prompt
    
    bash <(curl -s https://raw.githubusercontent.com/TS-25/SRJ-THEME/main/revix-theme)
}

install_arix() {
    print_info "Installing ARIX Theme v1.3.1..."
    
    if safe_download "https://raw.githubusercontent.com/TS-25/arix/main/arix" "/tmp/arix_installer.sh"; then
        chmod +x /tmp/arix_installer.sh
        bash /tmp/arix_installer.sh
    fi
}

install_reviactyl_blueprint() {
    print_info "Installing Reviactyl Blueprint..."
    warning_prompt
    
    bash <(curl -s https://raw.githubusercontent.com/TS-25/SRJ-THEME/main/reviactyl-blueprint)
}

# ========= THEME MANAGEMENT FUNCTIONS =========
list_installed_themes() {
    if detect_panel_path; then
        if [ -d "$PANEL_PATH/public/themes" ]; then
            echo -e "\n${CYAN}Installed Themes:${NC}"
            ls -la "$PANEL_PATH/public/themes"
        else
            print_info "No themes directory found"
        fi
    fi
}

# ========= THEME MENU =========
show_theme_menu() {
    echo -e "\n${CYAN}=== THEME INSTALLATION ===${NC}"
    echo "1) Install Blueprint (Required for themes)"
    echo "2) Install Nebula Theme"
    echo "3) Install Euphoria Theme"
    echo "4) Install Revix Theme"
    echo "5) Install ARIX Theme v1.3.1"
    echo "6) Install Reviactyl Blueprint"
    echo "7) List Installed Themes"
    echo "8) Back to Main Menu"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

handle_theme_choice() {
    local choice
    read -rp "Select theme option: " choice
    
    case $choice in
        1) install_blueprint ;;
        2) install_nebula ;;
        3) install_euphoria ;;
        4) install_revix ;;
        5) install_arix ;;
        6) install_reviactyl_blueprint ;;
        7) list_installed_themes ;;
        8) return 1 ;;
        *) 
            print_error "Invalid option"
            sleep 1
            ;;
    esac
    return 0
}

# Export theme functions
export -f install_blueprint install_nebula install_euphoria install_revix install_arix install_reviactyl_blueprint
export -f show_theme_menu handle_theme_choice
