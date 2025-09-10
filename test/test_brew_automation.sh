#!/bin/bash

# Test Suite for Homebrew Automation Scripts
# Run with: ./test_brew_automation.sh

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
HOMEBREW_DIR="$PROJECT_ROOT/homebrew-automation"
TEST_TMP="$SCRIPT_DIR/tmp"

# Setup and teardown
setup() {
    echo "Setting up test environment..."
    mkdir -p "$TEST_TMP"
    mkdir -p "$TEST_TMP/logs"
}

teardown() {
    echo "Cleaning up test environment..."
    rm -rf "$TEST_TMP"
}

# Test framework functions
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

assert_file_not_exists() {
    local file="$1"
    local message="${2:-File should not exist: $file}"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if [ ! -f "$file" ]; then
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

# Test: Script files exist and are executable
test_script_files() {
    echo -e "\n${YELLOW}Testing script file existence and permissions...${NC}"
    
    assert_file_exists "$HOMEBREW_DIR/brew-update.sh" "brew-update.sh exists"
    assert_file_exists "$HOMEBREW_DIR/brew-log-cleanup.sh" "brew-log-cleanup.sh exists"
    assert_file_exists "$HOMEBREW_DIR/install-launch-agents.sh" "install-launch-agents.sh exists"
    assert_file_exists "$HOMEBREW_DIR/uninstall-launch-agents.sh" "uninstall-launch-agents.sh exists"
    
    assert_command_succeeds "[ -x '$HOMEBREW_DIR/brew-update.sh' ]" "brew-update.sh is executable"
    assert_command_succeeds "[ -x '$HOMEBREW_DIR/brew-log-cleanup.sh' ]" "brew-log-cleanup.sh is executable"
    assert_command_succeeds "[ -x '$HOMEBREW_DIR/install-launch-agents.sh' ]" "install-launch-agents.sh is executable"
    assert_command_succeeds "[ -x '$HOMEBREW_DIR/uninstall-launch-agents.sh' ]" "uninstall-launch-agents.sh is executable"
}

# Test: LaunchAgent plist files exist and are valid
test_plist_files() {
    echo -e "\n${YELLOW}Testing LaunchAgent plist files...${NC}"
    
    assert_file_exists "$HOMEBREW_DIR/LaunchAgents/com.user.brew-update.plist" "brew-update plist exists"
    assert_file_exists "$HOMEBREW_DIR/LaunchAgents/com.user.brew-log-cleanup.plist" "brew-log-cleanup plist exists"
    
    # Test plist file validity
    if command -v plutil &> /dev/null; then
        assert_command_succeeds "plutil -lint '$HOMEBREW_DIR/LaunchAgents/com.user.brew-update.plist'" "brew-update plist is valid XML"
        assert_command_succeeds "plutil -lint '$HOMEBREW_DIR/LaunchAgents/com.user.brew-log-cleanup.plist'" "brew-log-cleanup plist is valid XML"
    else
        echo -e "${YELLOW}[SKIP]${NC} plutil not available - skipping plist validation"
    fi
}

# Test: Script syntax validation
test_script_syntax() {
    echo -e "\n${YELLOW}Testing script syntax...${NC}"
    
    assert_command_succeeds "bash -n '$HOMEBREW_DIR/brew-update.sh'" "brew-update.sh has valid syntax"
    assert_command_succeeds "bash -n '$HOMEBREW_DIR/brew-log-cleanup.sh'" "brew-log-cleanup.sh has valid syntax"
    assert_command_succeeds "bash -n '$HOMEBREW_DIR/install-launch-agents.sh'" "install-launch-agents.sh has valid syntax"
    assert_command_succeeds "bash -n '$HOMEBREW_DIR/uninstall-launch-agents.sh'" "uninstall-launch-agents.sh has valid syntax"
}

# Test: Log directory creation
test_log_directory_creation() {
    echo -e "\n${YELLOW}Testing log directory creation...${NC}"
    
    # Simulate log directory creation
    HOME="$TEST_TMP" bash -c 'source "$1" 2>/dev/null || true' _ "$HOMEBREW_DIR/brew-update.sh"
    
    assert_directory_exists "$TEST_TMP/Library/Logs/Homebrew" "Log directory is created"
}

# Test: Installation script behavior (dry run)
test_installation_script() {
    echo -e "\n${YELLOW}Testing installation script behavior...${NC}"
    
    # Check that install script checks for required files
    assert_contains "$HOMEBREW_DIR/install-launch-agents.sh" "LaunchAgents/com.user.brew-update.plist" "Install script references brew-update plist"
    assert_contains "$HOMEBREW_DIR/install-launch-agents.sh" "LaunchAgents/com.user.brew-log-cleanup.plist" "Install script references brew-log-cleanup plist"
    assert_contains "$HOMEBREW_DIR/install-launch-agents.sh" "launchctl" "Install script uses launchctl"
}

# Test: Uninstallation script behavior
test_uninstallation_script() {
    echo -e "\n${YELLOW}Testing uninstallation script behavior...${NC}"
    
    assert_contains "$HOMEBREW_DIR/uninstall-launch-agents.sh" "launchctl unload" "Uninstall script unloads agents"
    assert_contains "$HOMEBREW_DIR/uninstall-launch-agents.sh" "com.user.brew-update" "Uninstall script references brew-update"
    assert_contains "$HOMEBREW_DIR/uninstall-launch-agents.sh" "com.user.brew-log-cleanup" "Uninstall script references brew-log-cleanup"
}

# Test: Script error handling
test_error_handling() {
    echo -e "\n${YELLOW}Testing error handling...${NC}"
    
    assert_contains "$HOMEBREW_DIR/brew-update.sh" "command -v brew" "brew-update checks for brew installation"
    assert_contains "$HOMEBREW_DIR/brew-update.sh" "exit 1" "brew-update has error exit"
    
    assert_contains "$HOMEBREW_DIR/install-launch-agents.sh" "exit 1" "install script has error handling"
}

# Test: LaunchAgent schedule configuration
test_launchagent_schedule() {
    echo -e "\n${YELLOW}Testing LaunchAgent schedule configuration...${NC}"
    
    assert_contains "$HOMEBREW_DIR/LaunchAgents/com.user.brew-update.plist" "<key>StartCalendarInterval</key>" "brew-update has schedule"
    assert_contains "$HOMEBREW_DIR/LaunchAgents/com.user.brew-log-cleanup.plist" "<key>StartCalendarInterval</key>" "brew-log-cleanup has schedule"
    
    # Check for time configuration
    assert_contains "$HOMEBREW_DIR/LaunchAgents/com.user.brew-update.plist" "<key>Hour</key>" "brew-update has hour setting"
    assert_contains "$HOMEBREW_DIR/LaunchAgents/com.user.brew-log-cleanup.plist" "<key>Hour</key>" "brew-log-cleanup has hour setting"
}

# Test: PATH configuration in plist files
test_path_configuration() {
    echo -e "\n${YELLOW}Testing PATH configuration...${NC}"
    
    assert_contains "$HOMEBREW_DIR/LaunchAgents/com.user.brew-update.plist" "/opt/homebrew/bin" "brew-update includes Apple Silicon brew path"
    assert_contains "$HOMEBREW_DIR/LaunchAgents/com.user.brew-log-cleanup.plist" "/opt/homebrew/bin" "brew-log-cleanup includes Apple Silicon brew path"
    assert_contains "$HOMEBREW_DIR/LaunchAgents/com.user.brew-update.plist" "/usr/local/bin" "brew-update includes Intel brew path"
}

# Test: Logging functionality
test_logging() {
    echo -e "\n${YELLOW}Testing logging functionality...${NC}"
    
    assert_contains "$HOMEBREW_DIR/brew-update.sh" "log_message" "brew-update has logging function"
    assert_contains "$HOMEBREW_DIR/brew-log-cleanup.sh" "log_message" "brew-log-cleanup has logging function"
    
    assert_contains "$HOMEBREW_DIR/brew-update.sh" "LOG_FILE=" "brew-update defines log file"
    assert_contains "$HOMEBREW_DIR/brew-log-cleanup.sh" "LOG_FILE=" "brew-log-cleanup defines log file"
}

# Test: Cleanup functionality
test_cleanup_functionality() {
    echo -e "\n${YELLOW}Testing cleanup functionality...${NC}"
    
    assert_contains "$HOMEBREW_DIR/brew-update.sh" "brew cleanup" "brew-update performs cleanup"
    assert_contains "$HOMEBREW_DIR/brew-log-cleanup.sh" "find" "brew-log-cleanup uses find for old files"
    assert_contains "$HOMEBREW_DIR/brew-log-cleanup.sh" "-mtime" "brew-log-cleanup checks file age"
}

# Main test runner
main() {
    echo "================================================"
    echo "     Homebrew Automation Test Suite"
    echo "================================================"
    
    # Run setup
    setup
    
    # Run all tests
    test_script_files
    test_plist_files
    test_script_syntax
    test_log_directory_creation
    test_installation_script
    test_uninstallation_script
    test_error_handling
    test_launchagent_schedule
    test_path_configuration
    test_logging
    test_cleanup_functionality
    
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