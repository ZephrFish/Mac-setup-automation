#!/bin/bash

# System Configuration Script for Mac
# Performance and storage optimization

echo "Configuring macOS system settings..."

# Configure Touch ID for sudo
if [ -f ./configure-touchid-sudo.sh ]; then
    ./configure-touchid-sudo.sh
fi

# Performance optimizations for M4 Max
echo "Optimizing performance settings..."

# Disable animations for faster UI
defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false
defaults write com.apple.dock expose-animation-duration -float 0.1
defaults write com.apple.dock autohide-time-modifier -float 0.5

# Optimize SSD usage
echo "Optimizing SSD settings..."
# Disable hibernation (saves 16-32GB of space)
sudo pmset -a hibernatemode 0
sudo rm -f /var/vm/sleepimage 2>/dev/null || true
sudo mkdir /var/vm/sleepimage 2>/dev/null || true

# Note: vm.swappiness is Linux-specific, not available on macOS
# macOS manages swap automatically based on memory pressure

# Disable local Time Machine snapshots
sudo tmutil disablelocal 2>/dev/null || true

# Storage optimization
echo "Setting up storage optimization..."

# Configure Spotlight to exclude development and cache directories
# Note: mdutil doesn't support direct path exclusion, use Spotlight preferences instead
defaults write com.apple.spotlight exclusions -array-add "$HOME/Media/cache" "$HOME/Development" "$HOME/.cache" "$HOME/.npm" "$HOME/.cargo"

# Finder optimizations
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Developer settings
echo "Enabling developer settings..."
defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.DiskUtility DUDebugMenuEnabled -bool true
defaults write com.apple.DiskUtility advanced-image-options -bool true

# Xcode command line tools
xcode-select --install 2>/dev/null || true

# Memory management for heavy workloads
echo "Configuring memory management..."
# Increase file descriptor limits for development
sudo launchctl limit maxfiles 65536 200000
ulimit -n 65536

# Network optimizations for development
sudo sysctl -w net.inet.tcp.msl=1000
sudo sysctl -w net.inet.tcp.win_scale_factor=8

echo "Setting up monitoring..."
# Create launchd plist for storage monitoring
cat > ~/Library/LaunchAgents/com.user.storage-monitor.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.storage-monitor</string>
    <key>ProgramArguments</key>
    <array>
        <string>/Users/zephr/Tools/storage-monitor.sh</string>
    </array>
    <key>StartInterval</key>
    <integer>86400</integer>
</dict>
</plist>
EOF

echo "System configuration complete!"
echo "Please restart your Mac to apply all changes."
echo ""
echo "Post-restart tasks:"
echo "  1. Sign into App Store and install Xcode if needed"
echo "  2. Configure Docker/OrbStack memory limits (suggest 16-24GB max)"
echo "  3. Set up your development environments"