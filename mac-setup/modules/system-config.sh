#!/bin/bash

# System Configuration Module
# Handles macOS system settings and optimizations

# Source common functions
SCRIPT_DIR="${SCRIPT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
source "${SCRIPT_DIR}/lib/common.sh"
source "${SCRIPT_DIR}/lib/validators.sh"

# Module configuration
MODULE_NAME="System Configuration"

# System configuration categories (bash 3.x compatible)
SYSTEM_CONFIG_KEYS=("performance" "ssd" "developer" "finder" "network" "limits" "touchid")
SYSTEM_CONFIG_VALUES=(
    "Performance optimizations (animations, UI speed)"
    "SSD optimizations (hibernation, swap)"
    "Developer settings (hidden files, extensions)"
    "Finder enhancements"
    "Network optimizations"
    "File descriptor and resource limits"
    "Touch ID for sudo authentication"
)

# Apply performance optimizations
apply_performance_optimizations() {
    log INFO "Applying performance optimizations..."
    
    # Disable window animations
    execute "defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false"
    
    # Speed up expose animation
    execute "defaults write com.apple.dock expose-animation-duration -float 0.1"
    
    # Reduce dock animation times
    execute "defaults write com.apple.dock autohide-time-modifier -float 0.5"
    execute "defaults write com.apple.dock autohide-delay -float 0"
    
    # Disable smooth scrolling
    execute "defaults write NSGlobalDomain NSScrollAnimationEnabled -bool false"
    
    # Speed up mission control animations
    execute "defaults write com.apple.dock expose-group-by-app -bool false"
    
    log SUCCESS "Performance optimizations applied"
}

# Apply SSD optimizations
apply_ssd_optimizations() {
    log INFO "Applying SSD optimizations..."
    
    # Disable hibernation (saves disk space)
    safe_sudo "pmset -a hibernatemode 0"
    
    # Remove sleep image file
    safe_sudo "rm -f /var/vm/sleepimage"
    safe_sudo "mkdir -p /var/vm/sleepimage"
    
    # Disable sudden motion sensor (not needed for SSDs)
    safe_sudo "pmset -a sms 0"
    
    # Reduce swappiness (macOS doesn't have vm.swappiness like Linux)
    # Instead, we optimize memory pressure settings
    
    log SUCCESS "SSD optimizations applied"
}

# Apply developer settings
apply_developer_settings() {
    log INFO "Enabling developer settings..."
    
    # Show hidden files
    execute "defaults write com.apple.finder AppleShowAllFiles -bool true"
    
    # Show all file extensions
    execute "defaults write NSGlobalDomain AppleShowAllExtensions -bool true"
    
    # Enable Debug menu in Disk Utility
    execute "defaults write com.apple.DiskUtility DUDebugMenuEnabled -bool true"
    execute "defaults write com.apple.DiskUtility advanced-image-options -bool true"
    
    # Show build duration in Xcode
    execute "defaults write com.apple.dt.Xcode ShowBuildOperationDuration -bool true"
    
    # Enable developer mode for Safari
    execute "defaults write com.apple.Safari IncludeInternalDebugMenu -bool true"
    execute "defaults write com.apple.Safari IncludeDevelopMenu -bool true"
    
    # Install Xcode Command Line Tools if not present
    if ! validate_xcode_tools; then
        log INFO "Installing Xcode Command Line Tools..."
        execute "xcode-select --install" || true
    fi
    
    log SUCCESS "Developer settings enabled"
}

# Configure Finder
configure_finder() {
    log INFO "Configuring Finder..."
    
    # Show path bar
    execute "defaults write com.apple.finder ShowPathbar -bool true"
    
    # Show status bar
    execute "defaults write com.apple.finder ShowStatusBar -bool true"
    
    # Show full POSIX path in title
    execute "defaults write com.apple.finder _FXShowPosixPathInTitle -bool true"
    
    # Default to list view
    execute "defaults write com.apple.finder FXPreferredViewStyle -string 'Nlsv'"
    
    # Search current folder by default
    execute "defaults write com.apple.finder FXDefaultSearchScope -string 'SCcf'"
    
    # Disable file extension change warning
    execute "defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false"
    
    # Show Library folder
    execute "chflags nohidden ~/Library"
    
    # Show /Volumes folder
    safe_sudo "chflags nohidden /Volumes"
    
    log SUCCESS "Finder configured"
}

# Apply network optimizations
apply_network_optimizations() {
    log INFO "Applying network optimizations..."
    
    # Optimize TCP settings
    safe_sudo "sysctl -w net.inet.tcp.msl=1000"
    safe_sudo "sysctl -w net.inet.tcp.win_scale_factor=8"
    
    # Increase socket buffer sizes
    safe_sudo "sysctl -w kern.ipc.maxsockbuf=8388608"
    safe_sudo "sysctl -w net.inet.tcp.sendspace=1048576"
    safe_sudo "sysctl -w net.inet.tcp.recvspace=1048576"
    
    # Enable TCP keepalive
    safe_sudo "sysctl -w net.inet.tcp.always_keepalive=1"
    
    log SUCCESS "Network optimizations applied"
}

