#!/bin/bash

# Mac Setup Mega Script - All-in-One Configuration Tool
# For Development & Media Workstation
# Version 2.0

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Global variables
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
LOG_FILE="$HOME/mac-setup-$(date +%Y%m%d-%H%M%S).log"
INSTALLED_PACKAGES=""

# Logging function
log() {
    echo -e "$1" | tee -a "$LOG_FILE"
}

# Print header
print_header() {
    clear
    echo -e "${CYAN}================================================================${NC}"
    echo -e "${CYAN}         ${BOLD}Mac Setup Mega Script${NC}"
    echo -e "${CYAN}         Development & Media Workstation Configuration${NC}"
    echo -e "${CYAN}================================================================${NC}"
    echo ""
}

# Check prerequisites
check_prerequisites() {
    log "${YELLOW}Checking prerequisites...${NC}"
    
    # Check if running on macOS
    if [[ "$OSTYPE" != "darwin"* ]]; then
        log "${RED}Error: This script is only for macOS${NC}"
        exit 1
    fi
    
    # Check if running with proper permissions
    if ! sudo -n true 2>/dev/null; then
        log "${YELLOW}This script requires sudo access. Please enter your password:${NC}"
        sudo -v
    fi
    
    # Keep sudo alive
    while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
    
    log "${GREEN}[OK] Prerequisites check passed${NC}"
}

# Install Homebrew
install_homebrew() {
    if ! command -v brew &> /dev/null; then
        log "${YELLOW}Installing Homebrew...${NC}"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH for Apple Silicon
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
        log "${GREEN}[OK] Homebrew installed${NC}"
    else
        log "${GREEN}[OK] Homebrew already installed${NC}"
        brew update
    fi
}

# Development Tools Module
install_dev_tools() {
    print_header
    log "${BOLD}${BLUE}Development Tools Installation${NC}"
    echo ""
    
    local tools=(
        "1:Core Development:git gh node python@3.12 go rust"
        "2:Containers:docker docker-compose"
        "3:Virtualization:orbstack"
        "4:Databases:postgresql@16 redis mongodb-community mysql"
        "5:Cloud CLIs:awscli azure-cli"
        "6:Infrastructure:terraform kubectl helm"
        "7:All of the above:ALL"
    )
    
    echo "Select development tools to install:"
    for tool in "${tools[@]}"; do
        IFS=':' read -r num name packages <<< "$tool"
        echo "  [$num] $name"
    done
    echo "  [0] Back to main menu"
    echo ""
    read -p "Enter your choice (multiple choices separated by space): " -a choices
    
    for choice in "${choices[@]}"; do
        case $choice in
            1) brew install git gh node python@3.12 go rust ;;
            2) brew install docker docker-compose ;;
            3) brew install --cask orbstack ;;
            4) brew install postgresql@16 redis mongodb-community mysql ;;
            5) brew install awscli azure-cli ;;
            6) brew install terraform kubectl helm ;;
            7) 
                brew install git gh node python@3.12 go rust docker docker-compose
                brew install --cask orbstack
                brew install postgresql@16 redis mongodb-community mysql
                brew install awscli azure-cli terraform kubectl helm
                ;;
            0) return ;;
        esac
    done
    
    log "${GREEN}[OK] Development tools installation complete${NC}"
    read -p "Press Enter to continue..."
}

