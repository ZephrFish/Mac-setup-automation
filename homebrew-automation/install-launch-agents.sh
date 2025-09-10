#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"
HOME_DIR="$HOME"

echo -e "${GREEN}Homebrew Automation Launch Agents Installation${NC}"
echo "================================================"

# Create LaunchAgents directory if it doesn't exist
if [ ! -d "$LAUNCH_AGENTS_DIR" ]; then
    echo -e "${YELLOW}Creating LaunchAgents directory...${NC}"
    mkdir -p "$LAUNCH_AGENTS_DIR"
fi

# Function to install a launch agent
install_launch_agent() {
    local plist_name=$1
    local source_file="$SCRIPT_DIR/LaunchAgents/$plist_name"
    local dest_file="$LAUNCH_AGENTS_DIR/$plist_name"
    
    echo -e "\n${GREEN}Installing $plist_name...${NC}"
    
    # Check if source file exists
    if [ ! -f "$source_file" ]; then
        echo -e "${RED}Error: Source file not found: $source_file${NC}"
        return 1
    fi
    
    # Unload existing agent if it exists
    if [ -f "$dest_file" ]; then
        echo "  Unloading existing agent..."
        launchctl unload "$dest_file" 2>/dev/null
    fi
    
    # Copy and customize the plist file
    echo "  Customizing and installing plist..."
    sed -e "s|HOMEBREW_SCRIPTS_DIR|$SCRIPT_DIR|g" \
        -e "s|USER_HOME_DIR|$HOME_DIR|g" \
        "$source_file" > "$dest_file"
    
    # Set correct permissions
    chmod 644 "$dest_file"
    
    # Load the new agent
    echo "  Loading agent..."
    launchctl load "$dest_file"
    
    if [ $? -eq 0 ]; then
        echo -e "  ${GREEN}✓ Successfully installed and loaded${NC}"
    else
        echo -e "  ${RED}✗ Failed to load agent${NC}"
        return 1
    fi
}

# Install both launch agents
install_launch_agent "com.user.brew-update.plist"
install_launch_agent "com.user.brew-log-cleanup.plist"

echo -e "\n${GREEN}Installation Summary:${NC}"
echo "====================="
echo "Launch agents installed to: $LAUNCH_AGENTS_DIR"
echo "Scripts location: $SCRIPT_DIR"
echo ""
echo "Schedule:"
echo "  • brew-update: Daily at 9:00 AM"
echo "  • brew-log-cleanup: Weekly on Sunday at 2:00 AM"
echo ""
echo "To check status:"
echo "  launchctl list | grep com.user.brew"
echo ""
echo "To manually run:"
echo "  launchctl start com.user.brew-update"
echo "  launchctl start com.user.brew-log-cleanup"
echo ""
echo "To uninstall:"
echo "  Run: $SCRIPT_DIR/uninstall-launch-agents.sh"