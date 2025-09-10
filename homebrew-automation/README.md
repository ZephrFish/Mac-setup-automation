# Homebrew Automation Tools

Scripts for automated Homebrew maintenance on macOS.

## Overview

A collection of scripts that automatically update and maintain Homebrew using macOS launchd.

## Features

- Daily updates at 09:00
- Automatic package upgrades for outdated formulae
- Weekly log cleanup to prevent storage issues
- Health checks via brew doctor
- Detailed logging with error tracking

## Scripts

### brew-update.sh
Main update script:
- Updates Homebrew formulae
- Upgrades outdated packages
- Removes old versions
- Runs diagnostic checks
- Rotates logs

### brew-log-cleanup.sh
Weekly cleanup script:
- Removes old logs based on age thresholds
- Truncates large log files
- Keeps log directory organised

## Installation

### Quick Installation

1. Clone this repository or download the scripts
2. Navigate to the homebrew-automation directory
3. Run the installation script:

```bash
cd homebrew-automation
./install-launch-agents.sh
```

This will:
- Copy and configure the Launch Agent plist files to `~/Library/LaunchAgents/`
- Set up the correct paths for your system
- Load the agents to start automatic scheduling

### Manual Installation

If you prefer to install manually:

1. Copy the plist files from `LaunchAgents/` to `~/Library/LaunchAgents/`:
   ```bash
   cp LaunchAgents/com.user.brew-update.plist ~/Library/LaunchAgents/
   cp LaunchAgents/com.user.brew-log-cleanup.plist ~/Library/LaunchAgents/
   ```

2. Edit each plist file to replace placeholders:
   - Replace `HOMEBREW_SCRIPTS_DIR` with the full path to your scripts directory
   - Replace `USER_HOME_DIR` with your home directory path

3. Load the agents:
   ```bash
   launchctl load ~/Library/LaunchAgents/com.user.brew-update.plist
   launchctl load ~/Library/LaunchAgents/com.user.brew-log-cleanup.plist
   ```

## Uninstallation

To remove the automation:

```bash
./uninstall-launch-agents.sh
```

Or manually:
```bash
launchctl unload ~/Library/LaunchAgents/com.user.brew-update.plist
launchctl unload ~/Library/LaunchAgents/com.user.brew-log-cleanup.plist
rm ~/Library/LaunchAgents/com.user.brew-update.plist
rm ~/Library/LaunchAgents/com.user.brew-log-cleanup.plist
```

## Logs

All logs are stored in: `~/Library/Logs/Homebrew/`

- Weekly update logs: `weekly-update-YYYYMMDD-HHMMSS.log`
- Cleanup logs: `cleanup-YYYYMMDD.log`
- LaunchAgent output: `launchd-stdout.log` and `launchd-stderr.log`

## Manual Execution

To run the scripts manually:

```bash
# Run update script
~/tools/homebrew-automation/brew-update.sh

# Run cleanup script
~/tools/homebrew-automation/brew-log-cleanup.sh
```

## Managing the Service

```bash
# Check status
launchctl list | grep brew

# Disable temporarily
launchctl unload ~/Library/LaunchAgents/com.user.brew-update.plist
launchctl unload ~/Library/LaunchAgents/com.user.brew-log-cleanup.plist

# Re-enable
launchctl load ~/Library/LaunchAgents/com.user.brew-update.plist
launchctl load ~/Library/LaunchAgents/com.user.brew-log-cleanup.plist
```

## Schedule

- Daily Update: Every day at 09:00
- Weekly Cleanup: Every Sunday at 02:00

## Requirements

- macOS
- Homebrew installed
- User permissions for LaunchAgent execution