# CLI Tools Module
install_cli_tools() {
    print_header
    log "${BOLD}${BLUE}CLI Productivity Tools Installation${NC}"
    echo ""
    
    local categories=(
        "1:Essential Tools:fzf ripgrep bat eza tldr htop ncdu tree jq yq wget curl fd"
        "2:Terminal Enhancement:tmux neovim lazygit lazydocker zoxide"
        "3:Development Utilities:httpie gh direnv entr watch tokei hyperfine"
        "4:All CLI tools:ALL"
    )
    
    echo "Select CLI tool categories to install:"
    for category in "${categories[@]}"; do
        IFS=':' read -r num name packages <<< "$category"
        echo "  [$num] $name"
    done
    echo "  [0] Back to main menu"
    echo ""
    read -p "Enter your choice (multiple choices separated by space): " -a choices
    
    for choice in "${choices[@]}"; do
        case $choice in
            1) brew install fzf ripgrep bat eza tldr htop ncdu tree jq yq wget curl fd ;;
            2) brew install tmux neovim lazygit lazydocker zoxide ;;
            3) brew install httpie gh direnv entr watch tokei hyperfine ;;
            4) 
                brew install fzf ripgrep bat eza tldr htop ncdu tree jq yq wget curl fd
                brew install tmux neovim lazygit lazydocker zoxide
                brew install httpie gh direnv entr watch tokei hyperfine
                ;;
            0) return ;;
        esac
    done
    
    # Configure fzf if installed
    if command -v fzf &> /dev/null; then
        log "${YELLOW}Configuring fzf...${NC}"
        $(brew --prefix)/opt/fzf/install --key-bindings --completion --no-update-rc --no-bash --no-fish 2>/dev/null || true
    fi
    
    log "${GREEN}[OK] CLI tools installation complete${NC}"
    read -p "Press Enter to continue..."
}

# Media Tools Module
install_media_tools() {
    print_header
    log "${BOLD}${BLUE}Media Tools Installation${NC}"
    echo ""
    
    echo "Select media tools to install:"
    echo "  [1] FFmpeg & ImageMagick (CLI tools)"
    echo "  [2] HandBrake (Video transcoding)"
    echo "  [3] VLC (Media player)"
    echo "  [4] DaVinci Resolve (Video editing)"
    echo "  [5] All media tools"
    echo "  [0] Back to main menu"
    echo ""
    read -p "Enter your choice (multiple choices separated by space): " -a choices
    
    for choice in "${choices[@]}"; do
        case $choice in
            1) brew install ffmpeg imagemagick ;;
            2) brew install --cask handbrake ;;
            3) brew install --cask vlc ;;
            4) brew install --cask davinci-resolve ;;
            5) 
                brew install ffmpeg imagemagick
                brew install --cask handbrake vlc davinci-resolve
                ;;
            0) return ;;
        esac
    done
    
    log "${GREEN}[OK] Media tools installation complete${NC}"
    read -p "Press Enter to continue..."
}

# System Configuration Module
configure_system() {
    print_header
    log "${BOLD}${BLUE}System Configuration${NC}"
    echo ""
    
    echo "Select system configurations to apply:"
    echo "  [1] Performance optimizations (animations, UI speed)"
    echo "  [2] SSD optimizations (hibernation, swap)"
    echo "  [3] Developer settings (show hidden files, extensions)"
    echo "  [4] Finder enhancements"
    echo "  [5] Network optimizations"
    echo "  [6] File descriptor limits"
    echo "  [7] All system configurations"
    echo "  [0] Back to main menu"
    echo ""
    read -p "Enter your choice (multiple choices separated by space): " -a choices
    
    for choice in "${choices[@]}"; do
        case $choice in
            1)
                log "${YELLOW}Applying performance optimizations...${NC}"
                defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false
                defaults write com.apple.dock expose-animation-duration -float 0.1
                defaults write com.apple.dock autohide-time-modifier -float 0.5
                defaults write com.apple.dock autohide-delay -float 0
                ;;
            2)
                log "${YELLOW}Applying SSD optimizations...${NC}"
                sudo pmset -a hibernatemode 0
                sudo rm -f /var/vm/sleepimage 2>/dev/null || true
                sudo tmutil disablelocal 2>/dev/null || true
                ;;
            3)
                log "${YELLOW}Enabling developer settings...${NC}"
                defaults write com.apple.finder AppleShowAllFiles -bool true
                defaults write NSGlobalDomain AppleShowAllExtensions -bool true
                defaults write com.apple.DiskUtility DUDebugMenuEnabled -bool true
                defaults write com.apple.DiskUtility advanced-image-options -bool true
                ;;
            4)
                log "${YELLOW}Configuring Finder...${NC}"
                defaults write com.apple.finder ShowPathbar -bool true
                defaults write com.apple.finder ShowStatusBar -bool true
                defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
                defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
                defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
                ;;
            5)
                log "${YELLOW}Applying network optimizations...${NC}"
                sudo sysctl -w net.inet.tcp.msl=1000
                sudo sysctl -w net.inet.tcp.win_scale_factor=8
                ;;
            6)
                log "${YELLOW}Increasing file descriptor limits...${NC}"
                sudo launchctl limit maxfiles 65536 200000
                ulimit -n 65536
                ;;
            7)
                # Apply all configurations
                for i in {1..6}; do
                    configure_system <<< "$i"
                done
                ;;
            0) return ;;
        esac
    done
    
    killall Finder 2>/dev/null || true
    log "${GREEN}[OK] System configuration complete${NC}"
    read -p "Press Enter to continue..."
}