# Increase system limits
increase_system_limits() {
    log INFO "Increasing system resource limits..."
    
    # Increase file descriptor limits
    safe_sudo "launchctl limit maxfiles 65536 200000"
    
    # Update shell limits
    ulimit -n 65536
    
    # Create or update limit configuration
    local limit_conf="/Library/LaunchDaemons/limit.maxfiles.plist"
    
    if [[ ! -f "$limit_conf" ]]; then
        safe_sudo "tee '$limit_conf' > /dev/null" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>Label</key>
    <string>limit.maxfiles</string>
    <key>ProgramArguments</key>
    <array>
      <string>launchctl</string>
      <string>limit</string>
      <string>maxfiles</string>
      <string>65536</string>
      <string>200000</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>ServiceIPC</key>
    <false/>
  </dict>
</plist>
EOF
        safe_sudo "launchctl load -w '$limit_conf'"
    fi
    
    log SUCCESS "System limits increased"
}

# Configure Touch ID for sudo
configure_touchid_sudo() {
    log INFO "Configuring Touch ID for sudo..."
    
    # Check if Mac has Touch ID
    if ! system_profiler SPHardwareDataType | grep -q "Touch ID" && \
       ! ioreg -c AppleEmbeddedOSSupportHost | grep -q "AppleEmbeddedOSSupportHost"; then
        log WARNING "This Mac doesn't appear to have Touch ID"
        return 0
    fi
    
    # Backup PAM configuration
    local pam_sudo="/etc/pam.d/sudo_local"
    
    if [[ -f "/etc/pam.d/sudo_local.template" ]]; then
        backup_file "/etc/pam.d/sudo_local.template"
    fi
    
    # Create sudo_local file (survives OS updates)
    safe_sudo "tee '$pam_sudo' > /dev/null" <<'EOF'
# sudo_local: local config file for sudo which survives macOS updates
# Enable Touch ID for sudo
auth       sufficient     pam_tid.so
EOF
    
    log SUCCESS "Touch ID for sudo configured"
    log INFO "Note: Touch ID won't work in Terminal sessions over SSH/screen sharing"
}

# Verify system changes
verify_system_changes() {
    log INFO "Verifying system configuration..."
    
    local checks_passed=0
    local checks_total=0
    
    # Check hidden files
    ((checks_total++))
    if defaults read com.apple.finder AppleShowAllFiles | grep -q "1"; then
        print_check "Hidden files are visible"
        ((checks_passed++))
    else
        print_cross "Hidden files not visible"
    fi
    
    # Check file extensions
    ((checks_total++))
    if defaults read NSGlobalDomain AppleShowAllExtensions | grep -q "1"; then
        print_check "File extensions are shown"
        ((checks_passed++))
    else
        print_cross "File extensions not shown"
    fi
    
    # Check Touch ID
    ((checks_total++))
    if [[ -f "/etc/pam.d/sudo_local" ]]; then
        print_check "Touch ID for sudo is configured"
        ((checks_passed++))
    else
        print_cross "Touch ID for sudo not configured"
    fi
    
    # Check file limits
    ((checks_total++))
    local current_limit=$(ulimit -n)
    if [[ $current_limit -ge 65536 ]]; then
        print_check "File descriptor limit is optimized ($current_limit)"
        ((checks_passed++))
    else
        print_cross "File descriptor limit not optimized ($current_limit)"
    fi
    
    log INFO "Verification complete: $checks_passed/$checks_total checks passed"
}

# Main system configuration menu
show_system_config_menu() {
    print_header "$MODULE_NAME"
    
    echo "Select system configurations to apply:"
    local i=1
    for idx in "${!SYSTEM_CONFIG_VALUES[@]}"; do
        print_bullet "[$((idx+1))] ${SYSTEM_CONFIG_VALUES[$idx]}"
    done
    print_bullet "[A] Apply all configurations"
    print_bullet "[V] Verify current configuration"
    print_bullet "[0] Back to main menu"
    echo ""
    
    read -p "$(echo -e ${COLOR_PROMPT}Enter your choices (space-separated): ${NC})" -a choices
    
    for choice in "${choices[@]}"; do
        case $choice in
            1) apply_performance_optimizations ;;
            2) apply_ssd_optimizations ;;
            3) apply_developer_settings ;;
            4) configure_finder ;;
            5) apply_network_optimizations ;;
            6) increase_system_limits ;;
            7) configure_touchid_sudo ;;
            [Aa])
                apply_performance_optimizations
                apply_ssd_optimizations
                apply_developer_settings
                configure_finder
                apply_network_optimizations
                increase_system_limits
                configure_touchid_sudo
                ;;
            [Vv])
                verify_system_changes
                ;;
            0) return 0 ;;
            *)
                log ERROR "Invalid choice: $choice"
                ;;
        esac
    done
    
    # Restart Finder to apply changes
    if confirm "Restart Finder to apply changes?" "y"; then
        execute "killall Finder"
    fi
    
    log SUCCESS "$MODULE_NAME complete"
    log INFO "Some changes may require a system restart to take full effect"
    read -p "Press Enter to continue..."
}

# Export main function
export -f show_system_config_menu

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    show_system_config_menu
fi