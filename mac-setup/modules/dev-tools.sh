#!/bin/bash

# Development Tools Module
# Handles installation of development environments and tools

# Source common functions
SCRIPT_DIR="${SCRIPT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
source "${SCRIPT_DIR}/lib/common.sh"
source "${SCRIPT_DIR}/lib/validators.sh"

# Module configuration
MODULE_NAME="Development Tools"
PACKAGES_CONFIG="${CONFIG_DIR}/packages.conf"

# Read package definitions
load_package_definitions() {
    local category="$1"
    local packages=()
    
    while IFS='=' read -r package description; do
        [[ "$package" =~ ^[[:space:]]*# ]] && continue
        [[ -z "$package" ]] && continue
        
        package=$(echo "$package" | xargs)
        packages+=("$package")
    done < <(sed -n "/\[$category\]/,/\[/p" "$PACKAGES_CONFIG" | grep -v '^\[' | head -n -1)
    
    echo "${packages[@]}"
}

# Install development tools with verification
install_dev_category() {
    local category="$1"
    local packages=($(load_package_definitions "$category"))
    
    if [[ ${#packages[@]} -eq 0 ]]; then
        log WARNING "No packages found for category: $category"
        return 1
    fi
    
    log INFO "Installing $category packages: ${packages[*]}"
    
    # Determine if packages are casks
    local brew_command="brew install"
    if [[ "$category" == *"-gui" ]] || [[ "$category" == "development-containers" && "${packages[*]}" =~ "orbstack" ]]; then
        brew_command="brew install --cask"
    fi
    
    # Install packages with error handling
    for package in "${packages[@]}"; do
        if ! validate_package_name "$package"; then
            log ERROR "Invalid package name: $package"
            continue
        fi
        
        if command_exists "${package%@*}" 2>/dev/null; then
            log INFO "$package already installed"
            continue
        fi
        
        log INFO "Installing $package..."
        if execute "$brew_command $package"; then
            log SUCCESS "$package installed successfully"
        else
            log ERROR "Failed to install $package"
            # Continue with other packages
        fi
    done
    
    return 0
}

# Configure git with secure defaults
configure_git() {
    log INFO "Configuring Git with secure defaults..."
    
    execute "git config --global init.defaultBranch main"
    execute "git config --global pull.rebase false"
    execute "git config --global core.autocrlf input"
    execute "git config --global core.whitespace trailing-space,space-before-tab"
    
    # Security settings
    execute "git config --global transfer.fsckObjects true"
    execute "git config --global receive.fsckObjects true"
    execute "git config --global fetch.fsckObjects true"
    
    log SUCCESS "Git configured successfully"
}

# Setup Python environment
setup_python() {
    log INFO "Setting up Python environment..."
    
    if command_exists python3; then
        # Create virtual environment directory
        local venv_dir="$HOME/.virtualenvs"
        execute "mkdir -p $venv_dir"
        
        # Install essential Python packages
        execute "python3 -m pip install --upgrade pip"
        execute "python3 -m pip install virtualenv pipenv"
        
        log SUCCESS "Python environment configured"
    else
        log WARNING "Python not installed, skipping configuration"
    fi
}

# Setup Node.js environment
setup_nodejs() {
    log INFO "Setting up Node.js environment..."
    
    if command_exists node; then
        # Install global packages
        local npm_packages=(
            "npm@latest"
            "yarn"
            "pnpm"
            "typescript"
            "ts-node"
            "nodemon"
        )
        
        for package in "${npm_packages[@]}"; do
            execute "npm install -g $package"
        done
        
        log SUCCESS "Node.js environment configured"
    else
        log WARNING "Node.js not installed, skipping configuration"
    fi
}

# Setup Docker environment
setup_docker() {
    log INFO "Setting up Docker environment..."
    
    if command_exists docker; then
        # Create Docker config directory
        local docker_config="$HOME/.docker"
        execute "mkdir -p $docker_config"
        
        # Configure Docker memory limits for M4 Max (suggest 16-24GB)
        if [[ -f "$docker_config/daemon.json" ]]; then
            backup_file "$docker_config/daemon.json"
        fi
        
        cat > "$docker_config/daemon.json" <<EOF
{
  "builder": {
    "gc": {
      "defaultKeepStorage": "20GB",
      "enabled": true
    }
  },
  "experimental": false,
  "features": {
    "buildkit": true
  }
}
EOF
        
        log SUCCESS "Docker environment configured"
        log INFO "Remember to set memory limits in Docker Desktop or OrbStack (recommended: 16-24GB)"
    else
        log WARNING "Docker not installed, skipping configuration"
    fi
}

# Main installation menu
show_dev_tools_menu() {
    print_header "$MODULE_NAME Installation"
    
    local categories=(
        "1:Core Development:development-core"
        "2:Containers & Virtualization:development-containers"
        "3:Databases:development-databases"
        "4:Cloud CLIs:development-cloud"
        "5:All Development Tools:ALL"
    )
    
    echo "Select development tools to install:"
    for item in "${categories[@]}"; do
        IFS=':' read -r num name category <<< "$item"
        print_bullet "[$num] $name"
    done
    print_bullet "[0] Back to main menu"
    echo ""
    
    read -p "$(echo -e ${COLOR_PROMPT}Enter your choice: ${NC})" choice
    
    # Validate input
    if ! validate_menu_choice "$choice" 0 1 2 3 4 5; then
        log ERROR "Invalid choice: $choice"
        return 1
    fi
    
    case $choice in
        1) install_dev_category "development-core" ;;
        2) install_dev_category "development-containers" ;;
        3) install_dev_category "development-databases" ;;
        4) install_dev_category "development-cloud" ;;
        5)
            install_dev_category "development-core"
            install_dev_category "development-containers"
            install_dev_category "development-databases"
            install_dev_category "development-cloud"
            ;;
        0) return 0 ;;
    esac
    
    # Post-installation configuration
    if confirm "Configure installed tools?" "y"; then
        configure_git
        setup_python
        setup_nodejs
        setup_docker
    fi
    
    log SUCCESS "$MODULE_NAME installation complete"
    read -p "Press Enter to continue..."
}

# Export main function
export -f show_dev_tools_menu

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    show_dev_tools_menu
fi