# Touch ID for sudo Module
configure_touchid_sudo() {
    print_header
    log "${BOLD}${BLUE}Configure Touch ID for sudo${NC}"
    echo ""
    
    # Check if Mac has Touch ID
    if ! system_profiler SPHardwareDataType | grep -q "MacBook"; then
        if ! ioreg -c AppleEmbeddedOSSupportHost | grep -q "AppleEmbeddedOSSupportHost"; then
            log "${YELLOW}This Mac doesn't appear to have Touch ID. Skipping configuration.${NC}"
            read -p "Press Enter to continue..."
            return
        fi
    fi
    
    log "${YELLOW}Enabling Touch ID for sudo commands...${NC}"
    
    # Backup original configuration
    if [ ! -f /etc/pam.d/sudo_local.template.bak ]; then
        sudo cp /etc/pam.d/sudo_local.template /etc/pam.d/sudo_local.template.bak 2>/dev/null || true
    fi
    
    # Create sudo_local file
    sudo tee /etc/pam.d/sudo_local > /dev/null << 'EOF'
# sudo_local: local config file for sudo which survives macOS updates
# Enable Touch ID for sudo
auth       sufficient     pam_tid.so
EOF
    
    log "${GREEN}[OK] Touch ID for sudo has been configured${NC}"
    log "${CYAN}Note: Touch ID won't work in Terminal sessions over SSH/screen sharing${NC}"
    read -p "Press Enter to continue..."
}

# Oh My Zsh Module
setup_ohmyzsh() {
    print_header
    log "${BOLD}${BLUE}Oh My Zsh Setup${NC}"
    echo ""
    
    # Install Oh My Zsh if not already installed
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        log "${YELLOW}Installing Oh My Zsh...${NC}"
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
        log "${GREEN}[OK] Oh My Zsh already installed${NC}"
    fi
    
    ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}
    
    echo ""
    echo "Select Zsh plugins to install:"
    echo "  [1] zsh-autosuggestions (Fish-like autosuggestions)"
    echo "  [2] zsh-syntax-highlighting (Syntax highlighting)"
    echo "  [3] zsh-completions (Additional completions)"
    echo "  [4] zsh-history-substring-search (Better history search)"
    echo "  [5] zsh-z (Directory jumping)"
    echo "  [6] All plugins"
    echo "  [0] Back to main menu"
    echo ""
    read -p "Enter your choice (multiple choices separated by space): " -a choices
    
    for choice in "${choices[@]}"; do
        case $choice in
            1)
                if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
                    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
                fi
                ;;
            2)
                if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
                    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
                fi
                ;;
            3)
                if [ ! -d "$ZSH_CUSTOM/plugins/zsh-completions" ]; then
                    git clone https://github.com/zsh-users/zsh-completions "$ZSH_CUSTOM/plugins/zsh-completions"
                fi
                ;;
            4)
                if [ ! -d "$ZSH_CUSTOM/plugins/zsh-history-substring-search" ]; then
                    git clone https://github.com/zsh-users/zsh-history-substring-search "$ZSH_CUSTOM/plugins/zsh-history-substring-search"
                fi
                ;;
            5)
                if [ ! -d "$ZSH_CUSTOM/plugins/zsh-z" ]; then
                    git clone https://github.com/agkozak/zsh-z "$ZSH_CUSTOM/plugins/zsh-z"
                fi
                ;;
            6)
                # Install all plugins
                for i in {1..5}; do
                    setup_ohmyzsh <<< "$i"
                done
                ;;
            0) return ;;
        esac
    done
    
    # Update .zshrc with plugins
    if ! grep -q "plugins=(.*zsh-autosuggestions" ~/.zshrc; then
        log "${YELLOW}Updating .zshrc with plugins...${NC}"
        sed -i '' 's/plugins=(git)/plugins=(git docker docker-compose node npm python golang rust zsh-autosuggestions zsh-syntax-highlighting zsh-z)/' ~/.zshrc
    fi
    
    log "${GREEN}[OK] Oh My Zsh setup complete${NC}"
    read -p "Press Enter to continue..."
}

