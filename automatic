#!/bin/bash
# ============= MAIN INSTALLER SCRIPT =============
# This is the main entry point for the installer
# =================================================

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (use: sudo bash $0)"
    exit 1
fi

# Define module directory
MODULE_DIR="/tmp/panel_installer_modules"

# Clean up previous modules
rm -rf "$MODULE_DIR"
mkdir -p "$MODULE_DIR"

# Download all modules from GitHub
download_module() {
    local module_name="$1"
    local url="https://raw.githubusercontent.com/TS-25/SRJ-THEME/main/${module_name}.sh"
    
    echo "Downloading $module_name..."
    if curl -s "$url" -o "$MODULE_DIR/$module_name.sh"; then
        chmod +x "$MODULE_DIR/$module_name.sh"
        echo "✓ $module_name downloaded"
        return 0
    else
        echo "✗ Failed to download $module_name"
        return 1
    fi
}

# Download required modules
download_module "core_setup"
download_module "panel_installer"
download_module "theme_installer"
download_module "addon_installer"

# Load all modules
source "$MODULE_DIR/core_setup.sh"
source "$MODULE_DIR/panel_installer.sh"
source "$MODULE_DIR/theme_installer.sh"
source "$MODULE_DIR/addon_installer.sh"

# ========= MAIN LOOP =========
while true; do
    display_header
    show_main_menu
    read -rp "Select option: " main_choice
    
    case $main_choice in
        1)  # Panels
            while true; do
                display_header
                show_panel_menu
                if ! handle_panel_choice; then
                    break
                fi
                echo -e "\n${YELLOW}Press Enter to continue...${NC}"
                read -r
            done
            ;;
        2)  # Themes
            while true; do
                display_header
                show_theme_menu
                if ! handle_theme_choice; then
                    break
                fi
                echo -e "\n${YELLOW}Press Enter to continue...${NC}"
                read -r
            done
            ;;
        3)  # Addons
            while true; do
                display_header
                show_addon_menu
                if ! handle_addon_choice; then
                    break
                fi
                echo -e "\n${YELLOW}Press Enter to continue...${NC}"
                read -r
            done
            ;;
        4)  # System Info
            display_header
            echo -e "${CYAN}=== SYSTEM INFORMATION ===${NC}"
            echo "Panel Path: ${PANEL_PATH:-Not detected}"
            echo "Blueprint: $(command -v blueprint >/dev/null && echo "Installed" || echo "Not installed")"
            echo -e "${YELLOW}Press Enter to continue...${NC}"
            read -r
            ;;
        5)  # Exit
            print_success "Goodbye!"
            exit 0
            ;;
        *)
            print_error "Invalid option"
            sleep 1
            ;;
    esac
done
