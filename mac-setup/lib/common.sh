#!/bin/bash

# Common functions and utilities for MacSetup scripts
# Provides shared functionality for all modules

# Script configuration
SCRIPT_VERSION="2.1.0"
SCRIPT_DIR="${SCRIPT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
LOG_DIR="$HOME/.macsetup/logs"
CACHE_DIR="$HOME/.macsetup/cache"
CONFIG_DIR="$SCRIPT_DIR/config"
BACKUP_DIR="$HOME/.macsetup/backups"

# Create necessary directories
mkdir -p "$LOG_DIR" "$CACHE_DIR" "$BACKUP_DIR"

# Import color definitions
source "${SCRIPT_DIR}/lib/colors.sh"

# Global variables
DRY_RUN=${DRY_RUN:-false}
VERBOSE=${VERBOSE:-false}
VERIFY_MODE=${VERIFY_MODE:-false}
LOG_FILE="$LOG_DIR/macsetup-$(date +%Y%m%d-%H%M%S).log"

# Logging functions
log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case "$level" in
        ERROR)   echo -e "${RED}[ERROR]${NC} $message" | tee -a "$LOG_FILE" ;;
        WARNING) echo -e "${YELLOW}[WARNING]${NC} $message" | tee -a "$LOG_FILE" ;;
        SUCCESS) echo -e "${GREEN}[SUCCESS]${NC} $message" | tee -a "$LOG_FILE" ;;
        INFO)    echo -e "${CYAN}[INFO]${NC} $message" | tee -a "$LOG_FILE" ;;
        DEBUG)   
            [[ "$VERBOSE" == "true" ]] && echo -e "${GRAY}[DEBUG]${NC} $message" | tee -a "$LOG_FILE"
            ;;
        *)       echo -e "$level $message" | tee -a "$LOG_FILE" ;;
    esac
    
    echo "[$timestamp] $level: $message" >> "$LOG_FILE"
}

# Error handling
set_error_trap() {
    trap 'error_handler $? $LINENO' ERR
}

error_handler() {
    local exit_code=$1
    local line_number=$2
    log ERROR "Command failed with exit code $exit_code at line $line_number"
    cleanup_on_error
    exit "$exit_code"
}

cleanup_on_error() {
    log INFO "Performing cleanup after error..."
    # Remove any temporary files
    rm -f /tmp/macsetup-*
    # Reset sudo timestamp
    sudo -k
}

# Dry run wrapper
execute() {
    local command="$*"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log INFO "[DRY RUN] Would execute: $command"
        return 0
    fi
    
    log DEBUG "Executing: $command"
    eval "$command"
    local result=$?
    
    if [[ $result -ne 0 ]]; then
        log ERROR "Command failed: $command"
        return $result
    fi
    
    return 0
}

# Safe sudo execution
safe_sudo() {
    local command="$*"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log INFO "[DRY RUN] Would execute with sudo: $command"
        return 0
    fi
    
    # Verify sudo access without keeping it alive indefinitely
    if ! sudo -n true 2>/dev/null; then
        log INFO "This operation requires administrator privileges"
        sudo -v
    fi
    
    sudo sh -c "$command"
}

# Backup file before modification
backup_file() {
    local file="$1"
    
    if [[ ! -f "$file" ]]; then
        log DEBUG "File $file does not exist, skipping backup"
        return 0
    fi
    
    local backup_name="$(basename "$file").$(date +%Y%m%d-%H%M%S).bak"
    local backup_path="$BACKUP_DIR/$backup_name"
    
    log INFO "Backing up $file to $backup_path"
    cp "$file" "$backup_path"
    
    return 0
}

# Restore file from backup
restore_file() {
    local file="$1"
    local backup_pattern="$(basename "$file").*.bak"
    
    # Find most recent backup
    local latest_backup=$(ls -t "$BACKUP_DIR"/$backup_pattern 2>/dev/null | head -1)
    
    if [[ -z "$latest_backup" ]]; then
        log ERROR "No backup found for $file"
        return 1
    fi
    
    log INFO "Restoring $file from $latest_backup"
    cp "$latest_backup" "$file"
    
    return 0
}

