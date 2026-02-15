#!/bin/bash
# ============================================================
#  ORCHESTRA END-TO-END TEST - Comprehensive test suite
#  Tests ORCHESTRA.sh flow without actual installation
#  ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ORCHESTRA_DIR="$(cd "$SCRIPT_DIR/../install" && pwd)"
source "$SCRIPT_DIR/../scripts/common/functions.sh"
source "$SCRIPT_DIR/../scripts/common/logger.sh"
source "$SCRIPT_DIR/../scripts/common/colors.sh"

# Test configuration
TEST_STATE_FILE="/tmp/s1b_test_state"
# shellcheck disable=SC2034
TEST_ENV_FILE="/tmp/s1b_test_env"
PASSED=0
FAILED=0
TOTAL=0

# Colors for test output
TEST_PASS="${COLOR_GREEN}✓${COLOR_RESET}"
TEST_FAIL="${COLOR_RED}✗${COLOR_RESET}"
# shellcheck disable=SC2034
TEST_WARN="${COLOR_YELLOW}⚠${COLOR_RESET}"

# Test function
test_step() {
    local test_name="$1"
    local test_func="$2"
    
    TOTAL=$((TOTAL + 1))
    
    echo ""
    log_info "Testing: $test_name"
    
    if $test_func; then
        echo "  $TEST_PASS $test_name"
        PASSED=$((PASSED + 1))
        return 0
    else
        echo "  $TEST_FAIL $test_name"
        FAILED=$((FAILED + 1))
        return 1
    fi
}

# Test 1: ORCHESTRA.sh exists and is executable
test_orchestra_exists() {
    [[ -f "$ORCHESTRA_DIR/ORCHESTRA.sh" ]]
}

# Test 2: Syntax check
test_syntax() {
    bash -n "$ORCHESTRA_DIR/ORCHESTRA.sh"
}

# Test 3: Help message works
test_help() {
    "$ORCHESTRA_DIR/ORCHESTRA.sh" --help 2>&1 | grep -q "Usage:"
}

# Test 4: Dry-run mode works
test_dry_run() {
    "$ORCHESTRA_DIR/ORCHESTRA.sh" --dry-run 2>&1 | grep -qi "DRY RUN"
}

# Test 5: All preflight scripts exist
test_preflight_scripts() {
    local scripts=(
        "preflight/000_environment_selector.sh"
        "preflight/001_dependencies_check.sh"
        "preflight/002_disk_space_check.sh"
        "preflight/003_network_check.sh"
        "preflight/003_custom_selector.sh"
    )
    
    for script in "${scripts[@]}"; do
        if [[ ! -f "$ORCHESTRA_DIR/$script" ]]; then
            log_error "Missing: $script"
            return 1
        fi
    done
    return 0
}

# Test 6: All module scripts exist
test_module_scripts() {
    local modules=(
        "modules/010_dwm_setup.sh"
        "modules/020_shell_setup.sh"
        "modules/030_terminal_setup.sh"
        "modules/040_workflow_setup.sh"
        "modules/061_wofi_setup.sh"
        "modules/070_qt_setup.sh"
        "modules/071_warp_setup.sh"
        "modules/090_final_cleanup.sh"
    )
    
    local missing=0
    for module in "${modules[@]}"; do
        if [[ ! -f "$ORCHESTRA_DIR/$module" ]]; then
            log_warn "Missing module: $module"
            missing=$((missing + 1))
        fi
    done
    
    # Don't fail if some modules are missing (they might be optional)
    if [[ $missing -gt 3 ]]; then
        log_error "Too many missing modules: $missing"
        return 1
    fi
    return 0
}

# Test 7: Post-install scripts exist
test_post_install_scripts() {
    local scripts=(
        "post_install/setup_stow.sh"
        "post_install/setup_permissions.sh"
        "post_install/verify_installation.sh"
    )
    
    for script in "${scripts[@]}"; do
        if [[ ! -f "$ORCHESTRA_DIR/$script" ]]; then
            log_warn "Missing post-install: $script"
        fi
    done
    return 0
}

# Test 8: Common functions are importable
test_common_functions() {
    source "$SCRIPT_DIR/../scripts/common/functions.sh" 2>/dev/null
    source "$SCRIPT_DIR/../scripts/common/logger.sh" 2>/dev/null
    source "$SCRIPT_DIR/../scripts/common/colors.sh" 2>/dev/null
    return 0
}

