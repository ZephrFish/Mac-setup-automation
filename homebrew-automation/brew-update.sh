#!/bin/bash

# Homebrew Weekly Update Script
# This script updates Homebrew and optionally upgrades packages

# Set up logging
LOG_DIR="$HOME/Library/Logs/Homebrew"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/weekly-update-$(date +%Y%m%d-%H%M%S).log"

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log_message "Starting Homebrew weekly update"

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    log_message "ERROR: Homebrew is not installed"
    exit 1
fi

# Update Homebrew itself
log_message "Updating Homebrew..."
if brew update >> "$LOG_FILE" 2>&1; then
    log_message "Homebrew update completed successfully"
else
    log_message "WARNING: Homebrew update encountered issues"
fi

# Upgrade outdated packages
log_message "Checking for outdated packages..."
OUTDATED=$(brew outdated)
if [ -n "$OUTDATED" ]; then
    log_message "Found outdated packages:"
    echo "$OUTDATED" >> "$LOG_FILE"
    
    log_message "Upgrading packages..."
    if brew upgrade >> "$LOG_FILE" 2>&1; then
        log_message "Package upgrades completed successfully"
    else
        log_message "WARNING: Some package upgrades may have failed"
    fi
else
    log_message "No outdated packages found"
fi

# Clean up old versions
log_message "Cleaning up old versions..."
if brew cleanup >> "$LOG_FILE" 2>&1; then
    log_message "Cleanup completed successfully"
else
    log_message "WARNING: Cleanup encountered issues"
fi

# Run diagnostics
log_message "Running brew doctor..."
if brew doctor >> "$LOG_FILE" 2>&1; then
    log_message "Brew doctor reports system is ready"
else
    log_message "WARNING: Brew doctor found potential issues"
fi

log_message "Homebrew weekly update completed"
log_message "----------------------------------------"

# Keep only the last 10 weekly update log files
log_message "Cleaning up old log files..."
cd "$LOG_DIR"
ls -t weekly-update-*.log 2>/dev/null | tail -n +11 | xargs rm -f 2>/dev/null

# Also clean up launchd logs if they get too large (keep last 5)
ls -t launchd-*.log 2>/dev/null | tail -n +6 | xargs rm -f 2>/dev/null

# Clean up any log files older than 30 days
find "$LOG_DIR" -name "*.log" -type f -mtime +30 -delete 2>/dev/null

log_message "Log cleanup completed"

exit 0