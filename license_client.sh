#!/bin/bash
# ============================================
# LICENSE CLIENT FOR PANEL INSTALLER
# Validates licenses against server
# ============================================

# Configuration
LICENSE_SERVER="http://localhost:5000/api"
CACHE_DIR="/etc/panel_installer"
LICENSE_CACHE="$CACHE_DIR/license.cache"
HWID_FILE="$CACHE_DIR/hwid"
CONFIG_FILE="$CACHE_DIR/config.json"
MAX_RETRIES=3
RETRY_DELAY=2

# Colors
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
NC='\033[0m'
BOLD='\033[1m'

# Logging functions
log_success() { echo -e "${GREEN}✓${NC} $1"; }
log_error() { echo -e "${RED}✗${NC} $1"; }
log_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
log_info() { echo -e "${BLUE}ℹ${NC} $1"; }
log_debug() { echo -e "${CYAN}•${NC} $1"; }

# Create cache directory
mkdir -p "$CACHE_DIR"
chmod 700 "$CACHE_DIR"

# ========= HWID GENERATION =========
generate_hwid() {
    if [ -f "$HWID_FILE" ]; then
        cat "$HWID_FILE"
        return
    fi
    
    # Collect system information
    local hwid_parts=""
    
    # Machine ID (most reliable)
    if [ -f "/etc/machine-id" ]; then
        hwid_parts="${hwid_parts}$(cat /etc/machine-id 2>/dev/null || echo "NOMACHINEID")"
    fi
    
    # CPU information
    if [ -f "/proc/cpuinfo" ]; then
        cpu_id=$(grep -m1 "serial" /proc/cpuinfo 2>/dev/null | awk '{print $3}')
        if [ -n "$cpu_id" ]; then
            hwid_parts="${hwid_parts}${cpu_id}"
        else
            cpu_model=$(grep -m1 "model name" /proc/cpuinfo 2>/dev/null | md5sum | cut -c1-16)
            hwid_parts="${hwid_parts}${cpu_model}"
        fi
    fi
    
    # First network interface MAC
    mac_address=$(ip link show 2>/dev/null | awk '/ether/ {print $2; exit}' | tr -d ':')
    if [ -n "$mac_address" ]; then
        hwid_parts="${hwid_parts}${mac_address}"
    fi
    
    # Disk UUID (first disk)
    disk_uuid=$(lsblk -o UUID 2>/dev/null | grep -v UUID | head -1)
    if [ -n "$disk_uuid" ]; then
        hwid_parts="${hwid_parts}${disk_uuid}"
    fi
    
    # If we couldn't get enough info, generate random
    if [ -z "$hwid_parts" ] || [ ${#hwid_parts} -lt 10 ]; then
        hwid_parts=$(date +%s%N | sha256sum | head -c 32)
    fi
    
    # Create final HWID (hash for consistency)
    HWID=$(echo -n "$hwid_parts" | sha256sum | awk '{print $1}')
    
    # Save it
    echo "$HWID" > "$HWID_FILE"
    chmod 600 "$HWID_FILE"
    echo "$HWID"
}

# ========= SERVER COMMUNICATION =========
call_license_server() {
    local endpoint="$1"
    local method="$2"
    local data="$3"
    
    local response=""
    local curl_cmd=""
    
    # Build curl command
    if [ "$method" = "POST" ]; then
        curl_cmd="curl -s -X POST '$LICENSE_SERVER/$endpoint' \
            -H 'Content-Type: application/json' \
            -d '$data' \
            --max-time 10 \
            --retry $MAX_RETRIES \
            --retry-delay $RETRY_DELAY \
            2>/dev/null"
    else
        curl_cmd="curl -s '$LICENSE_SERVER/$endpoint' \
            --max-time 10 \
            --retry $MAX_RETRIES \
            --retry-delay $RETRY_DELAY \
            2>/dev/null"
    fi
    
    # Execute curl command
    response=$(eval "$curl_cmd")
    
    if [ $? -eq 0 ] && [ -n "$response" ]; then
        echo "$response"
        return 0
    else
        log_debug "Failed to contact license server"
        return 1
    fi
}

# ========= LICENSE VALIDATION =========
validate_license() {
    local license_key="$1"
    local hwid=$(generate_hwid)
    local machine_name=$(hostname)
    
    log_info "Validating license..."
    
    # Prepare validation data
    local validation_data=$(cat << EOF
{
    "license_key": "$license_key",
    "hwid": "$hwid",
    "machine_name": "$machine_name"
}
EOF
    )
    
    # Call license server
    local response=$(call_license_server "validate" "POST" "$validation_data")
    
    if [ $? -eq 0 ]; then
        # Parse JSON response (using simple grep/sed since jq might not be available)
        local valid=$(echo "$response" | grep -o '"valid":[^,]*' | cut -d: -f2 | tr -d ' ')
        local message=$(echo "$response" | grep -o '"message":"[^"]*"' | cut -d'"' -f4)
        
        if [ "$valid" = "true" ]; then
            # Extract license data
            local license_data=$(echo "$response" | grep -o '"license":{[^}]*}' | sed 's/"license"://')
            
            # Cache the successful validation
            cat > "$LICENSE_CACHE" << EOF
{
    "license_key": "$license_key",
    "hwid": "$hwid",
    "validated_at": $(date +%s),
    "response": $response
}
EOF
            chmod 600 "$LICENSE_CACHE"
            
            # Extract expiry time if available
            local expiry_time=$(echo "$response" | grep -o '"expiry_time":[0-9]*' | cut -d: -f2)
            if [ -n "$expiry_time" ]; then
                local current_time=$(date +%s)
                local days_left=$(( (expiry_time - current_time) / 86400 ))
                if [ $days_left -gt 0 ]; then
                    log_success "License valid! Days remaining: $days_left"
                else
                    log_success "License valid!"
                fi
            else
                log_success "License valid!"
            fi
            
            return 0
        else
            log_error "License invalid: ${message:-Unknown error}"
            return 1
        fi
    else
        # Server unreachable - try offline validation
        if validate_offline "$license_key"; then
            return 0
        else
            log_error "Cannot connect to license server and no cached license found"
            return 1
        fi
    fi
}

# ========= OFFLINE VALIDATION =========
validate_offline() {
    local license_key="$1"
    
    # Check if we have a cached license
    if [ -f "$LICENSE_CACHE" ]; then
        local cached_key=$(grep -o '"license_key":"[^"]*"' "$LICENSE_CACHE" | cut -d'"' -f4)
        local cached_hwid=$(grep -o '"hwid":"[^"]*"' "$LICENSE_CACHE" | cut -d'"' -f4)
        local current_hwid=$(generate_hwid)
        
        # Check if license key matches and HWID matches
        if [ "$cached_key" = "$license_key" ] && [ "$cached_hwid" = "$current_hwid" ]; then
            # Check cache age (max 7 days offline)
            local validated_at=$(grep -o '"validated_at":[0-9]*' "$LICENSE_CACHE" | cut -d: -f2)
            local current_time=$(date +%s)
            local cache_age=$((current_time - validated_at))
            local max_offline_age=604800  # 7 days in seconds
            
            if [ $cache_age -lt $max_offline_age ]; then
                log_warning "Using cached license (offline mode)"
                return 0
            else
                log_warning "Cached license expired (offline for too long)"
                return 1
            fi
        fi
    fi
    
    return 1
}

# ========= LICENSE CHECK (MAIN FUNCTION) =========
check_license() {
    # Display header
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════╗"
    echo "║      PREMIUM INSTALLER SYSTEM        ║"
    echo "╚══════════════════════════════════════╝${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo
    
    # Check for cached license first
    if [ -f "$LICENSE_CACHE" ]; then
        local cached_key=$(grep -o '"license_key":"[^"]*"' "$LICENSE_CACHE" 2>/dev/null | cut -d'"' -f4)
        if [ -n "$cached_key" ] && validate_offline "$cached_key"; then
            log_success "License verified from cache"
            return 0
        fi
    fi
    
    # No valid cache, ask for license
    echo -e "${YELLOW}This installer requires a valid license key.${NC}"
    echo -e "${YELLOW}Please enter your license key below.${NC}"
    echo
    echo -e "${BLUE}Format: XXXX-XXXX-XXXX-XXXX${NC}"
    echo
    
    local attempts=0
    local max_attempts=3
    
    while [ $attempts -lt $max_attempts ]; do
        echo -ne "${GREEN}License Key: ${NC}"
        read -r license_key
        
        # Clean input
        license_key=$(echo "$license_key" | tr '[:lower:]' '[:upper:]' | tr -d '[:space:]')
        
        # Check if user wants to exit
        if [ "$license_key" = "EXIT" ] || [ "$license_key" = "QUIT" ]; then
            log_error "Installation cancelled"
            exit 1
        fi
        
        # Validate format (basic check)
        if ! echo "$license_key" | grep -qE '^[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}$'; then
            log_error "Invalid format. Expected: XXXX-XXXX-XXXX-XXXX (uppercase letters/numbers)"
            attempts=$((attempts + 1))
            echo
            continue
        fi
        
        # Validate license
        if validate_license "$license_key"; then
            log_success "License accepted!"
            echo
            return 0
        else
            attempts=$((attempts + 1))
            if [ $attempts -lt $max_attempts ]; then
                log_warning "Please try again ($((max_attempts - attempts)) attempts remaining)"
                echo
            fi
        fi
    done
    
    log_error "Maximum attempts reached. Exiting."
    exit 1
}

# ========= LICENSE INFO =========
show_license_info() {
    if [ -f "$LICENSE_CACHE" ]; then
        local cached_key=$(grep -o '"license_key":"[^"]*"' "$LICENSE_CACHE" 2>/dev/null | cut -d'"' -f4)
        local cached_hwid=$(grep -o '"hwid":"[^"]*"' "$LICENSE_CACHE" 2>/dev/null | cut -d'"' -f4)
        local validated_at=$(grep -o '"validated_at":[0-9]*' "$LICENSE_CACHE" 2>/dev/null | cut -d: -f2)
        
        if [ -n "$cached_key" ]; then
            echo -e "${CYAN}=== LICENSE INFORMATION ===${NC}"
            echo -e "${GREEN}License:${NC} ${cached_key:0:8}...${cached_key: -4}"
            echo -e "${GREEN}HWID:${NC} ${cached_hwid:0:16}..."
            
            if [ -n "$validated_at" ]; then
                local validated_date=$(date -d "@$validated_at" "+%Y-%m-%d %H:%M:%S" 2>/dev/null || echo "Unknown")
                echo -e "${GREEN}Last Validated:${NC} $validated_date"
            fi
            
            # Try to get fresh info from server
            log_info "Checking license status..."
            local response=$(call_license_server "validate" "POST" "{\"license_key\":\"$cached_key\",\"hwid\":\"$cached_hwid\"}")
            
            if [ $? -eq 0 ]; then
                local expiry_time=$(echo "$response" | grep -o '"expiry_time":[0-9]*' | cut -d: -f2)
                if [ -n "$expiry_time" ]; then
                    local expiry_date=$(date -d "@$expiry_time" "+%Y-%m-%d" 2>/dev/null || echo "Unknown")
                    local current_time=$(date +%s)
                    local days_left=$(( (expiry_time - current_time) / 86400 ))
                    
                    echo -e "${GREEN}Expires:${NC} $expiry_date"
                    if [ $days_left -gt 0 ]; then
                        echo -e "${GREEN}Days Remaining:${NC} $days_left"
                    else
                        echo -e "${RED}License Expired${NC}"
                    fi
                fi
            fi
            echo -e "${CYAN}==========================${NC}"
        else
            log_error "No valid license found"
        fi
    else
        log_error "No license information available"
    fi
}

# ========= CLEAR LICENSE =========
clear_license() {
    if [ -f "$LICENSE_CACHE" ]; then
        rm -f "$LICENSE_CACHE"
        log_success "License cache cleared"
    fi
    
    if [ -f "$HWID_FILE" ]; then
        rm -f "$HWID_FILE"
        log_success "HWID cleared"
    fi
    
    log_info "You will need to enter license key on next run"
}

# ========= TEST CONNECTION =========
test_connection() {
    log_info "Testing connection to license server..."
    
    local response=$(call_license_server "health" "GET")
    
    if [ $? -eq 0 ]; then
        local status=$(echo "$response" | grep -o '"status":"[^"]*"' | cut -d'"' -f4)
        if [ "$status" = "online" ]; then
            log_success "License server is online"
            return 0
        else
            log_error "License server returned: $status"
            return 1
        fi
    else
        log_error "Cannot connect to license server"
        return 1
    fi
}

# ========= MAIN EXECUTION =========
if [ "$0" = "$BASH_SOURCE" ]; then
    case "${1:-}" in
        "info")
            show_license_info
            ;;
        "clear")
            clear_license
            ;;
        "test")
            test_connection
            ;;
        "hwid")
            echo "HWID: $(generate_hwid)"
            ;;
        *)
            check_license
            ;;
    esac
fi

# Export functions for use in main installer
export -f check_license show_license_info clear_license test_connection generate_hwid
