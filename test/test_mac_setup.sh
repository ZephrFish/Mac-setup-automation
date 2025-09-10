#!/bin/bash

# Test Suite for Mac Setup Scripts
# Run with: ./test_mac_setup.sh

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
MACSETUP_DIR="$PROJECT_ROOT/mac-setup"
TEST_TMP="$SCRIPT_DIR/tmp_macsetup"

# Setup and teardown
setup() {
    echo "Setting up test environment..."
    mkdir -p "$TEST_TMP"
}

teardown() {
    echo "Cleaning up test environment..."
    rm -rf "$TEST_TMP"
}

# Test framework functions (reused from test_brew_automation.sh)
assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-}"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if [ "$expected" = "$actual" ]; then
        echo -e "${GREEN}[PASS]${NC} $message"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}[FAIL]${NC} $message"
        echo "  Expected: $expected"
        echo "  Actual: $actual"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

assert_file_exists() {
    local file="$1"
    local message="${2:-File should exist: $file}"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if [ -f "$file" ]; then
        echo -e "${GREEN}[PASS]${NC} $message"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}[FAIL]${NC} $message"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

assert_directory_exists() {
    local dir="$1"
    local message="${2:-Directory should exist: $dir}"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if [ -d "$dir" ]; then
        echo -e "${GREEN}[PASS]${NC} $message"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}[FAIL]${NC} $message"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

assert_command_succeeds() {
    local command="$1"
    local message="${2:-Command should succeed: $command}"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if eval "$command" > /dev/null 2>&1; then
        echo -e "${GREEN}[PASS]${NC} $message"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}[FAIL]${NC} $message"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

assert_contains() {
    local file="$1"
    local pattern="$2"
    local message="${3:-File should contain pattern}"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if grep -q "$pattern" "$file" 2>/dev/null; then
        echo -e "${GREEN}[PASS]${NC} $message"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}[FAIL]${NC} $message"
        echo "  Pattern not found: $pattern"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# Test: Core script files exist
test_core_scripts() {
    echo -e "\n${YELLOW}Testing core script files...${NC}"
    
    assert_file_exists "$MACSETUP_DIR/setup.sh" "setup.sh exists"
    assert_file_exists "$MACSETUP_DIR/setup-zsh-complete.sh" "setup-zsh-complete.sh exists"
    assert_file_exists "$MACSETUP_DIR/macsetup.sh" "macsetup.sh exists"
    assert_file_exists "$MACSETUP_DIR/mac-setup-mega.sh" "mac-setup-mega.sh exists"
    assert_file_exists "$MACSETUP_DIR/install-ohmyzsh.sh" "install-ohmyzsh.sh exists"
    assert_file_exists "$MACSETUP_DIR/ohmyzsh-plugins-install.sh" "ohmyzsh-plugins-install.sh exists"
    
    assert_command_succeeds "[ -x '$MACSETUP_DIR/setup.sh' ]" "setup.sh is executable"
    assert_command_succeeds "[ -x '$MACSETUP_DIR/setup-zsh-complete.sh' ]" "setup-zsh-complete.sh is executable"
}

# Test: Directory structure
test_directory_structure() {
    echo -e "\n${YELLOW}Testing directory structure...${NC}"
    
    assert_directory_exists "$MACSETUP_DIR/config" "config directory exists"
    assert_directory_exists "$MACSETUP_DIR/lib" "lib directory exists"
    assert_directory_exists "$MACSETUP_DIR/modules" "modules directory exists"
    assert_directory_exists "$MACSETUP_DIR/utilities" "utilities directory exists"
}

# Test: Configuration files
test_config_files() {
    echo -e "\n${YELLOW}Testing configuration files...${NC}"
    
    assert_file_exists "$MACSETUP_DIR/config/Brewfile" "Brewfile exists"
    assert_file_exists "$MACSETUP_DIR/config/packages.conf" "packages.conf exists"
    assert_file_exists "$MACSETUP_DIR/config/checksums.conf" "checksums.conf exists"
    assert_file_exists "$MACSETUP_DIR/config/profiles.conf" "profiles.conf exists"
}

# Test: Library files
test_library_files() {
    echo -e "\n${YELLOW}Testing library files...${NC}"
    
    assert_file_exists "$MACSETUP_DIR/lib/common.sh" "common.sh exists"
    assert_file_exists "$MACSETUP_DIR/lib/colours.sh" "colours.sh exists"
    assert_file_exists "$MACSETUP_DIR/lib/validators.sh" "validators.sh exists"
}

# Test: Module files
test_module_files() {
    echo -e "\n${YELLOW}Testing module files...${NC}"
    
    assert_file_exists "$MACSETUP_DIR/modules/dev-tools.sh" "dev-tools.sh exists"
    assert_file_exists "$MACSETUP_DIR/modules/shell-setup.sh" "shell-setup.sh exists"
    assert_file_exists "$MACSETUP_DIR/modules/system-config.sh" "system-config.sh exists"
    assert_file_exists "$MACSETUP_DIR/modules/zshrc-setup.sh" "zshrc-setup.sh exists"
}

# Test: Utility scripts
test_utility_scripts() {
    echo -e "\n${YELLOW}Testing utility scripts...${NC}"
    
    assert_file_exists "$MACSETUP_DIR/utilities/configure-1password.sh" "configure-1password.sh exists"
    assert_file_exists "$MACSETUP_DIR/utilities/configure-system.sh" "configure-system.sh exists"
    assert_file_exists "$MACSETUP_DIR/utilities/configure-touchid-sudo.sh" "configure-touchid-sudo.sh exists"
}

