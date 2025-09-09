#!/bin/bash

# Homebrew Log Cleanup Script
# This script performs thorough cleanup of Homebrew logs monthly

LOG_DIR="$HOME/Library/Logs/Homebrew"
CLEANUP_LOG="$LOG_DIR/cleanup-$(date +%Y%m%d).log"

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$CLEANUP_LOG"
}

log_message "Starting Homebrew log cleanup"

# Clean up different types of Homebrew logs
if [ -d "$LOG_DIR" ]; then
    log_message "Cleaning up Homebrew logs directory..."
    
    # Remove weekly update logs older than 60 days
    find "$LOG_DIR" -name "weekly-update-*.log" -type f -mtime +60 -delete 2>/dev/null
    log_message "Removed weekly update logs older than 60 days"
    
    # Remove cleanup logs older than 90 days
    find "$LOG_DIR" -name "cleanup-*.log" -type f -mtime +90 -delete 2>/dev/null
    log_message "Removed cleanup logs older than 90 days"
    
    # Remove launchd logs older than 30 days
    find "$LOG_DIR" -name "launchd-*.log" -type f -mtime +30 -delete 2>/dev/null
    log_message "Removed launchd logs older than 30 days"
    
    # Keep only last 20 weekly update logs regardless of age
    cd "$LOG_DIR"
    ls -t weekly-update-*.log 2>/dev/null | tail -n +21 | xargs rm -f 2>/dev/null
    
    # Keep only last 10 cleanup logs
    ls -t cleanup-*.log 2>/dev/null | tail -n +11 | xargs rm -f 2>/dev/null
    
    # If any log file is larger than 10MB, truncate it
    for logfile in "$LOG_DIR"/*.log; do
        if [ -f "$logfile" ]; then
            size=$(stat -f%z "$logfile" 2>/dev/null)
            if [ "$size" -gt 10485760 ]; then
                log_message "Truncating large log file: $(basename "$logfile") ($(($size / 1048576))MB)"
                tail -n 1000 "$logfile" > "$logfile.tmp" && mv "$logfile.tmp" "$logfile"
            fi
        fi
    done
    
    # Calculate space saved
    AFTER_SIZE=$(du -sh "$LOG_DIR" 2>/dev/null | cut -f1)
    log_message "Log directory size after cleanup: $AFTER_SIZE"
fi

# Also clean up Homebrew's own logs directory if it exists
BREW_LOG_DIR="/opt/homebrew/var/log"
if [ -d "$BREW_LOG_DIR" ] && [ -w "$BREW_LOG_DIR" ]; then
    log_message "Cleaning up Homebrew system logs..."
    find "$BREW_LOG_DIR" -name "*.log" -type f -mtime +30 -delete 2>/dev/null
fi

log_message "Homebrew log cleanup completed"

exit 0