# 1Password Integration Module
setup_1password() {
    print_header
    log "${BOLD}${BLUE}1Password CLI Integration${NC}"
    echo ""
    
    # Check if 1Password CLI is installed
    if ! command -v op &> /dev/null; then
        log "${YELLOW}Installing 1Password CLI...${NC}"
        brew install --cask 1password 1password-cli
    else
        log "${GREEN}[OK] 1Password CLI already installed${NC}"
    fi
    
    echo ""
    echo "Select 1Password integrations to set up:"
    echo "  [1] SSH Agent integration"
    echo "  [2] Git credential helper"
    echo "  [3] Environment variable management"
    echo "  [4] AWS credential helper"
    echo "  [5] Database connection helper"
    echo "  [6] All integrations"
    echo "  [0] Back to main menu"
    echo ""
    read -p "Enter your choice (multiple choices separated by space): " -a choices
    
    # Create helpers directory
    mkdir -p ~/Tools/1password-helpers
    
    for choice in "${choices[@]}"; do
        case $choice in
            1)
                log "${YELLOW}Setting up SSH Agent integration...${NC}"
                cat > ~/Tools/1password-helpers/setup-ssh-agent.sh << 'EOF'
#!/bin/bash
echo "Setting up 1Password SSH agent..."
mkdir -p ~/.ssh
if ! grep -q "IdentityAgent" ~/.ssh/config 2>/dev/null; then
    cat >> ~/.ssh/config << 'SSH_CONFIG'
Host *
    IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
SSH_CONFIG
    echo "[OK] SSH config updated"
fi
echo "[OK] 1Password SSH agent configured"
EOF
                chmod +x ~/Tools/1password-helpers/setup-ssh-agent.sh
                ;;
            2)
                log "${YELLOW}Setting up Git credential helper...${NC}"
                git config --global credential.helper osxkeychain
                git config --global credential.helper '!op plugin run -- git credential-osxkeychain'
                ;;
            3)
                log "${YELLOW}Creating environment variable loader...${NC}"
                cat > ~/Tools/1password-helpers/load-env.sh << 'EOF'
#!/bin/bash
ENV_FILE="${1:-.env.op}"
if [ ! -f "$ENV_FILE" ]; then
    echo "Error: $ENV_FILE not found"
    return 1
fi
echo "Loading environment from $ENV_FILE with 1Password..."
if ! op account get &>/dev/null; then
    eval $(op signin)
fi
while IFS= read -r line; do
    if [[ ! "$line" =~ ^[[:space:]]*# && ! -z "$line" ]]; then
        processed_line=$(echo "$line" | op inject)
        export $processed_line
    fi
done < "$ENV_FILE"
echo "[OK] Environment loaded from $ENV_FILE"
EOF
                chmod +x ~/Tools/1password-helpers/load-env.sh
                ;;
            4)
                log "${YELLOW}Creating AWS credential helper...${NC}"
                cat > ~/Tools/1password-helpers/aws-1password.sh << 'EOF'
#!/bin/bash
PROFILE="${1:-default}"
echo "Loading AWS credentials for profile: $PROFILE"
if ! op account get &>/dev/null; then
    eval $(op signin)
fi
AWS_ACCESS_KEY_ID=$(op item get "AWS-$PROFILE" --fields access_key_id 2>/dev/null)
AWS_SECRET_ACCESS_KEY=$(op item get "AWS-$PROFILE" --fields secret_access_key 2>/dev/null)
if [ -z "$AWS_ACCESS_KEY_ID" ]; then
    echo "Error: Could not find AWS credentials for profile $PROFILE in 1Password"
    return 1
fi
export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY
echo "[OK] AWS credentials loaded for profile: $PROFILE"
EOF
                chmod +x ~/Tools/1password-helpers/aws-1password.sh
                ;;
            5)
                log "${YELLOW}Creating database connection helper...${NC}"
                cat > ~/Tools/1password-helpers/db-connect.sh << 'EOF'
