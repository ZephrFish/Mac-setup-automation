#!/bin/bash

# Zsh Configuration Module
# Handles .zshrc configuration and customisation

# Source common functions
SCRIPT_DIR="${SCRIPT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
source "${SCRIPT_DIR}/lib/common.sh"

# Module configuration
MODULE_NAME="Zsh Configuration"
CONFIG_DIR="${SCRIPT_DIR}/config"
ZSHRC_TEMPLATE="${CONFIG_DIR}/.zshrc"
BACKUP_DIR="${HOME}/.config/mac-setup/backups"

# Create backup of existing .zshrc
backup_zshrc() {
    if [[ -f "$HOME/.zshrc" ]]; then
        mkdir -p "$BACKUP_DIR"
        local backup_file="${BACKUP_DIR}/.zshrc.$(date +%Y%m%d-%H%M%S).bak"
        log INFO "Backing up existing .zshrc to $backup_file"
        cp "$HOME/.zshrc" "$backup_file"
        return 0
    fi
    return 1
}

# Install base .zshrc configuration
install_zshrc() {
    log INFO "Installing Zsh configuration..."
    
    # Check if template exists
    if [[ ! -f "$ZSHRC_TEMPLATE" ]]; then
        log ERROR "Zsh configuration template not found at $ZSHRC_TEMPLATE"
        return 1
    fi
    
    # Backup existing configuration
    backup_zshrc
    
    # Copy template to home directory
    if cp "$ZSHRC_TEMPLATE" "$HOME/.zshrc"; then
        log SUCCESS "Zsh configuration installed"
    else
        log ERROR "Failed to install Zsh configuration"
        return 1
    fi
    
    # Create .zshrc.local for personal customisation
    if [[ ! -f "$HOME/.zshrc.local" ]]; then
        cat > "$HOME/.zshrc.local" << 'EOF'
# Personal Zsh Configuration
# Add your personal settings, aliases, and sensitive configuration here
# This file is sourced by .zshrc and should not be committed to version control

# Example personal aliases
# alias myproject='cd ~/projects/myproject'

# Example environment variables
# export MY_API_KEY="your-api-key-here"

EOF
        log INFO "Created .zshrc.local for personal configuration"
    fi
    
    return 0
}

# Configure Powerlevel10k theme
configure_p10k() {
    log INFO "Setting up Powerlevel10k theme..."
    
    local p10k_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    
    if [[ ! -d "$p10k_dir" ]]; then
        log INFO "Installing Powerlevel10k..."
        if git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k_dir"; then
            log SUCCESS "Powerlevel10k installed"
        else
            log ERROR "Failed to install Powerlevel10k"
            return 1
        fi
    else
        log INFO "Powerlevel10k already installed"
    fi
    
    # Check if p10k configuration exists
    if [[ ! -f "$HOME/.p10k.zsh" ]]; then
        log INFO "Powerlevel10k configuration will be set up on first run"
        log INFO "Run 'p10k configure' after sourcing .zshrc"
    fi
    
    return 0
}

# Install modern CLI tools referenced in .zshrc
install_cli_tools() {
    log INFO "Installing modern CLI tools..."
    
    local tools=(
        "eza"       # Modern ls replacement
        "bat"       # Cat with syntax highlighting
        "fd"        # Fast find alternative
        "ripgrep"   # Fast grep alternative
        "fzf"       # Fuzzy finder
        "neovim"    # Modern vim
        "lazygit"   # Git UI
        "lazydocker" # Docker UI
    )
    
    for tool in "${tools[@]}"; do
        if command -v "$tool" &> /dev/null; then
            log INFO "$tool already installed"
        else
            log INFO "Installing $tool..."
            if brew install "$tool"; then
                log SUCCESS "$tool installed"
            else
                log WARNING "Failed to install $tool"
            fi
        fi
    done
    
    # Configure FZF
    if command -v fzf &> /dev/null; then
        log INFO "Configuring FZF..."
        if [[ -f "$(brew --prefix)/opt/fzf/install" ]]; then
            "$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc --no-bash --no-fish 2>/dev/null
            log SUCCESS "FZF configured"
        fi
    fi
    
    return 0
}

# Update existing .zshrc with our configuration
update_existing_zshrc() {
    log INFO "Updating existing .zshrc configuration..."
    
    local zshrc_file="$HOME/.zshrc"
    
    # Check if our configuration markers exist
    if grep -q "# MacSetup Zsh Configuration" "$zshrc_file" 2>/dev/null; then
        log INFO "MacSetup configuration already present"
        return 0
    fi
    
    # Backup current configuration
    backup_zshrc
    
    # Merge configurations
    log INFO "Merging configurations..."
    
    # Create temporary merged file
    local temp_file=$(mktemp)
    
    # Copy our template
    cp "$ZSHRC_TEMPLATE" "$temp_file"
    
    # Append existing custom configuration if any
    if [[ -f "$zshrc_file" ]]; then
        echo "" >> "$temp_file"
        echo "# === Previous Configuration ===" >> "$temp_file"
        grep -v "^export ZSH=" "$zshrc_file" | \
        grep -v "^ZSH_THEME=" | \
        grep -v "^plugins=(" | \
        grep -v "^source \$ZSH/oh-my-zsh.sh" >> "$temp_file" 2>/dev/null || true
    fi
    
    # Replace .zshrc
    mv "$temp_file" "$zshrc_file"
    
    log SUCCESS "Configuration updated"
    return 0
}

# Main setup function
setup_zshrc() {
    log SECTION "Setting up Zsh configuration"
    
    # Check if Oh My Zsh is installed
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        log ERROR "Oh My Zsh is not installed. Please install it first."
        return 1
    fi
    
    # Determine if we should update or install fresh
    if [[ -f "$HOME/.zshrc" ]]; then
        if confirm "Existing .zshrc found. Update with MacSetup configuration?"; then
            update_existing_zshrc
        else
            log INFO "Keeping existing configuration"
        fi
    else
        install_zshrc
    fi
    
    # Install Powerlevel10k theme
    configure_p10k
    
    # Install CLI tools
    if confirm "Install modern CLI tools (eza, bat, fd, etc.)?"; then
        install_cli_tools
    fi
    
    log SUCCESS "Zsh configuration complete"
    log INFO "Restart your terminal or run: source ~/.zshrc"
    
    return 0
}

# Allow direct execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_zshrc
fi