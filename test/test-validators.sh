#!/bin/bash

# Test suite for validators.sh
# Tests all validation functions

set -euo pipefail

# Source test framework
source "$(dirname "$0")/test-framework.sh"

# Source the validators
source "$PROJECT_ROOT/mac-setup/lib/validators.sh"

# Mock the log function if not available
if ! command -v log &>/dev/null; then
    log() {
        echo "[$1] ${@:2}" >&2
    }
    export -f log
fi

# Test validate_number function
test_validate_number() {
    # Valid numbers
    assert_command_succeeds "validate_number 42" "Should accept valid number"
    assert_command_succeeds "validate_number 0" "Should accept zero"
    assert_command_succeeds "validate_number 999999" "Should accept large number"
    
    # With range
    assert_command_succeeds "validate_number 5 1 10" "Should accept number in range"
    assert_command_fails "validate_number 15 1 10" "Should reject number above range"
    assert_command_fails "validate_number 0 1 10" "Should reject number below range"
    
    # Invalid inputs
    assert_command_fails "validate_number abc" "Should reject non-numeric"
    assert_command_fails "validate_number 12.5" "Should reject decimal"
    assert_command_fails "validate_number -5" "Should reject negative"
    assert_command_fails "validate_number ''" "Should reject empty string"
}

# Test validate_menu_choice function
test_validate_menu_choice() {
    # Valid choices
    assert_command_succeeds "validate_menu_choice 1 1 2 3 4" "Should accept valid choice"
    assert_command_succeeds "validate_menu_choice quit quit exit cancel" "Should accept string choice"
    
    # Invalid choices
    assert_command_fails "validate_menu_choice 5 1 2 3 4" "Should reject invalid choice"
    assert_command_fails "validate_menu_choice '' 1 2 3" "Should reject empty choice"
}

# Test validate_path function
test_validate_path() {
    # Valid paths
    assert_command_succeeds "validate_path /usr/local/bin" "Should accept absolute path"
    assert_command_succeeds "validate_path relative/path" "Should accept relative path"
    
    # Directory traversal attempts
    assert_command_fails "validate_path ../../../etc/passwd" "Should reject directory traversal"
    assert_command_fails "validate_path /path/../../../etc" "Should reject traversal in absolute path"
    
    # Test with ALLOW_ABSOLUTE_PATHS=false
    ALLOW_ABSOLUTE_PATHS=false assert_command_fails "validate_path /absolute/path" "Should reject absolute when not allowed"
    ALLOW_ABSOLUTE_PATHS=false assert_command_succeeds "validate_path relative/path" "Should accept relative when absolute not allowed"
}

# Test validate_url function
test_validate_url() {
    # Valid URLs
    assert_command_succeeds "validate_url https://github.com" "Should accept HTTPS URL"
    assert_command_succeeds "validate_url http://example.com" "Should accept HTTP URL"
    
    # Invalid URLs
    assert_command_fails "validate_url ftp://example.com" "Should reject FTP URL"
    assert_command_fails "validate_url github.com" "Should reject URL without protocol"
    assert_command_fails "validate_url javascript:alert(1)" "Should reject javascript protocol"
    
    # Test with allowlist
    URL_ALLOWLIST="github.com" assert_command_succeeds "validate_url https://github.com/user/repo" "Should accept allowlisted URL"
    URL_ALLOWLIST="github.com" assert_command_fails "validate_url https://gitlab.com/user/repo" "Should reject non-allowlisted URL"
}

# Test sanitize_input function
test_sanitize_input() {
    # Dangerous characters should be removed
    local result=$(sanitize_input 'test$variable')
    assert_equals "testvariable" "$result" "Should remove dollar sign"
    
    result=$(sanitize_input 'test`command`')
    assert_equals "testcommand" "$result" "Should remove backticks"
    
    result=$(sanitize_input 'test;rm -rf /')
    assert_equals "testrm -rf /" "$result" "Should remove semicolon"
    
    result=$(sanitize_input 'test|pipe')
    assert_equals "testpipe" "$result" "Should remove pipe"
    
    result=$(sanitize_input 'test > output')
    assert_equals "test  output" "$result" "Should remove redirects"
}

# Test validate_package_name function
test_validate_package_name() {
    # Valid package names
    assert_command_succeeds "validate_package_name git" "Should accept simple name"
    assert_command_succeeds "validate_package_name python@3.12" "Should accept versioned package"
    assert_command_succeeds "validate_package_name node-sass" "Should accept hyphenated name"
    assert_command_succeeds "validate_package_name ./local/package" "Should accept path-like name"
    
    # Invalid package names
    assert_command_fails "validate_package_name 'rm -rf /'" "Should reject command injection"
    assert_command_fails "validate_package_name 'package;ls'" "Should reject semicolon"
    assert_command_fails "validate_package_name 'package|grep'" "Should reject pipe"
}

# Test validate_email function
test_validate_email() {
    # Valid emails
    assert_command_succeeds "validate_email user@example.com" "Should accept valid email"
    assert_command_succeeds "validate_email user.name+tag@example.co.uk" "Should accept complex email"
    
    # Invalid emails
    assert_command_fails "validate_email notanemail" "Should reject non-email"
    assert_command_fails "validate_email @example.com" "Should reject missing local part"
    assert_command_fails "validate_email user@" "Should reject missing domain"
    assert_command_fails "validate_email user@.com" "Should reject invalid domain"
}

