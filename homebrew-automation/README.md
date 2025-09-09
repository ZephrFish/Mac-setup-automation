# Homebrew Automation Tools

Automated maintenance scripts for Homebrew on macOS.

## Overview

This repository contains automation scripts to keep Homebrew updated and maintained on a regular schedule using macOS's built-in launchd service.

## Features

- **Weekly Updates**: Automatic Homebrew updates every Monday at 10:00 AM
- **Package Upgrades**: Upgrades outdated packages automatically
- **Log Management**: Automatic cleanup of old log files to prevent disk space issues
- **Health Checks**: Runs `brew doctor` to identify potential issues
- **Error Handling**: Comprehensive logging with error tracking

## Scripts

### brew-update.sh
Main update script that:
- Updates Homebrew formulae
- Upgrades outdated packages
- Cleans up old versions
- Runs diagnostic checks
- Manages log rotation

### brew-log-cleanup.sh
Monthly cleanup script that:
- Removes logs older than specified thresholds
- Truncates oversized log files
- Maintains a clean log directory

## Installation

The scripts are automatically scheduled via LaunchAgents located in:
- `~/Library/LaunchAgents/com.user.brew-update.plist`
- `~/Library/LaunchAgents/com.user.brew-log-cleanup.plist`

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

- **Weekly Update**: Every Monday at 10:00 AM
- **Monthly Cleanup**: 1st of each month at 10:30 AM

## Requirements

- macOS
- Homebrew installed
- User permissions for LaunchAgent execution