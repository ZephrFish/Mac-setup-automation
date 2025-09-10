# Mac Setup Automation

Comprehensive automation scripts for macOS setup, configuration, and maintenance.

## Contents

### homebrew-automation/
Automated Homebrew maintenance with scheduled updates and cleanup via launchd.

**Scripts:**
- `brew-update.sh` - Daily Homebrew updates, upgrades, and health checks
- `brew-log-cleanup.sh` - Weekly log cleanup to prevent storage issues
- `install-launch-agents.sh` - Automated installation of launchd agents
- `uninstall-launch-agents.sh` - Clean removal of automation

**Features:**
- Daily automatic updates at 09:00
- Weekly log cleanup on Sundays at 02:00
- Automatic package upgrades for outdated formulae
- Health monitoring via brew doctor
- Detailed logging with rotation

### mac-setup/
Complete macOS development environment setup with modular architecture.

**Main Scripts:**
- `setup.sh` - Main setup script v3.0 with profiles and security features
- `setup-zsh-complete.sh` - Complete Zsh and terminal environment setup
- `macsetup.sh` - Legacy setup script v2.1 (maintained for compatibility)
- `mac-setup-mega.sh` - Comprehensive all-in-one setup script
- `setup-mac.sh` - Quick Mac configuration script
- `install-ohmyzsh.sh` - Oh My Zsh installation with configuration
- `ohmyzsh-plugins-install.sh` - External plugins for enhanced Zsh experience

**Directory Structure:**
- `config/` - Configuration files (Brewfile, packages.conf, checksums.conf)
- `lib/` - Shared libraries (common.sh, colours.sh, validators.sh)
- `modules/` - Modular components (dev-tools.sh, shell-setup.sh, system-config.sh, zshrc-setup.sh)
- `utilities/` - System configuration utilities
  - `configure-1password.sh` - 1Password CLI setup
  - `configure-system.sh` - System performance optimisation
  - `configure-touchid-sudo.sh` - Touch ID for sudo authentication

**Features:**
- Security-first approach with checksum verification
- Smart profiles (Developer, DevOps, Data Scientist, Designer, Media)
- Apple Silicon optimised
- 15+ programming languages and frameworks
- 30+ productivity CLI tools
- Complete shell customisation with Oh My Zsh

## Quick Start

### Homebrew Automation
```bash
cd homebrew-automation
./install-launch-agents.sh
```

### Mac Setup
```bash
cd mac-setup
# For complete Zsh setup
./setup-zsh-complete.sh

# Or for full system setup
./setup.sh quick --profile developer
```

## Requirements

- macOS 12.0 (Monterey) or later
- Administrator access
- Homebrew (will be installed if not present)

## Documentation

Detailed documentation for each component is available in their respective directories:
- [Homebrew Automation Documentation](homebrew-automation/README.md)
- [Mac Setup Documentation](mac-setup/README.md)