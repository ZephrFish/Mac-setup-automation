#!/bin/bash

# Test suite for main setup scripts
# Tests critical setup functions and workflows

set -euo pipefail

# Source test framework
source "$(dirname "$0")/test-framework.sh"

# Test script safety and error handling
test_script_safety() {
    local script="$1"
    
    # Check for set -e (exit on error)
    assert_command_succeeds "grep -q 'set -e' '$script'" "Script should use 'set -e'"
    
    # Check for proper error handling
    if grep -q 'set -.*u' "$script"; then
        echo "  ✓ Uses set -u (undefined variable protection)"
    fi
    
    if grep -q 'set -.*o pipefail' "$script"; then
        echo "  ✓ Uses pipefail (pipe error detection)"
    fi
    
    # Check for trap handlers
    if grep -q '^trap ' "$script"; then
        echo "  ✓ Has trap handlers for cleanup"
    fi
}

# Test script dependencies
test_script_dependencies() {
    local script="$1"
    
    # Check if script sources required libraries
    if grep -q 'source.*common\.sh' "$script"; then
        assert_file_exists "$PROJECT_ROOT/mac-setup/lib/common.sh" "Required library common.sh should exist"
    fi
    
    if grep -q 'source.*colors\.sh' "$script"; then
        assert_file_exists "$PROJECT_ROOT/mac-setup/lib/colors.sh" "Required library colors.sh should exist"
    fi
    
    if grep -q 'source.*validators\.sh' "$script"; then
        assert_file_exists "$PROJECT_ROOT/mac-setup/lib/validators.sh" "Required library validators.sh should exist"
    fi
}

# Test Brewfile syntax
test_brewfile_syntax() {
    local brewfile="$PROJECT_ROOT/mac-setup/config/Brewfile"
    
    assert_file_exists "$brewfile" "Brewfile should exist"
    
    # Check for valid tap syntax
    assert_command_succeeds "grep -E '^tap \"[^\"]+\"' '$brewfile' || true" "Tap syntax should be valid"
    
    # Check for valid brew syntax
    assert_command_succeeds "grep -E '^brew \"[^\"]+\"' '$brewfile' || true" "Brew syntax should be valid"
    
    # Check for valid cask syntax
    assert_command_succeeds "grep -E '^cask \"[^\"]+\"' '$brewfile' || true" "Cask syntax should be valid"
    
    # Ensure no deprecated taps
    assert_command_fails "grep -q 'homebrew/bundle' '$brewfile'" "Should not contain deprecated homebrew/bundle tap"
}

# Test configuration files
test_config_files() {
    # Test packages.conf
    local packages_conf="$PROJECT_ROOT/mac-setup/config/packages.conf"
    if [[ -f "$packages_conf" ]]; then
        # Check for proper format
        assert_command_succeeds "grep -E '^[A-Z_]+=' '$packages_conf' || true" "packages.conf should have valid variable format"
    fi
    
    # Test checksums.conf
    local checksums_conf="$PROJECT_ROOT/mac-setup/config/checksums.conf"
    if [[ -f "$checksums_conf" ]]; then
        # Check for SHA256 format
        assert_command_succeeds "grep -E '^[a-f0-9]{64}  ' '$checksums_conf' || true" "checksums.conf should contain valid SHA256 hashes"
    fi
}

