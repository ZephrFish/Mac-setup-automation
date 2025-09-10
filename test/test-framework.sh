#!/bin/bash

# Test Framework for Mac Setup Automation
# Provides testing utilities and assertions for shell scripts

set -euo pipefail

# Test configuration
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$TEST_DIR")"
TEMP_DIR=""
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_SKIPPED=0

# Colours for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Colour

# Test result tracking
declare -a FAILED_TESTS=()
declare -a PASSED_TESTS=()
declare -a SKIPPED_TESTS=()

# Setup test environment
setup_test_env() {
    TEMP_DIR=$(mktemp -d "${TMPDIR:-/tmp}/macsetup-test.XXXXXX")
    export TEST_MODE=1
    export ALLOW_ABSOLUTE_PATHS=true
    export LOG_LEVEL=ERROR  # Reduce noise during tests
}

# Cleanup test environment
cleanup_test_env() {
    if [[ -n "$TEMP_DIR" && -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR"
    fi
}

# Test assertion functions
assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-Assertion failed}"
    
    if [[ "$expected" == "$actual" ]]; then
        return 0
    else
        echo -e "${RED}✗ $message${NC}"
        echo "  Expected: '$expected'"
        echo "  Actual:   '$actual'"
        return 1
    fi
}

assert_not_equals() {
    local unexpected="$1"
    local actual="$2"
    local message="${3:-Assertion failed}"
    
    if [[ "$unexpected" != "$actual" ]]; then
        return 0
    else
        echo -e "${RED}✗ $message${NC}"
        echo "  Should not be: '$unexpected'"
        return 1
    fi
}

assert_true() {
    local condition="$1"
    local message="${2:-Assertion failed}"
    
    if eval "$condition"; then
        return 0
    else
        echo -e "${RED}✗ $message${NC}"
        echo "  Condition failed: $condition"
        return 1
    fi
}

assert_false() {
    local condition="$1"
    local message="${2:-Assertion failed}"
    
    if ! eval "$condition"; then
        return 0
    else
        echo -e "${RED}✗ $message${NC}"
        echo "  Condition should be false: $condition"
        return 1
    fi
}

assert_file_exists() {
    local file="$1"
    local message="${2:-File should exist}"
    
    if [[ -f "$file" ]]; then
        return 0
    else
        echo -e "${RED}✗ $message${NC}"
        echo "  File not found: $file"
        return 1
    fi
}

assert_dir_exists() {
    local dir="$1"
    local message="${2:-Directory should exist}"
    
    if [[ -d "$dir" ]]; then
        return 0
    else
        echo -e "${RED}✗ $message${NC}"
        echo "  Directory not found: $dir"
        return 1
    fi
}

assert_command_succeeds() {
    local command="$1"
    local message="${2:-Command should succeed}"
    
    if eval "$command" &>/dev/null; then
        return 0
    else
        echo -e "${RED}✗ $message${NC}"
        echo "  Command failed: $command"
        return 1
    fi
}

assert_command_fails() {
    local command="$1"
    local message="${2:-Command should fail}"
    
    if ! eval "$command" &>/dev/null; then
        return 0
    else
        echo -e "${RED}✗ $message${NC}"
        echo "  Command should have failed: $command"
        return 1
    fi
}

assert_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-String should contain substring}"
    
    if [[ "$haystack" == *"$needle"* ]]; then
        return 0
    else
        echo -e "${RED}✗ $message${NC}"
        echo "  String: '$haystack'"
        echo "  Should contain: '$needle'"
        return 1
    fi
}

assert_matches() {
    local string="$1"
    local pattern="$2"
    local message="${3:-String should match pattern}"
    
    if [[ "$string" =~ $pattern ]]; then
        return 0
    else
        echo -e "${RED}✗ $message${NC}"
        echo "  String: '$string'"
        echo "  Should match: '$pattern'"
        return 1
    fi
}

# Test execution functions
run_test() {
    local test_name="$1"
    local test_function="$2"
    
    ((TESTS_RUN++))
    
    echo -n "  Testing $test_name... "
    
    # Create isolated test environment
    local test_temp_dir="$TEMP_DIR/$test_name"
    mkdir -p "$test_temp_dir"
    
    # Run test in subshell to isolate environment
    if (
        cd "$test_temp_dir"
        $test_function
    ) 2>&1 | grep -v "^$" > "$test_temp_dir/output.log"; then
        echo -e "${GREEN}✓${NC}"
        ((TESTS_PASSED++))
        PASSED_TESTS+=("$test_name")
    else
        echo -e "${RED}✗${NC}"
        ((TESTS_FAILED++))
        FAILED_TESTS+=("$test_name")
        
        # Show test output on failure
        if [[ -s "$test_temp_dir/output.log" ]]; then
            echo "    Output:"
            sed 's/^/    /' "$test_temp_dir/output.log"
        fi
    fi
}

skip_test() {
    local test_name="$1"
    local reason="${2:-No reason provided}"
    
    ((TESTS_RUN++))
    ((TESTS_SKIPPED++))
    SKIPPED_TESTS+=("$test_name")
    
    echo -e "  Testing $test_name... ${YELLOW}SKIPPED${NC} ($reason)"
}

# Test suite functions
describe() {
    local suite_name="$1"
    echo -e "\n${BLUE}Testing: $suite_name${NC}"
}

# Summary reporting
print_summary() {
    echo -e "\n${BLUE}════════════════════════════════════════${NC}"
    echo -e "${BLUE}Test Summary${NC}"
    echo -e "${BLUE}════════════════════════════════════════${NC}"
    
    echo -e "Total tests run: $TESTS_RUN"
    echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
    echo -e "${RED}Failed: $TESTS_FAILED${NC}"
    echo -e "${YELLOW}Skipped: $TESTS_SKIPPED${NC}"
    
    if [[ ${#FAILED_TESTS[@]} -gt 0 ]]; then
        echo -e "\n${RED}Failed tests:${NC}"
        for test in "${FAILED_TESTS[@]}"; do
            echo "  - $test"
        done
    fi
    
    if [[ ${#SKIPPED_TESTS[@]} -gt 0 ]]; then
        echo -e "\n${YELLOW}Skipped tests:${NC}"
        for test in "${SKIPPED_TESTS[@]}"; do
            echo "  - $test"
        done
    fi
    
    echo -e "\n${BLUE}════════════════════════════════════════${NC}"
    
    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "${GREEN}All tests passed!${NC}"
        return 0
    else
        echo -e "${RED}Some tests failed.${NC}"
        return 1
    fi
}

# Mock functions for testing
mock_command() {
    local command="$1"
    local mock_output="${2:-}"
    local mock_exit_code="${3:-0}"
    
    # Create mock command in test PATH
    local mock_path="$TEMP_DIR/mocks"
    mkdir -p "$mock_path"
    
    cat > "$mock_path/$command" << EOF
#!/bin/bash
echo "$mock_output"
exit $mock_exit_code
EOF
    
    chmod +x "$mock_path/$command"
    export PATH="$mock_path:$PATH"
}

# Trap cleanup on exit
trap cleanup_test_env EXIT

# Export test functions
export -f assert_equals
export -f assert_not_equals
export -f assert_true
export -f assert_false
export -f assert_file_exists
export -f assert_dir_exists
export -f assert_command_succeeds
export -f assert_command_fails
export -f assert_contains
export -f assert_matches
export -f run_test
export -f skip_test
export -f describe
export -f mock_command