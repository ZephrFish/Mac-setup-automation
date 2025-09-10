#!/bin/bash

# Install Oh My Zsh with full configuration

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Setting up Oh My Zsh with configuration..."

# Install Oh My Zsh if not already installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
fi

# Install zsh plugins
echo "Installing zsh plugins..."

ZSH_CUSTOM="${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"

# Zsh autosuggestions
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

# Zsh syntax highlighting
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# Zsh completions
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-completions" ]; then
    git clone https://github.com/zsh-users/zsh-completions "$ZSH_CUSTOM/plugins/zsh-completions"
fi

# Install Powerlevel10k theme
if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
    echo "Installing Powerlevel10k theme..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
fi

# Now run the zshrc setup module
if [ -f "$SCRIPT_DIR/modules/zshrc-setup.sh" ]; then
    echo "Configuring .zshrc..."
    source "$SCRIPT_DIR/modules/zshrc-setup.sh"
    setup_zshrc
else
    echo "Warning: zshrc-setup.sh module not found"
    # Fallback to basic configuration
    if [ -f "$SCRIPT_DIR/config/.zshrc" ] && [ ! -f "$HOME/.zshrc" ]; then
        cp "$SCRIPT_DIR/config/.zshrc" "$HOME/.zshrc"
    fi
fi

echo "Oh My Zsh setup complete! Please run: source ~/.zshrc"