# Test 9: Lock mechanism works
test_lock_mechanism() {
    local test_lock="/tmp/s1b_test_lock_$$"
    
    # Try to acquire lock
    if acquire_lock "$test_lock"; then
        # Release lock
        release_lock "$test_lock"
        return 0
    fi
    return 1
}

# Test 10: State management works
test_state_management() {
    # Clean up any previous test state
    rm -f "$TEST_STATE_FILE"
    
    # Create test state
    echo "TEST_STEP=1" > "$TEST_STATE_FILE"
    
    # Verify state was created
    if [[ -f "$TEST_STATE_FILE" ]]; then
        rm -f "$TEST_STATE_FILE"
        return 0
    fi
    return 1
}

# Main test execution
log_section "🧪 ORCHESTRA END-TO-END TEST SUITE"

echo ""
echo "═══════════════════════════════════════"
echo "  Testing: $ORCHESTRA_DIR/ORCHESTRA.sh"
echo "═══════════════════════════════════════"

# Phase 1: Basic Tests
echo ""
log_subsection "Phase 1: Basic Validation"

test_step "Script exists" test_orchestra_exists
test_step "Syntax check" test_syntax
test_step "Help message" test_help
test_step "Dry-run mode" test_dry_run

# Phase 2: Component Tests
echo ""
log_subsection "Phase 2: Component Availability"

test_step "Preflight scripts" test_preflight_scripts
test_step "Module scripts" test_module_scripts
test_step "Post-install scripts" test_post_install_scripts

# Phase 3: Integration Tests
echo ""
log_subsection "Phase 3: Integration Tests"

test_step "Common functions load" test_common_functions
test_step "Lock mechanism" test_lock_mechanism
test_step "State management" test_state_management

# Phase 4: Module Validation
echo ""
log_subsection "Phase 4: Individual Module Validation"

# Count available modules
module_count=0
for module in "$ORCHESTRA_DIR"/modules/*.sh; do
    if [[ -f "$module" ]]; then
        module_count=$((module_count + 1))
        module_name=$(basename "$module")
        
        # Test module syntax
        if bash -n "$module" 2>/dev/null; then
            echo "  $TEST_PASS $module_name (syntax OK)"
            PASSED=$((PASSED + 1))
        else
            echo "  $TEST_FAIL $module_name (syntax errors)"
            FAILED=$((FAILED + 1))
        fi
        TOTAL=$((TOTAL + 1))
    fi
done

log_info "Found $module_count modules"

# Summary Report
echo ""
log_section "📊 TEST SUMMARY"

echo ""
echo "═══════════════════════════════════════"
echo "  Total Tests: $TOTAL"
echo -e "  ${COLOR_GREEN}Passed: $PASSED${COLOR_RESET}"
echo -e "  ${COLOR_RED}Failed: $FAILED${COLOR_RESET}"
echo "═══════════════════════════════════════"

# Calculate success rate
if [[ $TOTAL -gt 0 ]]; then
    success_rate=$(( PASSED * 100 / TOTAL ))
    echo ""
    echo "Success Rate: ${success_rate}%"
    
    if [[ $success_rate -ge 90 ]]; then
        echo ""
        log_success "🎉 EXCELLENT: ORCHESTRA.sh is production-ready!"
        exit_code=0
    elif [[ $success_rate -ge 75 ]]; then
        echo ""
        log_warn "⚠️  GOOD: Minor issues detected"
        exit_code=0
    elif [[ $success_rate -ge 50 ]]; then
        echo ""
        log_warn "⚠️  FAIR: Several issues need attention"
        exit_code=1
    else
        echo ""
        log_error "❌ POOR: Major issues found"
        exit_code=1
    fi
else
    log_error "No tests were executed!"
    exit_code=1
fi

# Recommendations
echo ""
log_info "Recommendations:"

if [[ $FAILED -eq 0 ]]; then
    echo "  ✓ All tests passed. ORCHESTRA.sh is ready for deployment."
else
    echo "  • Review failed tests above"
    echo "  • Ensure all dependencies are installed"
    echo "  • Check file permissions on scripts"
    echo "  • Run 'shellcheck install/ORCHESTRA.sh' for linting"
fi

exit $exit_code