#!/bin/bash
DB_NAME="$1"
if [ -z "$DB_NAME" ]; then
    echo "Usage: db-connect.sh <database-name>"
    exit 1
fi
echo "Connecting to database: $DB_NAME"
if ! op account get &>/dev/null; then
    eval $(op signin)
fi
DB_HOST=$(op item get "DB-$DB_NAME" --fields host 2>/dev/null)
DB_PORT=$(op item get "DB-$DB_NAME" --fields port 2>/dev/null)
DB_USER=$(op item get "DB-$DB_NAME" --fields username 2>/dev/null)
DB_PASS=$(op item get "DB-$DB_NAME" --fields password 2>/dev/null)
DB_DATABASE=$(op item get "DB-$DB_NAME" --fields database 2>/dev/null)
if [ -z "$DB_HOST" ]; then
    echo "Error: Could not find database $DB_NAME in 1Password"
    exit 1
fi
DB_TYPE=$(op item get "DB-$DB_NAME" --fields type 2>/dev/null || echo "postgres")
case "$DB_TYPE" in
    postgres|postgresql)
        PGPASSWORD="$DB_PASS" psql -h "$DB_HOST" -p "${DB_PORT:-5432}" -U "$DB_USER" -d "$DB_DATABASE"
        ;;
    mysql|mariadb)
        mysql -h "$DB_HOST" -P "${DB_PORT:-3306}" -u "$DB_USER" -p"$DB_PASS" "$DB_DATABASE"
        ;;
    mongodb)
        mongosh "mongodb://$DB_USER:$DB_PASS@$DB_HOST:${DB_PORT:-27017}/$DB_DATABASE"
        ;;
    *)
        echo "Unsupported database type: $DB_TYPE"
        exit 1
        ;;
esac
EOF
                chmod +x ~/Tools/1password-helpers/db-connect.sh
                ;;
            6)
                # Set up all integrations
                for i in {1..5}; do
                    setup_1password <<< "$i"
                done
                ;;
            0) return ;;
        esac
    done
    
    # Add aliases to zshrc
    if ! grep -q "1Password CLI Integration" ~/.zshrc; then
        cat >> ~/.zshrc << 'EOF'

# 1Password CLI Integration
export OP_BIOMETRIC_UNLOCK_ENABLED=true
alias ops='eval $(op signin)'
alias loadenv='source ~/Tools/1password-helpers/load-env.sh'
alias dbconnect='~/Tools/1password-helpers/db-connect.sh'
alias awsop='source ~/Tools/1password-helpers/aws-1password.sh'
EOF
    fi
    
    log "${GREEN}[OK] 1Password integration complete${NC}"
    read -p "Press Enter to continue..."
}

# Quick Setup Module
quick_setup() {
    print_header
    log "${BOLD}${BLUE}Quick Setup - Installing Everything${NC}"
    echo ""
    log "${YELLOW}This will install and configure all components. This may take a while...${NC}"
    echo ""
    read -p "Are you sure you want to continue? (y/N): " confirm
    
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        return
    fi
    
    # Install everything
    install_homebrew
    
    log "${YELLOW}Installing all development tools...${NC}"
    brew install git gh node python@3.12 go rust docker docker-compose
    brew install --cask orbstack
    brew install postgresql@16 redis mongodb-community mysql
    brew install awscli azure-cli terraform kubectl helm
    
    log "${YELLOW}Installing all CLI tools...${NC}"
    brew install fzf ripgrep bat eza tldr htop ncdu tree jq yq wget curl fd
    brew install tmux neovim lazygit lazydocker zoxide
    brew install httpie gh direnv entr watch tokei hyperfine
    
    log "${YELLOW}Installing media tools...${NC}"
    brew install ffmpeg imagemagick
    brew install --cask handbrake vlc
    
    log "${YELLOW}Configuring system...${NC}"
    configure_system <<< "7"
    
    log "${YELLOW}Setting up Touch ID for sudo...${NC}"
    configure_touchid_sudo
    
    log "${YELLOW}Setting up Oh My Zsh...${NC}"
    setup_ohmyzsh <<< "6"
    
    log "${YELLOW}Setting up 1Password integration...${NC}"
    setup_1password <<< "6"
    
    log "${GREEN}[COMPLETE] Quick setup complete!${NC}"
    log "${YELLOW}Please restart your Mac to apply all changes.${NC}"
    read -p "Press Enter to continue..."
}

