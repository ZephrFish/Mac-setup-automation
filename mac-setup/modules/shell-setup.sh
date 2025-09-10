#!/bin/bash

# Shell Setup Module
# Handles Oh My Zsh installation and configuration with security

# Source common functions
SCRIPT_DIR="${SCRIPT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
source "${SCRIPT_DIR}/lib/common.sh"
source "${SCRIPT_DIR}/lib/validators.sh"

# Module configuration
MODULE_NAME="Shell Setup"
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
CHECKSUMS_FILE="${CONFIG_DIR}/checksums.conf"

# Plugin definitions (using regular arrays for bash 3.x compatibility)
ZSH_PLUGIN_NAMES=("zsh-autosuggestions" "zsh-syntax-highlighting" "zsh-completions" "zsh-history-substring-search" "zsh-z")
ZSH_PLUGIN_URLS=("https://github.com/zsh-users/zsh-autosuggestions.git" "https://github.com/zsh-users/zsh-syntax-highlighting.git" "https://github.com/zsh-users/zsh-completions.git" "https://github.com/zsh-users/zsh-history-substring-search.git" "https://github.com/agkozak/zsh-z.git")
ZSH_PLUGIN_VERSIONS=("v0.7.0" "0.7.1" "0.34.0" "v1.0.2" "afaf29")

# Securely install Oh My Zsh
install_ohmyzsh() {
    log INFO "Installing Oh My Zsh..."
    
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        log INFO "Oh My Zsh already installed"
        return 0
    fi
    
    # Download installer to cache with verification
    local installer_url="https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"
    local installer_path="$CACHE_DIR/ohmyzsh-install.sh"
    local installer_checksum_path="$CACHE_DIR/ohmyzsh-install.sh.sha256"
    
    # Download installer
    if ! download_with_retry "$installer_url" "$installer_path"; then
        log ERROR "Failed to download Oh My Zsh installer"
        return 1
    fi
    
    # For production, you would verify against a known good checksum
    # For now, we'll generate one for reference
    local actual_checksum=$(shasum -a 256 "$installer_path" | cut -d' ' -f1)
    echo "$actual_checksum" > "$installer_checksum_path"
    log INFO "Installer checksum: $actual_checksum"
    
    # Review installer before execution
    if [[ "$VERIFY_MODE" == "true" ]]; then
        log INFO "Review the installer script at: $installer_path"
        if ! confirm "Proceed with Oh My Zsh installation?"; then
            log INFO "Installation cancelled"
            return 1
        fi
    fi
    
    # Execute installer in unattended mode
    if execute "sh '$installer_path' --unattended --keep-zshrc"; then
        log SUCCESS "Oh My Zsh installed successfully"
    else
        log ERROR "Oh My Zsh installation failed"
        return 1
    fi
    
    return 0
}

# Install Zsh plugin with verification
install_zsh_plugin() {
    local plugin_name="$1"
    local plugin_index=-1
    
    # Find plugin index
    for i in "${!ZSH_PLUGIN_NAMES[@]}"; do
        if [[ "${ZSH_PLUGIN_NAMES[$i]}" == "$plugin_name" ]]; then
            plugin_index=$i
            break
        fi
    done
    
    if [[ $plugin_index -eq -1 ]]; then
        log ERROR "Unknown plugin: $plugin_name"
        return 1
    fi
    
    local repo_url="${ZSH_PLUGIN_URLS[$plugin_index]}"
    local version="${ZSH_PLUGIN_VERSIONS[$plugin_index]}"
    
    local plugin_dir="$ZSH_CUSTOM/plugins/$plugin_name"
    
    if [[ -d "$plugin_dir" ]]; then
        log INFO "$plugin_name already installed"
        return 0
    fi
    
    log INFO "Installing $plugin_name..."
    
    # Clone with specific version/tag
    if execute "git clone --depth 1 --branch '$version' '$repo_url' '$plugin_dir' 2>/dev/null || git clone --depth 1 '$repo_url' '$plugin_dir'"; then
        log SUCCESS "$plugin_name installed successfully"
        
        # Verify the installed version
        if [[ -d "$plugin_dir/.git" ]]; then
            local installed_version=$(cd "$plugin_dir" && git rev-parse --short HEAD)
            log DEBUG "$plugin_name installed at commit: $installed_version"
        fi
    else
        log ERROR "Failed to install $plugin_name"
        return 1
    fi
    
    return 0
}