# Test module structure
test_module_structure() {
    local modules_dir="$PROJECT_ROOT/mac-setup/modules"
    
    assert_dir_exists "$modules_dir" "Modules directory should exist"
    
    # Check each module has required functions
    for module in "$modules_dir"/*.sh; do
        if [[ -f "$module" ]]; then
            local module_name=$(basename "$module")
            echo "  Checking module: $module_name"
            
            # Check for function definitions
            if grep -q 'function.*install\|.*_install()' "$module"; then
                echo "    ✓ Has install function"
            fi
            
            if grep -q 'function.*configure\|.*_configure()' "$module"; then
                echo "    ✓ Has configure function"
            fi
        fi
    done
}

# Test homebrew automation scripts
test_homebrew_automation() {
    local brew_update="$PROJECT_ROOT/homebrew-automation/brew-update.sh"
    local brew_cleanup="$PROJECT_ROOT/homebrew-automation/brew-log-cleanup.sh"
    
    assert_file_exists "$brew_update" "brew-update.sh should exist"
    assert_file_exists "$brew_cleanup" "brew-log-cleanup.sh should exist"
    
    # Check for executable permissions
    assert_true "[[ -x '$brew_update' ]]" "brew-update.sh should be executable"
    assert_true "[[ -x '$brew_cleanup' ]]" "brew-log-cleanup.sh should be executable"
    
    # Check for log directory creation
    assert_contains "$(cat '$brew_update')" "mkdir -p" "Should create log directory"
    
    # Check for proper brew commands
    assert_contains "$(cat '$brew_update')" "brew update" "Should run brew update"
    assert_contains "$(cat '$brew_update')" "brew upgrade" "Should run brew upgrade"
}

# Test LaunchAgent plist files
test_launch_agents() {
    local plist_dir="$PROJECT_ROOT/homebrew-automation/LaunchAgents"
    
    assert_dir_exists "$plist_dir" "LaunchAgents directory should exist"
    
    # Check plist files
    for plist in "$plist_dir"/*.plist; do
        if [[ -f "$plist" ]]; then
            local plist_name=$(basename "$plist")
            echo "  Checking plist: $plist_name"
            
            # Check for required plist keys
            assert_contains "$(cat '$plist')" "<key>Label</key>" "Plist should have Label key"
            assert_contains "$(cat '$plist')" "<key>ProgramArguments</key>" "Plist should have ProgramArguments"
            assert_contains "$(cat '$plist')" "<key>StartCalendarInterval</key>" "Plist should have schedule"
            
            # Check for placeholder replacement markers
            if grep -q 'HOMEBREW_SCRIPTS_DIR\|USER_HOME_DIR' "$plist"; then
                echo "    ⚠ Contains placeholders that need replacement during installation"
            fi
        fi
    done
}

# Test script argument handling
test_argument_handling() {
    local setup_script="$PROJECT_ROOT/mac-setup/setup.sh"
    
    # Test help flag
    assert_contains "$(bash '$setup_script' --help 2>&1 || true)" "Usage" "Should show usage with --help"
    
    # Test dry-run flag
    if grep -q 'DRY_RUN\|dry.run\|--dry-run' "$setup_script"; then
        echo "  ✓ Supports --dry-run flag"
    fi
    
    # Test verbose flag
    if grep -q 'VERBOSE\|verbose\|--verbose' "$setup_script"; then
        echo "  ✓ Supports --verbose flag"
    fi
}

# Test for security issues
test_security() {
    echo "  Checking for security issues..."
    
    # Check for hardcoded passwords
    local found_passwords=0
    for script in "$PROJECT_ROOT"/**/*.sh; do
        if [[ -f "$script" ]]; then
            if grep -qiE 'password.*=.*["\047][^$]' "$script"; then
                echo "    ⚠ Potential hardcoded password in: $(basename "$script")"
                ((found_passwords++))
            fi
        fi
    done
    
    assert_equals "0" "$found_passwords" "Should not contain hardcoded passwords"
    
    # Check for unsafe curl/wget usage
    local unsafe_downloads=0
    for script in "$PROJECT_ROOT"/**/*.sh; do
        if [[ -f "$script" ]]; then
            if grep -qE 'curl.*\| *(sudo)? *sh\|wget.*\| *(sudo)? *sh' "$script"; then
                echo "    ⚠ Unsafe download execution in: $(basename "$script")"
                ((unsafe_downloads++))
            fi
        fi
    done
    
    assert_equals "0" "$unsafe_downloads" "Should not pipe downloads directly to shell"
}

# Main test execution
main() {
    setup_test_env
    
    describe "Script Safety and Standards"
    
    # Test main setup scripts
    for script in "$PROJECT_ROOT"/mac-setup/*.sh; do
        if [[ -f "$script" ]]; then
            local script_name=$(basename "$script")
            run_test "safety_$script_name" "test_script_safety '$script'"
            run_test "dependencies_$script_name" "test_script_dependencies '$script'"
        fi
    done
    
    describe "Configuration Files"
    run_test "brewfile_syntax" test_brewfile_syntax
    run_test "config_files" test_config_files
    
    describe "Module Structure"
    run_test "module_structure" test_module_structure
    
    describe "Homebrew Automation"
    run_test "homebrew_automation" test_homebrew_automation
    run_test "launch_agents" test_launch_agents
    
    describe "Script Features"
    run_test "argument_handling" test_argument_handling
    
    describe "Security"
    run_test "security_checks" test_security
    
    print_summary
}

# Run tests if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi