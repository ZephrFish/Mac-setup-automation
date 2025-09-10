#!/bin/bash

# Configure Touch ID for sudo authentication on macOS
# This script safely enables Touch ID for sudo commands

echo "Configuring Touch ID for sudo authentication..."

# Check if we're on a Mac with Touch ID support (MacBook Pro/Air with Apple Silicon)
if ! system_profiler SPHardwareDataType | grep -q "MacBook"; then
    if ! ioreg -c AppleEmbeddedOSSupportHost | grep -q "AppleEmbeddedOSSupportHost"; then
        echo "This Mac doesn't appear to have Touch ID. Skipping configuration."
        exit 0
    fi
fi

# Backup the original sudo configuration
if [ ! -f /etc/pam.d/sudo_local.template.bak ]; then
    echo "Backing up original sudo configuration..."
    sudo cp /etc/pam.d/sudo_local.template /etc/pam.d/sudo_local.template.bak 2>/dev/null || true
fi

# Create or update sudo_local file (persists through OS updates)
echo "Updating sudo authentication configuration..."

# Create the sudo_local file with Touch ID support
sudo tee /etc/pam.d/sudo_local > /dev/null << 'EOF'
# sudo_local: local config file for sudo which survives macOS updates
# Enable Touch ID for sudo
auth       sufficient     pam_tid.so
EOF

echo "Touch ID for sudo has been configured!"
echo ""
echo "Notes:"
echo "  - Touch ID will now work for sudo commands"
echo "  - This configuration persists through macOS updates"
echo "  - You can still use your password if Touch ID fails"
echo "  - Touch ID won't work in Terminal sessions over SSH/screen sharing"
echo ""
echo "Testing configuration..."
echo "Try running: sudo echo 'Touch ID test successful!'"