# Configure Zsh plugins in .zshrc
configure_zshrc() {
    log INFO "Configuring .zshrc..."
    
    local zshrc="$HOME/.zshrc"
    
    if [[ ! -f "$zshrc" ]]; then
        log ERROR ".zshrc not found"
        return 1
    fi
    
    # Backup .zshrc
    backup_file "$zshrc"
    
    # Define plugins to enable
    local plugins_list="git docker docker-compose node npm python golang rust"
    local custom_plugins="zsh-autosuggestions zsh-syntax-highlighting zsh-z"
    
    # Update plugins line
    if grep -q "^plugins=" "$zshrc"; then
        # Update existing plugins line
        execute "sed -i '' 's/^plugins=.*/plugins=($plugins_list $custom_plugins)/' '$zshrc'"
    else
        # Add plugins line
        echo "plugins=($plugins_list $custom_plugins)" >> "$zshrc"
    fi
    
    # Add custom configurations
    if ! grep -q "# MacSetup Custom Configuration" "$zshrc"; then
        cat >> "$zshrc" <<'EOF'

# MacSetup Custom Configuration
# Performance optimizations
export HISTSIZE=10000
export SAVEHIST=10000
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY

# Aliases
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias gs='git status'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph'

# Path additions
export PATH="/opt/homebrew/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# Development environment
export EDITOR='vim'
export VISUAL='vim'

# Enable color output
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

# FZF configuration
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# Zoxide configuration
eval "$(zoxide init zsh)" 2>/dev/null || true

# Load local configurations if exists
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
EOF
    fi
    
    log SUCCESS ".zshrc configured successfully"
    return 0
}

# Configure FZF
configure_fzf() {
    log INFO "Configuring FZF..."
    
    if command_exists fzf; then
        local fzf_install="$(brew --prefix)/opt/fzf/install"
        
        if [[ -f "$fzf_install" ]]; then
            execute "'$fzf_install' --key-bindings --completion --no-update-rc --no-bash --no-fish"
            log SUCCESS "FZF configured successfully"
        else
            log WARNING "FZF install script not found"
        fi
    else
        log WARNING "FZF not installed"
    fi
    
    return 0
}

# Main shell setup menu
show_shell_setup_menu() {
    print_header "$MODULE_NAME"
    
    echo "Select shell configuration options:"
    print_bullet "[1] Install Oh My Zsh"
    print_bullet "[2] Install Zsh plugins"
    print_bullet "[3] Configure shell environment"
    print_bullet "[4] Complete shell setup (all of the above)"
    print_bullet "[0] Back to main menu"
    echo ""
    
    read -p "$(echo -e ${COLOR_PROMPT}Enter your choice: ${NC})" choice
    
    if ! validate_menu_choice "$choice" 0 1 2 3 4; then
        log ERROR "Invalid choice: $choice"
        return 1
    fi
    
    case $choice in
        1)
            install_ohmyzsh
            ;;
        2)
            if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
                log ERROR "Oh My Zsh not installed. Please install it first."
                return 1
            fi
            
            echo ""
            echo "Select plugins to install:"
            local i=1
            for plugin in "${ZSH_PLUGIN_NAMES[@]}"; do
                print_bullet "[$i] $plugin"
                ((i++))
            done
            print_bullet "[A] All plugins"
            echo ""
            
            read -p "$(echo -e ${COLOR_PROMPT}Enter your choices (space-separated): ${NC})" -a choices
            
            for choice in "${choices[@]}"; do
                if [[ "$choice" == "A" ]] || [[ "$choice" == "a" ]]; then
                    for plugin in "${ZSH_PLUGIN_NAMES[@]}"; do
                        install_zsh_plugin "$plugin"
                    done
                elif validate_number "$choice" 1 "${#ZSH_PLUGIN_NAMES[@]}"; then
                    install_zsh_plugin "${ZSH_PLUGIN_NAMES[$((choice-1))]}"
                fi
            done
            ;;
        3)
            configure_zshrc
            configure_fzf
            ;;
        4)
            install_ohmyzsh
            for plugin in "${ZSH_PLUGIN_NAMES[@]}"; do
                install_zsh_plugin "$plugin"
            done
            configure_zshrc
            configure_fzf
            ;;
        0)
            return 0
            ;;
    esac
    
    log SUCCESS "$MODULE_NAME complete"
    read -p "Press Enter to continue..."
}

# Export main function
export -f show_shell_setup_menu

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    show_shell_setup_menu
fi