# Check if running on macOS
check_macos() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        log ERROR "This script is only for macOS"
        exit 1
    fi
    
    # Get macOS version
    local macos_version=$(sw_vers -productVersion)
    log INFO "Running on macOS $macos_version"
    
    # Check architecture
    local arch=$(uname -m)
    log INFO "System architecture: $arch"
    
    return 0
}

# Check if command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Install Homebrew if needed
ensure_homebrew() {
    if command_exists brew; then
        log DEBUG "Homebrew already installed"
        return 0
    fi
    
    log INFO "Installing Homebrew..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log INFO "[DRY RUN] Would install Homebrew"
        return 0
    fi
    
    # Download and verify Homebrew installer
    local installer_url="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
    local installer_path="$CACHE_DIR/homebrew-install.sh"
    
    # Download with retry logic
    download_with_retry "$installer_url" "$installer_path"
    
    # Execute installer
    /bin/bash "$installer_path" </dev/null
    
    # Add Homebrew to PATH for Apple Silicon
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    
    log SUCCESS "Homebrew installed successfully"
    
    return 0
}

# Download file with retry and verification
download_with_retry() {
    local url="$1"
    local output="$2"
    local max_retries=3
    local retry_delay=5
    
    for i in $(seq 1 $max_retries); do
        log INFO "Downloading $url (attempt $i/$max_retries)..."
        
        if curl -fsSL --connect-timeout 10 --max-time 300 -o "$output" "$url"; then
            log SUCCESS "Download successful"
            return 0
        fi
        
        log WARNING "Download failed, retrying in ${retry_delay}s..."
        sleep $retry_delay
    done
    
    log ERROR "Failed to download $url after $max_retries attempts"
    return 1
}

# Verify checksum
verify_checksum() {
    local file="$1"
    local expected_checksum="$2"
    local algorithm="${3:-sha256}"
    
    if [[ ! -f "$file" ]]; then
        log ERROR "File $file not found for checksum verification"
        return 1
    fi
    
    local actual_checksum
    case "$algorithm" in
        sha256)
            actual_checksum=$(shasum -a 256 "$file" | cut -d' ' -f1)
            ;;
        sha512)
            actual_checksum=$(shasum -a 512 "$file" | cut -d' ' -f1)
            ;;
        md5)
            actual_checksum=$(md5 -q "$file")
            ;;
        *)
            log ERROR "Unknown checksum algorithm: $algorithm"
            return 1
            ;;
    esac
    
    if [[ "$actual_checksum" != "$expected_checksum" ]]; then
        log ERROR "Checksum verification failed for $file"
        log ERROR "Expected: $expected_checksum"
        log ERROR "Actual: $actual_checksum"
        return 1
    fi
    
    log SUCCESS "Checksum verified for $file"
    return 0
}

# User confirmation prompt
confirm() {
    local message="$1"
    local default="${2:-n}"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log INFO "[DRY RUN] Would prompt: $message"
        return 0
    fi
    
    local prompt
    if [[ "$default" == "y" ]]; then
        prompt="$message [Y/n]: "
    else
        prompt="$message [y/N]: "
    fi
    
    read -p "$prompt" response
    response=${response:-$default}
    
    [[ "$response" =~ ^[Yy]$ ]]
}

# Progress indicator
show_progress() {
    local message="$1"
    echo -n "$message"
    
    while kill -0 $! 2>/dev/null; do
        echo -n "."
        sleep 1
    done
    
    echo " Done!"
}

# Cleanup function
cleanup() {
    log INFO "Performing cleanup..."
    
    # Remove temporary files
    rm -f /tmp/macsetup-*
    
    # Reset sudo timestamp
    sudo -k
    
    log INFO "Cleanup complete"
}

# Set cleanup trap
trap cleanup EXIT

# Export functions for use in other scripts
export -f log
export -f execute
export -f safe_sudo
export -f backup_file
export -f restore_file
export -f command_exists
export -f download_with_retry
export -f verify_checksum
export -f confirm
export -f show_progress