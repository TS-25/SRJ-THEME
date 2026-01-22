#!/bin/bash
# ============= CORE SETUP MODULE =============
# This module contains shared utilities, colors, and basic functions
# =============================================

# Exit on error
set -e

# ========= COLOR DEFINITIONS =========
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
PURPLE='\033[1;35m'
CYAN='\033[1;36m'
NC='\033[0m' # No Color

# ========= DISPLAY FUNCTIONS =========
display_header() {
    clear
    echo -e "${CYAN}"
    echo "  _______               _      "
    echo " |__   __|             (_)     "
    echo "    | | __ _ _ ____   ___ _ __ "
    echo "    | |/ _\` | '_ \\ \\ / / | '__|"
    echo "    | | (_| | | | \\ V /| | |   "
    echo "    |_|\\__,_|_| |_|\\_/ |_|_|   "
    echo "                               "
    echo -e "${NC}         Installer Script      "
    echo -e "${YELLOW}===============================${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# ========= SAFETY FUNCTIONS =========
confirm_continue() {
    echo
    read -rp "Continue? (yes/no): " response
    case "$response" in
        yes|y|Y|YES) return 0 ;;
        *) return 1 ;;
    esac
}

warning_prompt() {
    echo -e "${RED}⚠ WARNING ⚠${NC}"
    echo -e "${YELLOW}This installation may overwrite panel files."
    echo -e "Your panel may become FRESH/RESET."
    echo -e "Please ensure you have a FULL BACKUP.${NC}"
    
    if ! confirm_continue; then
        print_error "Installation cancelled by user."
        exit 1
    fi
}

# ========= PANEL DETECTION =========
detect_panel_path() {
    local detected_path=""
    
    # Common panel paths
    local possible_paths=(
        "/var/www/pterodactyl"
        "/var/www/reviactyl"
        "/var/www/panel"
        "/home/panel"
    )
    
    for path in "${possible_paths[@]}"; do
        if [ -d "$path" ] && [ -f "$path/app/Http/Controllers/Controller.php" ]; then
            detected_path="$path"
            break
        fi
    done
    
    if [ -z "$detected_path" ]; then
        # Fallback to directory existence check
        for path in "${possible_paths[@]}"; do
            if [ -d "$path" ]; then
                detected_path="$path"
                break
            fi
        done
    fi
    
    if [ -n "$detected_path" ]; then
        PANEL_PATH="$detected_path"
        print_success "Panel detected at: $PANEL_PATH"
        return 0
    else
        print_error "No valid panel installation found."
        echo -e "${YELLOW}Expected paths:${NC}"
        for path in "${possible_paths[@]}"; do
            echo "  - $path"
        done
        return 1
    fi
}

# ========= SYSTEM CHECKS =========
check_root() {
    if [ "$EUID" -ne 0 ]; then 
        print_error "Please run as root (use sudo)"
        exit 1
    fi
}

check_dependencies() {
    local dependencies=("curl" "wget" "git")
    local missing=()
    
    for dep in "${dependencies[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing+=("$dep")
        fi
    done
    
    if [ ${#missing[@]} -gt 0 ]; then
        print_warning "Missing dependencies: ${missing[*]}"
        echo -e "${YELLOW}Installing missing packages...${NC}"
        apt-get update && apt-get install -y "${missing[@]}"
        print_success "Dependencies installed"
    fi
}

# ========= DOWNLOAD HELPERS =========
safe_download() {
    local url="$1"
    local output="$2"
    
    if wget --quiet --show-progress -O "$output" "$url"; then
        return 0
    elif curl --silent --fail -L -o "$output" "$url"; then
        return 0
    else
        print_error "Failed to download: $url"
        return 1
    fi
}

# ========= MAIN MENU =========
show_main_menu() {
    echo -e "\n${CYAN}=== MAIN MENU ===${NC}"
    echo "1) Install Panels"
    echo "2) Install Themes"
    echo "3) Install Addons"
    echo "4) System Info"
    echo "5) Exit"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Export functions that might be used by other modules
export -f print_success print_error print_warning print_info
export -f confirm_continue warning_prompt
export -f detect_panel_path safe_download
