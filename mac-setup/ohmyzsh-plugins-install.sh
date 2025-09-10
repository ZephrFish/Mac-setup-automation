#!/bin/bash

# Oh My Zsh External Plugins Installation Script
# This script installs essential external plugins and tools for enhanced Zsh experience

echo " Installing Oh My Zsh external plugins and tools..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Oh My Zsh is installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo -e "${RED}Oh My Zsh is not installed. Please install it first:${NC}"
    echo 'sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'
    exit 1
fi

ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}

echo -e "\n${YELLOW}Installing external Zsh plugins...${NC}"

# Install zsh-autosuggestions
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    echo "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
else
    echo -e "${GREEN}✓${NC} zsh-autosuggestions already installed"
fi

# Install zsh-syntax-highlighting
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    echo "Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
else
    echo -e "${GREEN}✓${NC} zsh-syntax-highlighting already installed"
fi

# Install zsh-completions
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-completions" ]; then
    echo "Installing zsh-completions..."
    git clone https://github.com/zsh-users/zsh-completions "$ZSH_CUSTOM/plugins/zsh-completions"
else
    echo -e "${GREEN}✓${NC} zsh-completions already installed"
fi

# Install zsh-history-substring-search
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-history-substring-search" ]; then
    echo "Installing zsh-history-substring-search..."
    git clone https://github.com/zsh-users/zsh-history-substring-search "$ZSH_CUSTOM/plugins/zsh-history-substring-search"
else
    echo -e "${GREEN}✓${NC} zsh-history-substring-search already installed"
fi

echo -e "\n${YELLOW}Installing Homebrew packages...${NC}"

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo -e "${RED}Homebrew is not installed. Installing...${NC}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Essential tools
brew_packages=(
    "fzf"           # Fuzzy finder
    "fd"            # Better find
    "ripgrep"       # Better grep
    "bat"           # Better cat
    "eza"           # Better ls (formerly exa)
    "zoxide"        # Better cd
    "htop"          # Better top
    "ncdu"          # Disk usage analyzer
    "tldr"          # Simplified man pages
    "jq"            # JSON processor
    "yq"            # YAML processor
    "httpie"        # Better curl
    "gh"            # GitHub CLI
    "tree"          # Directory tree
    "watch"         # Execute command periodically
    "wget"          # Download files
    "tmux"          # Terminal multiplexer
)

echo "Installing Homebrew packages..."
for package in "${brew_packages[@]}"; do
    if brew list --formula | grep -q "^${package}\$"; then
        echo -e "${GREEN}✓${NC} $package already installed"
    else
        echo "Installing $package..."
        brew install "$package"
    fi
done

# Optional: Development tools (uncomment if needed)
# dev_packages=(
#     "node"
#     "python@3.11"
#     "go"
#     "rust"
#     "docker"
#     "kubectl"
#     "terraform"
#     "awscli"
#     "azure-cli"
#     "gcloud"
# )

# for package in "${dev_packages[@]}"; do
#     if brew list --formula | grep -q "^${package}\$"; then
#         echo -e "${GREEN}✓${NC} $package already installed"
#     else
#         echo "Installing $package..."
#         brew install "$package"
#     fi
# done

echo -e "\n${YELLOW}Configuring installed tools...${NC}"

# Install fzf key bindings and fuzzy completion
if command -v fzf &> /dev/null; then
    echo "Setting up fzf..."
    $(brew --prefix)/opt/fzf/install --key-bindings --completion --no-update-rc --no-bash --no-fish
    echo -e "${GREEN}✓${NC} fzf configured"
fi

# Initialize zoxide
if command -v zoxide &> /dev/null; then
    echo "Setting up zoxide..."
    echo 'eval "$(zoxide init zsh)"' >> ~/.zshrc.local
    echo -e "${GREEN}✓${NC} zoxide configured"
fi

echo -e "\n${GREEN} Installation complete!${NC}"
echo -e "\n${YELLOW}Next steps:${NC}"
echo "1. Restart your terminal or run: source ~/.zshrc"
echo "2. Configure Powerlevel10k if needed: p10k configure"
echo "3. Test new commands:"
echo "   - fzf: Ctrl+R for history search, Ctrl+T for file search"
echo "   - z [directory]: Jump to frequently used directories"
echo "   - bat [file]: View files with syntax highlighting"
echo "   - eza -la: Better ls with icons and git status"
echo "   - tldr [command]: Get quick command examples"
echo ""
echo "Plugin shortcuts:"
echo "   - ESC ESC: Add sudo to current command"
echo "   - Ctrl+O: Copy current command to clipboard"
echo "   - Ctrl+G: Toggle per-directory history"
echo "   - Up/Down arrows: Search history with current input"
echo "   - google/github/stackoverflow [query]: Web search from terminal"