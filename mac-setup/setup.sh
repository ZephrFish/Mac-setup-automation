#!/usr/bin/env bash

# ==================================================================
# MacSetup - Comprehensive macOS Development Environment Setup
# Version 3.0.0
# 
# A secure, modular, and comprehensive system configuration tool
# for macOS development and media workstations
# 
# Optimized for Apple Silicon (M3/M4) with 64GB+ RAM
# ==================================================================

set -eo pipefail

# Script metadata
readonly VERSION="3.0.0"
readonly SCRIPT_NAME="MacSetup"
export SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source libraries
source "${SCRIPT_DIR}/lib/common.sh"
source "${SCRIPT_DIR}/lib/colors.sh"
source "${SCRIPT_DIR}/lib/validators.sh"

# Configuration
readonly CONFIG_FILE="${SCRIPT_DIR}/config/setup.conf"
readonly BREWFILE="${SCRIPT_DIR}/config/Brewfile"
readonly CHECKSUMS_FILE="${SCRIPT_DIR}/config/checksums.conf"

# Global variables
SETUP_MODE=""
PROFILE=""
SKIP_CONFIRMATIONS=false
INSTALL_OPTIONAL=false

# ==================================================================
# Core Functions
# ==================================================================

show_banner() {
    clear
    echo -e "${BLUE}"
    cat << 'EOF'
    __  ___           _____      __            
   /  |/  /___ ______/ ___/___  / /___  ______ 
  / /|_/ / __ `/ ___/\__ \/ _ \/ __/ / / / __ \
 / /  / / /_/ / /__ ___/ /  __/ /_/ /_/ / /_/ /
/_/  /_/\__,_/\___//____/\___/\__/\__,_/ .___/ 
                                      /_/       
EOF
    echo -e "${NC}"
    echo -e "${CYAN}Version ${VERSION}${NC}"
    echo -e "${GRAY}Comprehensive macOS Development Environment Setup${NC}"
    echo ""
}

show_help() {
    cat <<EOF
${SCRIPT_NAME} - Comprehensive macOS Development Environment Setup
Version ${VERSION}

Usage: $0 [OPTIONS] [COMMAND]

COMMANDS:
    quick           Run quick setup with recommended settings
    full            Run full setup with all options
    minimal         Run minimal setup (essentials only)
    dev             Setup development tools only
    shell           Setup shell environment only
    system          Configure system settings only
    security        Setup security tools only
    media           Setup media production tools
    status          Check installation status
    verify          Verify all installations
    rollback        Rollback recent changes

OPTIONS:
    --profile PROFILE    Use predefined profile (developer|designer|devops|data-scientist|media)
    --dry-run           Preview changes without applying them
    --verbose, -v       Enable verbose output
    --quiet, -q         Suppress non-critical output
    --no-confirm        Skip confirmation prompts
    --with-optional     Include optional packages
    --backup            Create full system backup before changes
    --log-level LEVEL   Set log level (DEBUG|INFO|WARNING|ERROR)
    --help, -h          Show this help message
    --version           Show version information

PROFILES:
    developer       Full-stack development (default)
    designer        Design and frontend development
    devops          DevOps and infrastructure
    data-scientist  Data science and machine learning
    media          Media production and editing

EXAMPLES:
    # Quick setup with developer profile
    $0 quick --profile developer

    # Preview full installation
    $0 full --dry-run

    # Minimal setup without confirmations
    $0 minimal --no-confirm

    # Check current status
    $0 status

    # Setup only development tools
    $0 dev --with-optional

For more information, see README.md or visit:
https://github.com/yourusername/macsetup
EOF
}

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            quick|full|minimal|dev|shell|system|security|media|status|verify|rollback)
                SETUP_MODE="$1"
                ;;
            --profile)
                PROFILE="$2"
                shift
                ;;
            --dry-run)
                export DRY_RUN=true
                log INFO "Dry run mode enabled - no changes will be made"
                ;;
            --verbose|-v)
                export VERBOSE=true
                log INFO "Verbose mode enabled"
                ;;
            --quiet|-q)
                export QUIET=true
                ;;
            --no-confirm)
                SKIP_CONFIRMATIONS=true
                ;;
            --with-optional)
                INSTALL_OPTIONAL=true
                ;;
            --backup)
                CREATE_BACKUP=true
                ;;
            --log-level)
                export LOG_LEVEL="$2"
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            --version)
                echo "${SCRIPT_NAME} version ${VERSION}"
                exit 0
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

# ==================================================================
# Installation Functions
# ==================================================================

install_xcode_tools() {
    print_header "Installing Xcode Command Line Tools"
    
    if xcode-select -p &>/dev/null; then
        log SUCCESS "Xcode Command Line Tools already installed"
        return 0
    fi
    
    log INFO "Installing Xcode Command Line Tools..."
    execute "xcode-select --install"
    
    # Wait for installation
    until xcode-select -p &>/dev/null; do
        sleep 5
    done
    
    log SUCCESS "Xcode Command Line Tools installed"
}

setup_homebrew() {
    print_header "Setting up Homebrew"
    
    ensure_homebrew
    
    log INFO "Updating Homebrew..."
    execute "brew update"
    
    # Brew bundle is now built into Homebrew core, no tap needed
    
    if [[ -f "$BREWFILE" ]]; then
        log INFO "Installing packages from Brewfile..."
        execute "brew bundle install --file='$BREWFILE'"
    else
        log WARNING "Brewfile not found, using default package list"
        install_default_packages
    fi
    
    log SUCCESS "Homebrew setup complete"
}

install_default_packages() {
    log INFO "Installing default packages..."
    
    # Essential CLI tools
    local essential_tools=(
        "git"
        "gh"
        "wget"
        "curl"
        "tree"
        "htop"
        "ncdu"
        "jq"
        "yq"
    )
    
    # Development tools
    local dev_tools=(
        "node"
        "python@3.12"
        "go"
        "rust"
        "docker"
        "docker-compose"
    )
    
    # Productivity tools
    local productivity_tools=(
        "fzf"
        "ripgrep"
        "bat"
        "eza"
        "tldr"
        "tmux"
        "neovim"
        "lazygit"
        "lazydocker"
    )
    
    # Install in batches
    log INFO "Installing essential tools..."
    execute "brew install ${essential_tools[*]}"
    
    log INFO "Installing development tools..."
    execute "brew install ${dev_tools[*]}"
    
    log INFO "Installing productivity tools..."
    execute "brew install ${productivity_tools[*]}"
}

setup_development_environment() {
    print_header "Setting up Development Environment"
    
    case "${PROFILE:-developer}" in
        developer)
            setup_fullstack_dev
            ;;
        designer)
            setup_designer_env
            ;;
        devops)
            setup_devops_env
            ;;
        data-scientist)
            setup_data_science_env
            ;;
        media)
            setup_media_env
            ;;
        *)
            log WARNING "Unknown profile: $PROFILE, using developer"
            setup_fullstack_dev
            ;;
    esac
}

setup_fullstack_dev() {
    log INFO "Setting up full-stack development environment..."
    
    # Frontend tools
    execute "npm install -g yarn pnpm typescript @angular/cli @vue/cli create-react-app"
    
    # Backend tools
    execute "brew install postgresql@16 redis mongodb-community mysql"
    
    # Cloud tools
    execute "brew install awscli azure-cli google-cloud-sdk terraform"
    
    # Container tools
    execute "brew install --cask docker orbstack"
    
    log SUCCESS "Full-stack development environment ready"
}

setup_designer_env() {
    log INFO "Setting up designer environment..."
    
    # Design tools
    execute "brew install --cask figma sketch adobe-creative-cloud"
    
    # Frontend tools
    execute "npm install -g tailwindcss postcss autoprefixer"
    
    log SUCCESS "Designer environment ready"
}

setup_devops_env() {
    log INFO "Setting up DevOps environment..."
    
    # Infrastructure tools
    execute "brew install terraform ansible kubectl helm vault"
    
    # Monitoring tools
    execute "brew install prometheus grafana datadog"
    
    # CI/CD tools
    execute "brew install jenkins circleci gitlab-runner"
    
    log SUCCESS "DevOps environment ready"
}

setup_data_science_env() {
    log INFO "Setting up data science environment..."
    
    # Python packages
    execute "pip3 install numpy pandas scikit-learn matplotlib jupyter notebook"
    
    # R and related tools
    execute "brew install --cask r rstudio"
    
    # Database tools
    execute "brew install apache-spark hadoop"
    
    log SUCCESS "Data science environment ready"
}

setup_media_env() {
    log INFO "Setting up media production environment..."
    
    # Video editing
    execute "brew install --cask final-cut-pro davinci-resolve adobe-premiere-pro"
    
    # Audio tools
    execute "brew install --cask logic-pro ableton-live audacity"
    
    # Graphics tools
    execute "brew install --cask adobe-photoshop affinity-photo blender"
    
    log SUCCESS "Media production environment ready"
}

# ==================================================================
# Shell Configuration
# ==================================================================

setup_shell_environment() {
    print_header "Setting up Shell Environment"
    
    # Install Oh My Zsh
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        log INFO "Installing Oh My Zsh..."
        
        # Download with checksum verification
        local omz_installer="$CACHE_DIR/omz-install.sh"
        download_with_retry \
            "https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh" \
            "$omz_installer"
        
        # Verify checksum if available
        if [[ -f "$CHECKSUMS_FILE" ]]; then
            local expected_checksum=$(grep "omz-install.sh" "$CHECKSUMS_FILE" | cut -d' ' -f1)
            if [[ -n "$expected_checksum" ]]; then
                verify_checksum "$omz_installer" "$expected_checksum"
            fi
        fi
        
        execute "sh '$omz_installer' --unattended"
    else
        log SUCCESS "Oh My Zsh already installed"
    fi
    
    # Install Zsh plugins
    install_zsh_plugins
    
    # Configure shell
    configure_shell
    
    log SUCCESS "Shell environment configured"
}

install_zsh_plugins() {
    log INFO "Installing Zsh plugins..."
    
    local plugins=(
        "zsh-users/zsh-autosuggestions"
        "zsh-users/zsh-syntax-highlighting"
        "zsh-users/zsh-completions"
        "romkatv/powerlevel10k"
    )
    
    local custom_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    
    for plugin_repo in "${plugins[@]}"; do
        local plugin_name=$(basename "$plugin_repo")
        local plugin_dir="$custom_dir/plugins/$plugin_name"
        
        if [[ "$plugin_repo" == *"powerlevel10k" ]]; then
            plugin_dir="$custom_dir/themes/$plugin_name"
        fi
        
        if [[ ! -d "$plugin_dir" ]]; then
            log INFO "Installing $plugin_name..."
            execute "git clone --depth=1 https://github.com/$plugin_repo '$plugin_dir'"
        else
            log SUCCESS "$plugin_name already installed"
        fi
    done
}

configure_shell() {
    log INFO "Configuring shell..."
    
    # Backup existing .zshrc
    backup_file "$HOME/.zshrc"
    
    # Create custom .zshrc
    cat > "$HOME/.zshrc" << 'EOF'
# MacSetup Zsh Configuration
# Generated by MacSetup v3.0.0

# Path to oh-my-zsh
export ZSH="$HOME/.oh-my-zsh"

# Theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins
plugins=(
    git
    docker
    docker-compose
    kubectl
    terraform
    aws
    npm
    yarn
    python
    golang
    rust
    fzf
    tmux
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-completions
)

# Oh My Zsh
source $ZSH/oh-my-zsh.sh

# User configuration
export LANG=en_US.UTF-8
export EDITOR='nvim'
export VISUAL='nvim'

# Homebrew
if [[ -f "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# FZF
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Aliases
alias ll='eza -la --icons'
alias la='eza -la --icons'
alias lt='eza --tree --icons'
alias cat='bat'
alias find='fd'
alias grep='rg'
alias vim='nvim'
alias dc='docker-compose'
alias k='kubectl'
alias tf='terraform'
alias lg='lazygit'
alias ld='lazydocker'

# Functions
mkcd() { mkdir -p "$1" && cd "$1"; }
backup() { cp "$1" "$1.$(date +%Y%m%d-%H%M%S).bak"; }
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2) tar xjf "$1" ;;
            *.tar.gz) tar xzf "$1" ;;
            *.bz2) bunzip2 "$1" ;;
            *.gz) gunzip "$1" ;;
            *.tar) tar xf "$1" ;;
            *.tbz2) tar xjf "$1" ;;
            *.tgz) tar xzf "$1" ;;
            *.zip) unzip "$1" ;;
            *.Z) uncompress "$1" ;;
            *.7z) 7z x "$1" ;;
            *) echo "'$1' cannot be extracted" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Custom prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Load local configuration if exists
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
EOF
    
    log SUCCESS "Shell configuration complete"
}

# ==================================================================
# System Configuration
# ==================================================================

configure_system_settings() {
    print_header "Configuring System Settings"
    
    log INFO "Applying system optimizations..."
    
    # General settings
    configure_general_settings
    
    # Finder settings
    configure_finder_settings
    
    # Performance optimizations
    configure_performance_settings
    
    # Developer settings
    configure_developer_settings
    
    # Security settings
    configure_security_settings
    
    log SUCCESS "System configuration complete"
}

configure_general_settings() {
    log INFO "Configuring general settings..."
    
    # Show battery percentage
    execute "defaults write com.apple.menuextra.battery ShowPercent YES"
    
    # Enable tap to click
    execute "defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true"
    execute "defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1"
    
    # Keyboard settings
    execute "defaults write NSGlobalDomain KeyRepeat -int 2"
    execute "defaults write NSGlobalDomain InitialKeyRepeat -int 15"
    
    # Disable auto-correct
    execute "defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false"
}

configure_finder_settings() {
    log INFO "Configuring Finder..."
    
    # Show hidden files
    execute "defaults write com.apple.finder AppleShowAllFiles -bool true"
    
    # Show file extensions
    execute "defaults write NSGlobalDomain AppleShowAllExtensions -bool true"
    
    # Show path bar
    execute "defaults write com.apple.finder ShowPathbar -bool true"
    
    # Show status bar
    execute "defaults write com.apple.finder ShowStatusBar -bool true"
    
    # Use list view by default
    execute "defaults write com.apple.finder FXPreferredViewStyle -string 'Nlsv'"
    
    # Keep folders on top
    execute "defaults write com.apple.finder _FXSortFoldersFirst -bool true"
    
    # Restart Finder
    execute "killall Finder"
}

configure_performance_settings() {
    log INFO "Configuring performance settings..."
    
    # Disable animations
    execute "defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false"
    execute "defaults write com.apple.dock autohide-time-modifier -float 0"
    execute "defaults write com.apple.dock autohide-delay -float 0"
    
    # SSD optimizations
    execute "sudo pmset -a hibernatemode 0"
    execute "sudo rm -f /var/vm/sleepimage"
    execute "sudo mkdir /var/vm/sleepimage"
    
    # Increase system limits
    execute "sudo launchctl limit maxfiles 65536 200000"
    execute "sudo launchctl limit maxproc 2048 4096"
}

configure_developer_settings() {
    log INFO "Configuring developer settings..."
    
    # Enable developer menu in Safari
    execute "defaults write com.apple.Safari IncludeDevelopMenu -bool true"
    
    # Show full URL in Safari
    execute "defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true"
    
    # Enable debug menu in App Store
    execute "defaults write com.apple.appstore ShowDebugMenu -bool true"
    
    # Create development directories
    execute "mkdir -p ~/Development ~/Projects ~/Scripts"
}

configure_security_settings() {
    log INFO "Configuring security settings..."
    
    # Enable firewall
    execute "sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on"
    
    # Enable stealth mode
    execute "sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on"
    
    # Configure Touch ID for sudo
    configure_touchid_sudo
    
    # Setup 1Password CLI
    setup_1password
}

configure_touchid_sudo() {
    log INFO "Configuring Touch ID for sudo..."
    
    # Check if Mac has Touch ID
    if ! system_profiler SPHardwareDataType | grep -q "Touch ID" && \
       ! ioreg -c AppleEmbeddedOSSupportHost | grep -q "AppleEmbeddedOSSupportHost"; then
        log WARNING "Touch ID not available on this Mac"
        return 0
    fi
    
    # Create sudo_local file with Touch ID support
    local sudo_config="/etc/pam.d/sudo_local"
    
    if [[ ! -f "$sudo_config" ]]; then
        echo "auth       sufficient     pam_tid.so" | sudo tee "$sudo_config" > /dev/null
        log SUCCESS "Touch ID configured for sudo"
    else
        log SUCCESS "Touch ID already configured for sudo"
    fi
}

setup_1password() {
    log INFO "Setting up 1Password CLI..."
    
    if ! command_exists op; then
        execute "brew install --cask 1password 1password-cli"
    fi
    
    log SUCCESS "1Password CLI ready"
}

# ==================================================================
# Status and Verification
# ==================================================================

check_status() {
    print_header "System Status Check"
    
    echo -e "${CYAN}System Information:${NC}"
    echo "  macOS Version: $(sw_vers -productVersion)"
    echo "  Architecture: $(uname -m)"
    echo "  Hostname: $(hostname)"
    echo ""
    
    echo -e "${CYAN}Core Tools:${NC}"
    check_tool_status "Homebrew" "brew"
    check_tool_status "Git" "git"
    check_tool_status "Node.js" "node"
    check_tool_status "Python" "python3"
    check_tool_status "Go" "go"
    check_tool_status "Rust" "rustc"
    check_tool_status "Docker" "docker"
    echo ""
    
    echo -e "${CYAN}Shell Environment:${NC}"
    check_directory_status "Oh My Zsh" "$HOME/.oh-my-zsh"
    check_file_status "Zsh Config" "$HOME/.zshrc"
    echo ""
    
    echo -e "${CYAN}Security:${NC}"
    check_tool_status "1Password CLI" "op"
    check_file_status "Touch ID Sudo" "/etc/pam.d/sudo_local"
    echo ""
    
    echo -e "${CYAN}System Settings:${NC}"
    check_setting "Hidden Files" "com.apple.finder AppleShowAllFiles" "1"
    check_setting "File Extensions" "NSGlobalDomain AppleShowAllExtensions" "1"
    check_setting "Developer Menu" "com.apple.Safari IncludeDevelopMenu" "1"
}

check_tool_status() {
    local name="$1"
    local command="$2"
    
    printf "  %-20s: " "$name"
    if command_exists "$command"; then
        local version=$($command --version 2>/dev/null | head -1)
        print_check "Installed - $version"
    else
        print_cross "Not installed"
    fi
}

check_directory_status() {
    local name="$1"
    local path="$2"
    
    printf "  %-20s: " "$name"
    if [[ -d "$path" ]]; then
        print_check "Installed"
    else
        print_cross "Not installed"
    fi
}

check_file_status() {
    local name="$1"
    local path="$2"
    
    printf "  %-20s: " "$name"
    if [[ -f "$path" ]]; then
        print_check "Configured"
    else
        print_cross "Not configured"
    fi
}

check_setting() {
    local name="$1"
    local key="$2"
    local expected="$3"
    
    printf "  %-20s: " "$name"
    if defaults read $key 2>/dev/null | grep -q "$expected"; then
        print_check "Enabled"
    else
        print_cross "Disabled"
    fi
}

# ==================================================================
# Main Execution
# ==================================================================

main() {
    # Set error trap
    set_error_trap
    
    # Parse arguments
    parse_arguments "$@"
    
    # Show banner
    show_banner
    
    # Check prerequisites
    check_macos
    
    # Execute based on mode
    case "$SETUP_MODE" in
        quick)
            run_quick_setup
            ;;
        full)
            run_full_setup
            ;;
        minimal)
            run_minimal_setup
            ;;
        dev)
            setup_development_environment
            ;;
        shell)
            setup_shell_environment
            ;;
        system)
            configure_system_settings
            ;;
        security)
            configure_security_settings
            ;;
        media)
            setup_media_env
            ;;
        status)
            check_status
            ;;
        verify)
            verify_installation
            ;;
        rollback)
            rollback_changes
            ;;
        *)
            show_interactive_menu
            ;;
    esac
    
    # Show completion message
    if [[ "$SETUP_MODE" != "status" ]]; then
        print_header "Setup Complete!"
        log SUCCESS "All tasks completed successfully"
        log INFO "Log file: $LOG_FILE"
        log INFO "Please restart your terminal or run: source ~/.zshrc"
    fi
}

run_quick_setup() {
    print_header "Quick Setup"
    
    log INFO "Running quick setup with recommended settings..."
    
    install_xcode_tools
    setup_homebrew
    setup_development_environment
    setup_shell_environment
    configure_system_settings
}

run_full_setup() {
    print_header "Full Setup"
    
    log INFO "Running complete system setup..."
    
    install_xcode_tools
    setup_homebrew
    setup_development_environment
    setup_shell_environment
    configure_system_settings
    
    if [[ "$INSTALL_OPTIONAL" == "true" ]]; then
        log INFO "Installing optional packages..."
        install_optional_packages
    fi
}

run_minimal_setup() {
    print_header "Minimal Setup"
    
    log INFO "Running minimal setup..."
    
    install_xcode_tools
    setup_homebrew
    setup_shell_environment
}

show_interactive_menu() {
    while true; do
        print_header "Interactive Setup Menu"
        
        echo "Please select an option:"
        echo ""
        print_bullet "[1] Quick Setup (Recommended)"
        print_bullet "[2] Full Setup (Everything)"
        print_bullet "[3] Minimal Setup (Essentials)"
        print_bullet "[4] Development Tools"
        print_bullet "[5] Shell Environment"
        print_bullet "[6] System Settings"
        print_bullet "[7] Security Settings"
        print_bullet "[8] Check Status"
        print_bullet "[Q] Quit"
        echo ""
        
        read -p "$(echo -e ${COLOR_PROMPT}Enter your choice: ${NC})" choice
        
        case ${choice,,} in
            1) run_quick_setup; break ;;
            2) run_full_setup; break ;;
            3) run_minimal_setup; break ;;
            4) setup_development_environment; break ;;
            5) setup_shell_environment; break ;;
            6) configure_system_settings; break ;;
            7) configure_security_settings; break ;;
            8) check_status ;;
            q) log INFO "Exiting..."; exit 0 ;;
            *) log ERROR "Invalid choice: $choice" ;;
        esac
        
        echo ""
        read -p "Press Enter to continue..."
    done
}

verify_installation() {
    print_header "Verification"
    
    log INFO "Verifying all installations..."
    
    local failed=0
    
    # Check essential tools
    for tool in brew git node python3; do
        if ! command_exists "$tool"; then
            log ERROR "$tool is not installed"
            ((failed++))
        fi
    done
    
    if [[ $failed -eq 0 ]]; then
        log SUCCESS "All verifications passed"
    else
        log ERROR "$failed verifications failed"
        exit 1
    fi
}

rollback_changes() {
    print_header "Rollback"
    
    log WARNING "This will rollback recent changes"
    
    if ! confirm "Are you sure you want to rollback?" "n"; then
        log INFO "Rollback cancelled"
        return 0
    fi
    
    # Restore backed up files
    for backup in "$BACKUP_DIR"/*.bak; do
        if [[ -f "$backup" ]]; then
            local original="${backup%.*.bak}"
            log INFO "Restoring $original..."
            restore_file "$original"
        fi
    done
    
    log SUCCESS "Rollback complete"
}

install_optional_packages() {
    log INFO "Installing optional packages..."
    
    # Optional development tools
    execute "brew install graphviz plantuml mermaid-cli"
    
    # Optional productivity tools
    execute "brew install --cask notion obsidian alfred rectangle"
    
    # Optional terminal tools
    execute "brew install --cask iterm2 warp kitty"
}

# Run main function
main "$@"