# Test: Script syntax validation
test_script_syntax() {
    echo -e "\n${YELLOW}Testing script syntax...${NC}"
    
    for script in "$MACSETUP_DIR"/*.sh; do
        if [ -f "$script" ]; then
            script_name=$(basename "$script")
            assert_command_succeeds "bash -n '$script'" "$script_name has valid syntax"
        fi
    done
    
    for script in "$MACSETUP_DIR"/modules/*.sh; do
        if [ -f "$script" ]; then
            script_name=$(basename "$script")
            assert_command_succeeds "bash -n '$script'" "modules/$script_name has valid syntax"
        fi
    done
    
    for script in "$MACSETUP_DIR"/utilities/*.sh; do
        if [ -f "$script" ]; then
            script_name=$(basename "$script")
            assert_command_succeeds "bash -n '$script'" "utilities/$script_name has valid syntax"
        fi
    done
}

# Test: Profile support
test_profile_support() {
    echo -e "\n${YELLOW}Testing profile support...${NC}"
    
    assert_contains "$MACSETUP_DIR/setup.sh" "--profile" "setup.sh supports profiles"
    assert_contains "$MACSETUP_DIR/config/profiles.conf" "developer" "developer profile exists"
    assert_contains "$MACSETUP_DIR/config/profiles.conf" "devops" "devops profile exists"
    assert_contains "$MACSETUP_DIR/config/profiles.conf" "data_scientist" "data_scientist profile exists"
}

# Test: Help documentation
test_help_documentation() {
    echo -e "\n${YELLOW}Testing help documentation...${NC}"
    
    assert_contains "$MACSETUP_DIR/setup.sh" "--help" "setup.sh has help option"
    assert_contains "$MACSETUP_DIR/setup-zsh-complete.sh" "Usage:" "setup-zsh-complete.sh has usage info"
}

# Test: Error handling
test_error_handling() {
    echo -e "\n${YELLOW}Testing error handling...${NC}"
    
    assert_contains "$MACSETUP_DIR/setup.sh" "set -e" "setup.sh uses error mode"
    assert_contains "$MACSETUP_DIR/lib/common.sh" "error_exit" "common.sh has error handling"
    assert_contains "$MACSETUP_DIR/lib/validators.sh" "validate_" "validators.sh has validation functions"
}

# Test: Logging functionality
test_logging() {
    echo -e "\n${YELLOW}Testing logging functionality...${NC}"
    
    assert_contains "$MACSETUP_DIR/lib/common.sh" "log_" "common.sh has logging functions"
    assert_contains "$MACSETUP_DIR/setup.sh" "LOG_FILE" "setup.sh defines log file"
}

# Test: Homebrew integration
test_homebrew_integration() {
    echo -e "\n${YELLOW}Testing Homebrew integration...${NC}"
    
    assert_contains "$MACSETUP_DIR/config/Brewfile" "brew" "Brewfile contains brew commands"
    assert_contains "$MACSETUP_DIR/setup.sh" "brew" "setup.sh uses brew"
}

# Test: Oh My Zsh integration
test_ohmyzsh_integration() {
    echo -e "\n${YELLOW}Testing Oh My Zsh integration...${NC}"
    
    assert_contains "$MACSETUP_DIR/install-ohmyzsh.sh" "oh-my-zsh" "install-ohmyzsh.sh references oh-my-zsh"
    assert_contains "$MACSETUP_DIR/ohmyzsh-plugins-install.sh" "ZSH_CUSTOM" "plugin installer uses ZSH_CUSTOM"
    assert_contains "$MACSETUP_DIR/modules/zshrc-setup.sh" ".zshrc" "zshrc-setup.sh configures .zshrc"
}

# Test: Security features
test_security_features() {
    echo -e "\n${YELLOW}Testing security features...${NC}"
    
    assert_contains "$MACSETUP_DIR/config/checksums.conf" "sha256" "checksums.conf contains SHA256 hashes"
    assert_contains "$MACSETUP_DIR/utilities/configure-touchid-sudo.sh" "pam_tid" "Touch ID script configures PAM"
    assert_contains "$MACSETUP_DIR/lib/validators.sh" "verify_checksum" "validators.sh can verify checksums"
}

# Main test runner
main() {
    echo "================================================"
    echo "          Mac Setup Test Suite"
    echo "================================================"
    
    # Run setup
    setup
    
    # Run all tests
    test_core_scripts
    test_directory_structure
    test_config_files
    test_library_files
    test_module_files
    test_utility_scripts
    test_script_syntax
    test_profile_support
    test_help_documentation
    test_error_handling
    test_logging
    test_homebrew_integration
    test_ohmyzsh_integration
    test_security_features
    
    # Run teardown
    teardown
    
    # Print summary
    echo ""
    echo "================================================"
    echo "                Test Summary"
    echo "================================================"
    echo -e "Tests run:    $TESTS_RUN"
    echo -e "Tests passed: ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Tests failed: ${RED}$TESTS_FAILED${NC}"
    
    if [ $TESTS_FAILED -eq 0 ]; then
        echo -e "\n${GREEN}All tests passed!${NC}"
        exit 0
    else
        echo -e "\n${RED}Some tests failed.${NC}"
        exit 1
    fi
}

# Run tests
main "$@"