# Test validate_github_repo function
test_validate_github_repo() {
    # Valid repos
    assert_command_succeeds "validate_github_repo user/repo" "Should accept valid repo"
    assert_command_succeeds "validate_github_repo org-name/repo-name" "Should accept hyphenated names"
    assert_command_succeeds "validate_github_repo user/repo.git" "Should accept .git extension"
    
    # Invalid repos
    assert_command_fails "validate_github_repo justarepo" "Should reject missing slash"
    assert_command_fails "validate_github_repo /repo" "Should reject missing user"
    assert_command_fails "validate_github_repo user/" "Should reject missing repo"
    assert_command_fails "validate_github_repo user/repo/extra" "Should reject extra path"
}

# Test validate_version function
test_validate_version() {
    # Valid versions
    assert_command_succeeds "validate_version 1.2.3" "Should accept basic semver"
    assert_command_succeeds "validate_version v1.2.3" "Should accept v prefix"
    assert_command_succeeds "validate_version 1.2.3-alpha" "Should accept prerelease"
    assert_command_succeeds "validate_version 1.2.3-alpha.1" "Should accept complex prerelease"
    assert_command_succeeds "validate_version 1.2.3+build123" "Should accept build metadata"
    assert_command_succeeds "validate_version 1.2.3-alpha+build" "Should accept full semver"
    
    # Invalid versions
    assert_command_fails "validate_version 1.2" "Should reject incomplete version"
    assert_command_fails "validate_version 1.2.3.4" "Should reject too many parts"
    assert_command_fails "validate_version abc" "Should reject non-version string"
}

# Test validate_boolean function
test_validate_boolean() {
    # True values
    local result=$(validate_boolean true)
    assert_equals "true" "$result" "Should normalize 'true'"
    
    result=$(validate_boolean YES)
    assert_equals "true" "$result" "Should normalize 'YES'"
    
    result=$(validate_boolean 1)
    assert_equals "true" "$result" "Should normalize '1'"
    
    # False values
    result=$(validate_boolean false)
    assert_equals "false" "$result" "Should normalize 'false'"
    
    result=$(validate_boolean NO)
    assert_equals "false" "$result" "Should normalize 'NO'"
    
    result=$(validate_boolean 0)
    assert_equals "false" "$result" "Should normalize '0'"
    
    # Invalid values
    assert_command_fails "validate_boolean maybe" "Should reject invalid boolean"
}

# Test validate_disk_space function
test_validate_disk_space() {
    # This test may pass or fail depending on actual disk space
    # We'll skip it in CI environments
    if [[ "${CI:-false}" == "true" ]]; then
        skip_test "validate_disk_space" "Skipped in CI environment"
    else
        # Test with very small requirement (should pass)
        assert_command_succeeds "validate_disk_space 1 /" "Should pass with 1GB requirement"
        
        # Test with impossible requirement (should fail)
        assert_command_fails "validate_disk_space 999999 /" "Should fail with impossible requirement"
    fi
}

# Test validate_network function
test_validate_network() {
    # Skip in offline environments
    if ! ping -c 1 -t 1 8.8.8.8 &>/dev/null; then
        skip_test "validate_network" "No network connection available"
    else
        assert_command_succeeds "validate_network 8.8.8.8 1" "Should succeed with valid host"
        assert_command_fails "validate_network invalid.host.that.does.not.exist 1" "Should fail with invalid host"
    fi
}

# Test validate_macos_version function
test_validate_macos_version() {
    # Only test on macOS
    if [[ "$(uname)" != "Darwin" ]]; then
        skip_test "validate_macos_version" "Not running on macOS"
    else
        # Test with old version (should pass)
        assert_command_succeeds "validate_macos_version 10.0" "Should pass with old version requirement"
        
        # Test with future version (should fail)
        assert_command_fails "validate_macos_version 99.0" "Should fail with future version requirement"
    fi
}

# Test validate_xcode_tools function
test_validate_xcode_tools() {
    # Only test on macOS
    if [[ "$(uname)" != "Darwin" ]]; then
        skip_test "validate_xcode_tools" "Not running on macOS"
    else
        # This might pass or fail depending on system
        if xcode-select -p &>/dev/null; then
            assert_command_succeeds "validate_xcode_tools" "Should pass if Xcode tools installed"
        else
            assert_command_fails "validate_xcode_tools" "Should fail if Xcode tools not installed"
        fi
    fi
}

# Main test execution
main() {
    setup_test_env
    
    describe "Validator Functions"
    
    run_test "validate_number" test_validate_number
    run_test "validate_menu_choice" test_validate_menu_choice
    run_test "validate_path" test_validate_path
    run_test "validate_url" test_validate_url
    run_test "sanitize_input" test_sanitize_input
    run_test "validate_package_name" test_validate_package_name
    run_test "validate_email" test_validate_email
    run_test "validate_github_repo" test_validate_github_repo
    run_test "validate_version" test_validate_version
    run_test "validate_boolean" test_validate_boolean
    run_test "validate_disk_space" test_validate_disk_space
    run_test "validate_network" test_validate_network
    run_test "validate_macos_version" test_validate_macos_version
    run_test "validate_xcode_tools" test_validate_xcode_tools
    
    print_summary
}

# Run tests if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi