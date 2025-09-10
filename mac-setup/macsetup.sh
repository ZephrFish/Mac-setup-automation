#!/usr/bin/env bash

# MacSetup - Secure macOS Development Environment Setup
# Version 2.1.0
# 
# A comprehensive, secure, and modular system configuration tool
# for macOS development and media workstations

set -eo pipefail

# Get script directory
export SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common libraries
source "${SCRIPT_DIR}/lib/common.sh"
source "${SCRIPT_DIR}/lib/colors.sh"
source "${SCRIPT_DIR}/lib/validators.sh"

# Source modules
source "${SCRIPT_DIR}/modules/dev-tools.sh"
source "${SCRIPT_DIR}/modules/shell-setup.sh"
source "${SCRIPT_DIR}/modules/system-config.sh"

# Script metadata
readonly VERSION="2.1.0"
readonly SCRIPT_NAME="MacSetup"

# Parse command line arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --dry-run)
                export DRY_RUN=true
                log INFO "Dry run mode enabled - no changes will be made"
                ;;
            --verbose|-v)
                export VERBOSE=true
                log INFO "Verbose mode enabled"
                ;;
            --verify)
                export VERIFY_MODE=true
                log INFO "Verify mode enabled - will prompt before major changes"
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            --version)
                echo "$SCRIPT_NAME version $VERSION"
                exit 0
                ;;
            --quick)
                QUICK_SETUP=true
                ;;
            *)
                log ERROR "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
        shift
    done
}

# Show help message
show_help() {
    cat <<EOF
$SCRIPT_NAME - Secure macOS Development Environment Setup
Version $VERSION

Usage: $0 [OPTIONS]

OPTIONS:
    --dry-run       Run without making any changes (preview mode)
    --verbose, -v   Enable verbose output
    --verify        Prompt before major changes
    --quick         Run quick setup (install everything)
    --help, -h      Show this help message
    --version       Show version information

EXAMPLES:
    # Preview what would be installed
    $0 --dry-run

    # Run with verification prompts
    $0 --verify

    # Quick setup with verbose output
    $0 --quick --verbose

For more information, see README.md
EOF
}

# Check prerequisites
check_prerequisites() {
    log INFO "Checking prerequisites..."
    
    # Check macOS
    check_macos
    
    # Check disk space (require 10GB free)
    if ! validate_disk_space 10 "/"; then
        log ERROR "Insufficient disk space"
        exit 1
    fi
    
    # Check network connectivity
    if ! validate_network "github.com"; then
        log ERROR "No network connectivity"
        exit 1
    fi
    
    # Ensure Homebrew is installed
    ensure_homebrew
    
    log SUCCESS "Prerequisites check passed"
}

# Quick setup - install everything
quick_setup() {
    print_header "Quick Setup - Installing Everything"
    
    log WARNING "This will install and configure all components"
    if ! confirm "Are you sure you want to continue?" "n"; then
        log INFO "Quick setup cancelled"
        return 0
    fi
    
    # Run all modules
    log INFO "Installing development tools..."
    install_dev_category "development-core"
    install_dev_category "development-containers"
    install_dev_category "development-databases"
    install_dev_category "development-cloud"
    
    log INFO "Setting up shell environment..."
    install_ohmyzsh
    for plugin in "${!ZSH_PLUGINS[@]}"; do
        install_zsh_plugin "$plugin"
    done
    configure_zshrc
    configure_fzf
    
    log INFO "Configuring system settings..."
    apply_performance_optimizations
    apply_ssd_optimizations
    apply_developer_settings
    configure_finder
    apply_network_optimizations
    increase_system_limits
    configure_touchid_sudo
    
    log SUCCESS "Quick setup complete!"
    log INFO "Please restart your Mac to apply all changes"
}

# Check installation status
check_status() {
    print_header "Installation Status"
    
    # Check Homebrew
    echo -n "Homebrew: "
    if command_exists brew; then
        print_check "Installed ($(brew --version | head -1))"
    else
        print_cross "Not installed"
    fi
    
    # Check key tools
    local tools=("git" "node" "python3" "go" "rustc" "docker" "fzf" "tmux" "nvim")
    
    echo ""
    echo "Development Tools:"
    for tool in "${tools[@]}"; do
        echo -n "  $tool: "
        if command_exists "$tool"; then
            print_check "Installed"
        else
            print_cross "Not installed"
        fi
    done
    
    # Check Oh My Zsh
    echo ""
    echo -n "Oh My Zsh: "
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        print_check "Installed"
    else
        print_cross "Not installed"
    fi
    
    # Check Touch ID for sudo
    echo -n "Touch ID for sudo: "
    if [[ -f "/etc/pam.d/sudo_local" ]]; then
        print_check "Configured"
    else
        print_cross "Not configured"
    fi
    
    # Check system settings
    echo ""
    echo "System Settings:"
    echo -n "  Hidden files: "
    if defaults read com.apple.finder AppleShowAllFiles 2>/dev/null | grep -q "1"; then
        print_check "Visible"
    else
        print_cross "Hidden"
    fi
    
    echo -n "  File extensions: "
    if defaults read NSGlobalDomain AppleShowAllExtensions 2>/dev/null | grep -q "1"; then
        print_check "Shown"
    else
        print_cross "Hidden"
    fi
    
    echo ""
    echo "Log file: $LOG_FILE"
}

# Main menu
main_menu() {
    while true; do
        print_header "$SCRIPT_NAME - Main Menu"
        
        echo "Version $VERSION"
        echo ""
        
        if [[ "$DRY_RUN" == "true" ]]; then
            print_warning "DRY RUN MODE - No changes will be made"
            echo ""
        fi
        
        print_bullet "[1] Quick Setup (Install Everything)"
        print_bullet "[2] Install Development Tools"
        print_bullet "[3] Setup Shell Environment"
        print_bullet "[4] Configure System Settings"
        print_bullet "[5] Check Installation Status"
        print_bullet "[Q] Quit"
        echo ""
        
        read -p "$(echo -e ${COLOR_PROMPT}Enter your choice: ${NC})" choice
        
        case ${choice,,} in
            1) quick_setup ;;
            2) show_dev_tools_menu ;;
            3) show_shell_setup_menu ;;
            4) show_system_config_menu ;;
            5) check_status ;;
            q) 
                log INFO "Exiting $SCRIPT_NAME"
                exit 0
                ;;
            *)
                log ERROR "Invalid choice: $choice"
                sleep 1
                ;;
        esac
        
        echo ""
        read -p "Press Enter to continue..."
    done
}

# Main execution
main() {
    # Set error trap
    set_error_trap
    
    # Parse arguments
    parse_arguments "$@"
    
    # Show header
    print_header "$SCRIPT_NAME"
    echo "Secure macOS Development Environment Setup"
    echo "Version $VERSION"
    echo ""
    
    # Check prerequisites
    check_prerequisites
    
    # Run quick setup if requested
    if [[ "${QUICK_SETUP:-false}" == "true" ]]; then
        quick_setup
        exit 0
    fi
    
    # Show main menu
    main_menu
}

# Run main function
main "$@"