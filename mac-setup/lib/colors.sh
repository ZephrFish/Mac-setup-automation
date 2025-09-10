#!/bin/bash

# Color definitions for terminal output
# Provides consistent color scheme across all scripts

# Regular Colors
export BLACK='\033[0;30m'
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[0;33m'
export BLUE='\033[0;34m'
export PURPLE='\033[0;35m'
export CYAN='\033[0;36m'
export WHITE='\033[0;37m'
export GRAY='\033[0;90m'

# Bold Colors
export BOLD_BLACK='\033[1;30m'
export BOLD_RED='\033[1;31m'
export BOLD_GREEN='\033[1;32m'
export BOLD_YELLOW='\033[1;33m'
export BOLD_BLUE='\033[1;34m'
export BOLD_PURPLE='\033[1;35m'
export BOLD_CYAN='\033[1;36m'
export BOLD_WHITE='\033[1;37m'

# Background Colors
export BG_BLACK='\033[40m'
export BG_RED='\033[41m'
export BG_GREEN='\033[42m'
export BG_YELLOW='\033[43m'
export BG_BLUE='\033[44m'
export BG_PURPLE='\033[45m'
export BG_CYAN='\033[46m'
export BG_WHITE='\033[47m'

# Special Effects
export BOLD='\033[1m'
export DIM='\033[2m'
export ITALIC='\033[3m'
export UNDERLINE='\033[4m'
export BLINK='\033[5m'
export REVERSE='\033[7m'
export HIDDEN='\033[8m'
export STRIKETHROUGH='\033[9m'

# Reset
export NC='\033[0m' # No Color / Reset

# Semantic Colors
export COLOR_SUCCESS="$GREEN"
export COLOR_ERROR="$RED"
export COLOR_WARNING="$YELLOW"
export COLOR_INFO="$CYAN"
export COLOR_DEBUG="$GRAY"
export COLOR_HEADER="$BOLD_CYAN"
export COLOR_PROMPT="$BOLD_BLUE"

# Print colored header
print_header() {
    local title="$1"
    local width=70
    local padding=$(( (width - ${#title}) / 2 ))
    
    echo -e "${COLOR_HEADER}"
    echo "$(printf '=%.0s' $(seq 1 $width))"
    printf "%*s%s%*s\n" $padding "" "$title" $((width - padding - ${#title})) ""
    echo "$(printf '=%.0s' $(seq 1 $width))"
    echo -e "${NC}"
}

# Print colored separator
print_separator() {
    echo -e "${COLOR_INFO}----------------------------------------------------${NC}"
}

# Print colored bullet point
print_bullet() {
    local message="$1"
    echo -e "${COLOR_INFO}*${NC} $message"
}

# Print colored checkmark
print_check() {
    local message="$1"
    echo -e "${COLOR_SUCCESS}[OK]${NC} $message"
}

# Print colored cross
print_cross() {
    local message="$1"
    echo -e "${COLOR_ERROR}[FAIL]${NC} $message"
}

# Print colored warning
print_warning() {
    local message="$1"
    echo -e "${COLOR_WARNING}[WARN]${NC} $message"
}

# Print colored info
print_info() {
    local message="$1"
    echo -e "${COLOR_INFO}[INFO]${NC} $message"
}

# Export functions
export -f print_header
export -f print_separator
export -f print_bullet
export -f print_check
export -f print_cross
export -f print_warning
export -f print_info