# MacSetup - Comprehensive macOS Development Environment

<div align="center">

![Version](https://img.shields.io/badge/version-3.0.0-blue.svg)
![macOS](https://img.shields.io/badge/macOS-12.0%2B-green.svg)
![Apple Silicon](https://img.shields.io/badge/Apple%20Silicon-Ready-orange.svg)
![License](https://img.shields.io/badge/license-MIT-purple.svg)

**Automated, secure, and comprehensive macOS development environment setup**

[Quick Start](#-quick-start) • [Features](#-features) • [Installation](#-installation) • [Documentation](#-documentation) • [Contributing](#-contributing)

</div>

---

## 🚀 Quick Start

```bash
# Clone and run
git clone https://github.com/yourusername/macsetup.git
cd macsetup

# Complete Zsh and terminal setup (recommended)
./setup-zsh-complete.sh

# Or full system setup
./setup.sh quick --profile developer
```

**That's it!** Your Mac will be configured with a complete development environment in minutes.

## ✨ Features

### 🛡️ Security First
- **Checksum Verification**: All downloads verified for integrity
- **Touch ID for Sudo**: Biometric authentication for admin tasks
- **1Password Integration**: Secure credential management
- **Encrypted Secrets**: Sensitive data protection

### 📦 Comprehensive Tools
- **Development**: 15+ languages and frameworks
- **Databases**: PostgreSQL, MySQL, MongoDB, Redis
- **Containers**: Docker, Kubernetes, OrbStack
- **Cloud**: AWS, Azure, GCP, Terraform
- **Productivity**: 30+ CLI tools

### ⚡ Performance Optimized
- **Apple Silicon Native**: Optimized for M3/M4 processors
- **SSD Optimization**: Extended drive lifespan
- **System Tuning**: Developer-friendly settings
- **Resource Management**: Efficient memory usage

### 🎯 Smart Profiles
- **Developer**: Full-stack development
- **DevOps**: Infrastructure and cloud
- **Data Scientist**: ML and data tools
- **Designer**: Creative and frontend
- **Media**: Production and editing

## 📋 Installation

### Prerequisites
- macOS 12.0 (Monterey) or later
- Apple Silicon (M1/M2/M3/M4) or Intel Mac
- 10GB free disk space
- Administrator access

### Installation Methods

#### 🎯 Quick Setup (Recommended)
```bash
./setup.sh quick
```
Installs recommended tools with sensible defaults.

#### 🛠️ Custom Setup
```bash
./setup.sh --profile devops --with-optional
```
Choose specific profile and include optional tools.

#### 🎨 Interactive Setup
```bash
./setup.sh
```
Menu-driven installation with full control.

#### 🔍 Preview Mode
```bash
./setup.sh full --dry-run
```
See what would be installed without making changes.

### Command Options

| Option | Description |
|--------|-------------|
| `quick` | Quick setup with defaults |
| `full` | Complete installation |
| `minimal` | Essential tools only |
| `dev` | Development tools only |
| `shell` | Shell environment only |
| `system` | System settings only |
| `status` | Check installation status |

### Flags

| Flag | Description |
|------|-------------|
| `--profile PROFILE` | Use specific profile |
| `--dry-run` | Preview without changes |
| `--verbose` | Detailed output |
| `--no-confirm` | Skip confirmations |
| `--with-optional` | Include optional packages |
| `--backup` | Backup before changes |

## 🗂️ What's Included

### Development Environment

<details>
<summary><strong>Languages & Runtimes</strong></summary>

- Node.js 20 LTS
- Python 3.12
- Go 1.21
- Rust (latest)
- Ruby 3.3
- Java 21
- Swift
- TypeScript
- And more...

</details>

<details>
<summary><strong>Developer Tools</strong></summary>

- Visual Studio Code
- IntelliJ IDEA
- Docker & OrbStack
- Postman/Insomnia
- TablePlus
- GitHub Desktop
- And more...

</details>

<details>
<summary><strong>CLI Productivity</strong></summary>

- **Modern Replacements**: `bat` (cat), `eza` (ls), `ripgrep` (grep), `fd` (find)
- **Git Tools**: `lazygit`, `git-delta`, `gh`
- **Terminal**: iTerm2, Warp, Kitty
- **Multiplexer**: tmux with plugins
- **Fuzzy Finder**: fzf with integrations

</details>

### System Configuration

<details>
<summary><strong>macOS Optimizations</strong></summary>

- Show hidden files and extensions
- Developer-friendly Finder settings
- Optimized keyboard repeat rates
- Disabled unnecessary animations
- SSD-specific optimizations
- Increased file handle limits

</details>

<details>
<summary><strong>Shell Environment</strong></summary>

- Oh My Zsh with Powerlevel10k
- Auto-suggestions and syntax highlighting
- Custom aliases and functions
- FZF integration
- Git status in prompt
- Smart directory navigation

</details>

## 📁 Project Structure

```
MacSetup/
├── setup.sh              # Main setup script (v3.0)
├── setup-zsh-complete.sh # Complete Zsh setup
├── macsetup.sh          # Legacy setup script (v2.1)
├── lib/
│   ├── common.sh        # Shared functions
│   ├── colors.sh        # Color definitions
│   └── validators.sh    # Input validation
├── modules/
│   ├── dev-tools.sh     # Development tools
│   ├── shell-setup.sh   # Shell configuration
│   ├── zshrc-setup.sh   # Zsh configuration module
│   └── system-config.sh # System settings
├── config/
│   ├── .zshrc           # Zsh configuration template
│   ├── Brewfile         # Homebrew packages
│   ├── packages.conf    # Package definitions
│   └── checksums.conf   # Security checksums
└── utilities/
    ├── configure-1password.sh
    ├── configure-system.sh
    └── configure-touchid-sudo.sh
```

## 🔒 Security

### Security Features
- ✅ SHA256 checksum verification
- ✅ Secure download with retry logic
- ✅ Backup before modifications
- ✅ Touch ID for sudo authentication
- ✅ 1Password CLI integration
- ✅ No hardcoded credentials
- ✅ Audit logging

### Security Best Practices
1. Review scripts before running
2. Use `--dry-run` to preview changes
3. Keep checksums updated
4. Regular security updates
5. Use profiles for least privilege

## 📊 Status Check

Run `./setup.sh status` to see:
- Installed tools and versions
- System configuration status
- Missing components
- Security settings

## 🔧 Troubleshooting

### Common Issues

<details>
<summary><strong>Homebrew Installation Fails</strong></summary>

```bash
# Manually install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add to PATH (Apple Silicon)
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

</details>

<details>
<summary><strong>Touch ID Not Working</strong></summary>

```bash
# Check Touch ID availability
system_profiler SPHardwareDataType | grep "Touch ID"

# Manually configure
echo "auth sufficient pam_tid.so" | sudo tee /etc/pam.d/sudo_local
```

</details>

<details>
<summary><strong>Permission Errors</strong></summary>

```bash
# Fix Homebrew permissions
sudo chown -R $(whoami) /opt/homebrew

# Reset sudo access
sudo -k
sudo -v
```

</details>

### Getting Help
- Check logs: `~/.macsetup/logs/`
- Run with `--verbose` for details
- Open an [issue](https://github.com/yourusername/macsetup/issues)

## 🤝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Development
```bash
# Run tests
./test.sh

# Lint scripts
shellcheck *.sh lib/*.sh modules/*.sh

# Format code
shfmt -w *.sh
```

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

Built with inspiration from:
- [mathiasbynens/dotfiles](https://github.com/mathiasbynens/dotfiles)
- [thoughtbot/laptop](https://github.com/thoughtbot/laptop)
- [donnemartin/dev-setup](https://github.com/donnemartin/dev-setup)
- [nikitavoloboev/my-mac-os](https://github.com/nikitavoloboev/my-mac-os)

## 📈 Roadmap

- [ ] GUI application for setup
- [ ] Cloud backup/restore
- [ ] Team configuration profiles
- [ ] Automated updates
- [ ] Docker-based testing
- [ ] CI/CD integration

## 💬 Support

- **Documentation**: [Wiki](https://github.com/yourusername/macsetup/wiki)
- **Issues**: [GitHub Issues](https://github.com/yourusername/macsetup/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/macsetup/discussions)

## 📊 Version History

### v3.0.0 (Current)
- Complete rewrite with enhanced security
- Declarative package management with Brewfile
- Smart profiles for different workflows
- Checksum verification for all downloads
- Comprehensive error handling and logging

### v2.1.0
- Modular architecture
- Input validation
- Dry-run mode
- Interactive menus

### v2.0.0
- Initial modular design
- Basic menu system

### v1.0.0
- Original script collection

---

<div align="center">

**Made with ❤️ for the macOS developer community**

[⬆ Back to Top](#macsetup---comprehensive-macos-development-environment)

</div>