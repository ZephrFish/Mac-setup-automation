#!/bin/bash

# Input validation and sanitization functions
# Provides security and data validation utilities

# Validate numeric input
validate_number() {
    local input="$1"
    local min="${2:-0}"
    local max="${3:-999999}"
    
    # Check if input is a number
    if ! [[ "$input" =~ ^[0-9]+$ ]]; then
        return 1
    fi
    
    # Check range
    if [[ $input -lt $min || $input -gt $max ]]; then
        return 1
    fi
    
    return 0
}

# Validate menu choice
validate_menu_choice() {
    local input="$1"
    shift
    local valid_choices=("$@")
    
    for choice in "${valid_choices[@]}"; do
        if [[ "$input" == "$choice" ]]; then
            return 0
        fi
    done
    
    return 1
}

# Validate file path (no directory traversal)
validate_path() {
    local path="$1"
    
    # Check for directory traversal attempts
    if [[ "$path" =~ \.\. ]]; then
        log ERROR "Invalid path: directory traversal detected"
        return 1
    fi
    
    # Check for absolute paths when not allowed
    if [[ "${ALLOW_ABSOLUTE_PATHS:-true}" != "true" && "$path" =~ ^/ ]]; then
        log ERROR "Invalid path: absolute paths not allowed"
        return 1
    fi
    
    return 0
}

# Validate URL
validate_url() {
    local url="$1"
    
    # Basic URL validation
    if ! [[ "$url" =~ ^https?:// ]]; then
        log ERROR "Invalid URL: must start with http:// or https://"
        return 1
    fi
    
    # Check against allowlist if defined
    if [[ -n "${URL_ALLOWLIST:-}" ]]; then
        local allowed=false
        for pattern in $URL_ALLOWLIST; do
            if [[ "$url" =~ $pattern ]]; then
                allowed=true
                break
            fi
        done
        
        if [[ "$allowed" != "true" ]]; then
            log ERROR "URL not in allowlist: $url"
            return 1
        fi
    fi
    
    return 0
}

# Sanitize input for shell execution
sanitize_input() {
    local input="$1"
    
    # Remove potentially dangerous characters
    input="${input//[\$\`\\]/}"
    input="${input//[;|&]/}"
    input="${input//[<>]/}"
    
    echo "$input"
}

# Validate package name
validate_package_name() {
    local package="$1"
    
    # Check for valid package name format
    if ! [[ "$package" =~ ^[a-zA-Z0-9@/_.-]+$ ]]; then
        log ERROR "Invalid package name: $package"
        return 1
    fi
    
    return 0
}

# Validate email address
validate_email() {
    local email="$1"
    
    if ! [[ "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        return 1
    fi
    
    return 0
}

# Validate GitHub repository format
validate_github_repo() {
    local repo="$1"
    
    if ! [[ "$repo" =~ ^[a-zA-Z0-9_-]+/[a-zA-Z0-9_.-]+$ ]]; then
        log ERROR "Invalid GitHub repository format: $repo"
        return 1
    fi
    
    return 0
}

# Validate semantic version
validate_version() {
    local version="$1"
    
    if ! [[ "$version" =~ ^v?[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.-]+)?(\+[a-zA-Z0-9.-]+)?$ ]]; then
        return 1
    fi
    
    return 0
}

# Validate boolean value
validate_boolean() {
    local value="$1"
    
    case "${value,,}" in
        true|yes|y|1|on)
            echo "true"
            return 0
            ;;
        false|no|n|0|off)
            echo "false"
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Validate disk space available
validate_disk_space() {
    local required_gb="${1:-5}"
    local path="${2:-/}"
    
    local available_kb=$(df -k "$path" | awk 'NR==2 {print $4}')
    local available_gb=$((available_kb / 1024 / 1024))
    
    if [[ $available_gb -lt $required_gb ]]; then
        log ERROR "Insufficient disk space. Required: ${required_gb}GB, Available: ${available_gb}GB"
        return 1
    fi
    
    return 0
}

# Validate network connectivity
validate_network() {
    local test_host="${1:-github.com}"
    local timeout="${2:-5}"
    
    if ! ping -c 1 -t "$timeout" "$test_host" &>/dev/null; then
        log ERROR "No network connectivity to $test_host"
        return 1
    fi
    
    return 0
}

# Validate sudo access
validate_sudo() {
    if ! sudo -n true 2>/dev/null; then
        if ! sudo -v; then
            log ERROR "Failed to obtain sudo access"
            return 1
        fi
    fi
    
    return 0
}

# Validate macOS version requirement
validate_macos_version() {
    local required_version="$1"
    local current_version=$(sw_vers -productVersion)
    
    if ! [[ "$(printf '%s\n' "$required_version" "$current_version" | sort -V | head -n1)" == "$required_version" ]]; then
        log ERROR "macOS version $current_version is below required version $required_version"
        return 1
    fi
    
    return 0
}

# Validate Xcode Command Line Tools
validate_xcode_tools() {
    if ! xcode-select -p &>/dev/null; then
        log ERROR "Xcode Command Line Tools not installed"
        return 1
    fi
    
    return 0
}

# Export functions
export -f validate_number
export -f validate_menu_choice
export -f validate_path
export -f validate_url
export -f sanitize_input
export -f validate_package_name
export -f validate_email
export -f validate_github_repo
export -f validate_version
export -f validate_boolean
export -f validate_disk_space
export -f validate_network
export -f validate_sudo
export -f validate_macos_version
export -f validate_xcode_tools