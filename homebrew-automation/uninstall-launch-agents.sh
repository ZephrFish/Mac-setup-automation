#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"

echo -e "${YELLOW}Homebrew Automation Launch Agents Uninstallation${NC}"
echo "=================================================="

# Function to uninstall a launch agent
uninstall_launch_agent() {
    local plist_name=$1
    local plist_file="$LAUNCH_AGENTS_DIR/$plist_name"
    
    echo -e "\n${YELLOW}Uninstalling $plist_name...${NC}"
    
    if [ -f "$plist_file" ]; then
        # Unload the agent
        echo "  Unloading agent..."
        launchctl unload "$plist_file" 2>/dev/null
        
        # Remove the plist file
        echo "  Removing plist file..."
        rm "$plist_file"
        
        echo -e "  ${GREEN}✓ Successfully uninstalled${NC}"
    else
        echo -e "  ${YELLOW}Agent not found, skipping${NC}"
    fi
}

# Uninstall both launch agents
uninstall_launch_agent "com.user.brew-update.plist"
uninstall_launch_agent "com.user.brew-log-cleanup.plist"

echo -e "\n${GREEN}Uninstallation complete!${NC}"
echo "Launch agents have been removed from: $LAUNCH_AGENTS_DIR"