# Configuration Files

This directory contains template configuration files for Mac setup.

## Files

### .zshrc
Template Zsh configuration file with:
- Oh My Zsh setup with Powerlevel10k theme
- Useful plugins for development (git, docker, kubernetes, terraform, etc.)
- Modern CLI tool aliases (eza, bat, fd, ripgrep)
- Helpful shell functions
- Homebrew path configuration for Apple Silicon Macs

## Usage

Copy the .zshrc file to your home directory:
```bash
cp .zshrc ~/.zshrc
```

## Customisation

For personal or sensitive configuration (API keys, custom paths, etc.), create a `~/.zshrc.local` file which will be automatically sourced by the main .zshrc.

## Dependencies

The .zshrc file expects these tools to be installed:
- Oh My Zsh
- Powerlevel10k theme
- eza (modern ls replacement)
- bat (cat with syntax highlighting)
- fd (fast find alternative)
- ripgrep (fast grep alternative)
- neovim
- fzf (fuzzy finder)

These can be installed via the main setup scripts in the parent directory.