#!/bin/bash

# Mac Setup Script for M4 Max Development & Media Workstation
# Optimized for 64GB RAM, 1TB SSD

set -e

# Development tools
brew install git gh node python@3.12 go rust docker docker-compose
brew install --cask docker orbstack  # OrbStack is more efficient than Docker Desktop

# Database tools
brew install postgresql@16 redis mongodb-community mysql

# CLI productivity tools
brew install fzf ripgrep bat eza tldr htop ncdu tree jq yq wget curl
brew install tmux neovim lazygit lazydocker

# Security tools
brew install --cask 1password 1password-cli

# Media tools (lighter alternatives where possible)
brew install ffmpeg imagemagick
brew install --cask handbrake vlc

# System monitoring
brew install --cask stats istat-menus

echo "Configuring Git..."
git config --global init.defaultBranch main
git config --global pull.rebase false

echo "Setting up Zsh with Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Install zsh plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions 2>/dev/null || true
git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting 2>/dev/null || true
git clone https://github.com/agkozak/zsh-z ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-z 2>/dev/null || true

echo "Basic setup complete!"
echo "Please run the system configuration script next: ./configure-system.sh"