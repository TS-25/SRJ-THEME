#!/bin/bash
# ============= PANEL INSTALLER MODULE =============
# This module handles panel installations
# ==================================================

# Load core functions if not already loaded
if ! type print_success &>/dev/null; then
    source core_setup.sh 2>/dev/null || {
        echo "Error: core_setup.sh not found"
        exit 1
    }
fi

# ========= PANEL INSTALLATION FUNCTIONS =========
install_reviactyl() {
    print_info "Installing Reviactyl Panel..."
    warning_prompt
    
    if safe_download "https://raw.githubusercontent.com/TS-25/SRJ-THEME/main/reviactyl" "/tmp/reviactyl_installer.sh"; then
        chmod +x /tmp/reviactyl_installer.sh
        bash /tmp/reviactyl_installer.sh
        
        if [ $? -eq 0 ]; then
            print_success "Reviactyl installed successfully"
        else
            print_error "Reviactyl installation failed"
        fi
    fi
}

install_pterodactyl() {
    print_info "Installing Pterodactyl Panel..."
    warning_prompt
    
    echo -e "${YELLOW}This will install the official Pterodactyl panel.${NC}"
    echo -e "${YELLOW}Make sure you have MySQL and PHP installed.${NC}"
    
    if confirm_continue; then
        curl -sSL https://get.pterodactyl-installer.se | bash
    fi
}

# ========= PANEL MANAGEMENT FUNCTIONS =========
update_panel() {
    if detect_panel_path; then
        print_info "Updating panel at: $PANEL_PATH"
        
        cd "$PANEL_PATH" || {
            print_error "Cannot access panel directory"
            return 1
        }
        
        # Backup current installation
        print_info "Creating backup..."
        tar -czf "/tmp/panel_backup_$(date +%Y%m%d_%H%M%S).tar.gz" .
        
        # Update process
        php artisan down
        git pull origin master
        composer install --no-dev --optimize-autoloader
        php artisan migrate --seed --force
        php artisan view:clear
        php artisan config:clear
        php artisan up
        
        print_success "Panel updated successfully"
    fi
}

# ========= PANEL MENU =========
show_panel_menu() {
    echo -e "\n${CYAN}=== PANEL INSTALLATION ===${NC}"
    echo "1) Install Reviactyl"
    echo "2) Install Pterodactyl (Official)"
    echo "3) Update Existing Panel"
    echo "4) Back to Main Menu"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

handle_panel_choice() {
    local choice
    read -rp "Select panel option: " choice
    
    case $choice in
        1) install_reviactyl ;;
        2) install_pterodactyl ;;
        3) update_panel ;;
        4) return 1 ;;
        *) 
            print_error "Invalid option"
            sleep 1
            ;;
    esac
    return 0
}

# Export panel functions
export -f install_reviactyl install_pterodactyl
export -f show_panel_menu handle_panel_choice
