#!/bin/bash

# Complete Zsh Setup Script
# Installs Oh My Zsh, plugins, theme, and configures .zshrc

set -e

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR/config"
ZSHRC_TEMPLATE="$CONFIG_DIR/.zshrc"

# Colours for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Colour

# Logging functions
log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    error "This script is designed for macOS"
fi

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    warning "Homebrew not installed. Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for this session
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
fi

log "Starting complete Zsh setup..."

# Step 1: Install Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    log "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
    success "Oh My Zsh installed"
else
    log "Oh My Zsh already installed"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# Step 2: Install Powerlevel10k theme
if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
    log "Installing Powerlevel10k theme..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
    success "Powerlevel10k installed"
else
    log "Powerlevel10k already installed"
fi

# Step 3: Install Zsh plugins
log "Installing Zsh plugins..."

plugins=(
    "zsh-autosuggestions https://github.com/zsh-users/zsh-autosuggestions"
    "zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting"
    "zsh-completions https://github.com/zsh-users/zsh-completions"
)

for plugin_info in "${plugins[@]}"; do
    plugin_name="${plugin_info%% *}"
    plugin_url="${plugin_info#* }"
    
    if [ ! -d "$ZSH_CUSTOM/plugins/$plugin_name" ]; then
        log "Installing $plugin_name..."
        git clone "$plugin_url" "$ZSH_CUSTOM/plugins/$plugin_name"
        success "$plugin_name installed"
    else
        log "$plugin_name already installed"
    fi
done

# Step 4: Install modern CLI tools
log "Installing modern CLI tools..."

cli_tools=(
    "eza"        # Modern ls
    "bat"        # Better cat
    "fd"         # Better find
    "ripgrep"    # Better grep
    "fzf"        # Fuzzy finder
    "neovim"     # Modern vim
    "lazygit"    # Git UI
    "lazydocker" # Docker UI
    "tmux"       # Terminal multiplexer
    "htop"       # Process viewer
    "ncdu"       # Disk usage
    "tldr"       # Simplified man pages
    "jq"         # JSON processor
    "yq"         # YAML processor
    "httpie"     # Better curl
    "gh"         # GitHub CLI
)

for tool in "${cli_tools[@]}"; do
    if command -v "$tool" &> /dev/null; then
        log "$tool already installed"
    else
        log "Installing $tool..."
        if brew install "$tool" 2>/dev/null; then
            success "$tool installed"
        else
            warning "Failed to install $tool"
        fi
    fi
done

# Configure FZF
if command -v fzf &> /dev/null; then
    log "Configuring FZF..."
    if [[ -f "$(brew --prefix)/opt/fzf/install" ]]; then
        "$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc --no-bash --no-fish 2>/dev/null || true
        success "FZF configured"
    fi
fi

# Step 5: Configure .zshrc
log "Configuring .zshrc..."

# Backup existing .zshrc if it exists
if [[ -f "$HOME/.zshrc" ]]; then
    backup_file="$HOME/.zshrc.backup.$(date +%Y%m%d-%H%M%S)"
    log "Backing up existing .zshrc to $backup_file"
    cp "$HOME/.zshrc" "$backup_file"
fi

# Copy our template .zshrc
if [[ -f "$ZSHRC_TEMPLATE" ]]; then
    cp "$ZSHRC_TEMPLATE" "$HOME/.zshrc"
    success ".zshrc configured with MacSetup template"
else
    warning "Template .zshrc not found, using default configuration"
fi

# Create .zshrc.local for personal customisation
if [[ ! -f "$HOME/.zshrc.local" ]]; then
    cat > "$HOME/.zshrc.local" << 'EOF'
# Personal Zsh Configuration
# Add your personal settings here

# Personal aliases
# alias myproject='cd ~/projects/myproject'

# Personal environment variables
# export MY_API_KEY="your-key-here"

# Personal functions
# function myfunction() {
#     echo "Hello from my function"
# }
EOF
    log "Created .zshrc.local for personal configuration"
fi

# Step 6: Final setup
success "Zsh setup complete!"

echo ""
echo "Next steps:"
echo "1. Restart your terminal or run: source ~/.zshrc"
echo "2. Configure Powerlevel10k by running: p10k configure"
echo "3. Add personal configuration to ~/.zshrc.local"
echo ""
echo "Installed tools shortcuts:"
echo "  - ll/la: List files with icons (eza)"
echo "  - cat: View files with syntax highlighting (bat)"
echo "  - find: Fast file search (fd)"
echo "  - grep: Fast text search (ripgrep)"
echo "  - Ctrl+R: Fuzzy history search (fzf)"
echo "  - lg: LazyGit UI"
echo "  - ld: LazyDocker UI"
echo ""
echo "Zsh plugin features:"
echo "  - Tab completion suggestions (zsh-autosuggestions)"
echo "  - Syntax highlighting as you type (zsh-syntax-highlighting)"
echo "  - Better tab completions (zsh-completions)"