# Check installation status
check_status() {
    print_header
    log "${BOLD}${BLUE}Installation Status${NC}"
    echo ""
    
    # Check Homebrew
    echo -n "Homebrew: "
    if command -v brew &> /dev/null; then
        echo -e "${GREEN}[OK] Installed${NC} ($(brew --version | head -1))"
    else
        echo -e "${RED}[X] Not installed${NC}"
    fi
    
    # Check key tools
    local tools=("git" "node" "python3" "go" "rustc" "docker" "op" "fzf" "tmux" "nvim")
    echo ""
    echo "Key Tools:"
    for tool in "${tools[@]}"; do
        echo -n "  $tool: "
        if command -v "$tool" &> /dev/null; then
            echo -e "${GREEN}[OK] Installed${NC}"
        else
            echo -e "${RED}[X] Not installed${NC}"
        fi
    done
    
    # Check Oh My Zsh
    echo ""
    echo -n "Oh My Zsh: "
    if [ -d "$HOME/.oh-my-zsh" ]; then
        echo -e "${GREEN}[OK] Installed${NC}"
    else
        echo -e "${RED}[X] Not installed${NC}"
    fi
    
    # Check Touch ID for sudo
    echo -n "Touch ID for sudo: "
    if [ -f "/etc/pam.d/sudo_local" ]; then
        echo -e "${GREEN}[OK] Configured${NC}"
    else
        echo -e "${YELLOW}[!] Not configured${NC}"
    fi
    
    echo ""
    echo -e "${CYAN}Log file: $LOG_FILE${NC}"
    echo ""
    read -p "Press Enter to continue..."
}

# Main menu
main_menu() {
    while true; do
        print_header
        echo "${BOLD}Main Menu${NC}"
        echo ""
        echo "  [1] Quick Setup (Install Everything)"
        echo "  [2] Install Homebrew"
        echo "  [3] Install Development Tools"
        echo "  [4] Install CLI Tools"
        echo "  [5] Install Media Tools"
        echo "  [6] Configure System Settings"
        echo "  [7] Configure Touch ID for sudo"
        echo "  [8] Setup Oh My Zsh"
        echo "  [9] Setup 1Password Integration"
        echo "  [S] Check Installation Status"
        echo "  [Q] Quit"
        echo ""
        read -p "Enter your choice: " choice
        
        case $choice in
            1) quick_setup ;;
            2) install_homebrew ;;
            3) install_dev_tools ;;
            4) install_cli_tools ;;
            5) install_media_tools ;;
            6) configure_system ;;
            7) configure_touchid_sudo ;;
            8) setup_ohmyzsh ;;
            9) setup_1password ;;
            [Ss]) check_status ;;
            [Qq])
                echo ""
                log "${GREEN}Setup complete! Log saved to: $LOG_FILE${NC}"
                log "${YELLOW}Remember to restart your Mac if you made system changes.${NC}"
                exit 0
                ;;
            *)
                log "${RED}Invalid choice. Please try again.${NC}"
                sleep 1
                ;;
        esac
    done
}

# Main execution
main() {
    print_header
    log "${CYAN}Starting Mac Setup Mega Script at $(date)${NC}"
    log "${CYAN}Log file: $LOG_FILE${NC}"
    echo ""
    
    check_prerequisites
    main_menu
}

# Run the script
main "$@"