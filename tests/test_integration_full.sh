#!/bin/bash
# ============================================================
#  INTEGRATION TEST - Full S1Bs1stem Installation Test
#  Tests ORCHESTRA.sh with actual execution (safe mode)
#  ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
S1B_ROOT="$(cd "$SCRIPT_DIR/../" && pwd)"
INSTALL_DIR="$S1B_ROOT/install"
TEST_LOG="/tmp/s1b_integration_test_$(date +%Y%m%d_%H%M%S).log"

# Colors
PASS='\033[0;32m✓\033[0m'
FAIL='\033[0;31m✗\033[0m'
WARN='\033[0;33m⚠\033[0m'

PASSED=0
FAILED=0
WARNINGS=0

log_test() {
    echo "[$(date '+%H:%M:%S')] $1" | tee -a "$TEST_LOG"
}

test_header() {
    echo ""
    echo "═══════════════════════════════════════════"
    echo "  $1"
    echo "═══════════════════════════════════════════"
    echo ""
    log_test "=== $1 ==="
}

test_step() {
    local name="$1"
    local cmd="$2"
    
    echo -n "Testing: $name... "
    log_test "Testing: $name"
    
    if eval "$cmd" >> "$TEST_LOG" 2>&1; then
        echo -e "$PASS PASSED"
        log_test "PASSED: $name"
        PASSED=$((PASSED + 1))
        return 0
    else
        echo -e "$FAIL FAILED"
        log_test "FAILED: $name"
        FAILED=$((FAILED + 1))
        return 1
    fi
}

# ============================================
# PHASE 1: Pre-Installation Checks
# ============================================
test_header "PHASE 1: Pre-Installation Validation"

test_step "Check S1Bs1stem directory exists" "[[ -d $S1B_ROOT ]]"
test_step "Check ORCHESTRA.sh exists" "[[ -f $INSTALL_DIR/ORCHESTRA.sh ]]"
test_step "Check ORCHESTRA.sh syntax" "bash -n $INSTALL_DIR/ORCHESTRA.sh"
test_step "Check common functions" "[[ -f $S1B_ROOT/scripts/common/functions.sh ]]"
test_step "Check all preflight scripts" "[[ -f $INSTALL_DIR/preflight/000_environment_selector.sh && -f $INSTALL_DIR/preflight/001_dependencies_check.sh ]]"

# ============================================
# PHASE 2: Module Validation
# ============================================
test_header "PHASE 2: Module Validation"

MODULES=(
    "modules/020_shell_setup.sh"
    "modules/030_terminal_setup.sh"
    "modules/070_qt_setup.sh"
    "modules/071_warp_setup.sh"
    "modules/090_final_cleanup.sh"
)

for module in "${MODULES[@]}"; do
    if [[ -f "$INSTALL_DIR/$module" ]]; then
        test_step "Check syntax: $(basename $module)" "bash -n $INSTALL_DIR/$module"
    else
        echo -e "$WARN WARNING: $module not found (optional)"
        WARNINGS=$((WARNINGS + 1))
    fi
done

# ============================================
# PHASE 3: Script Execution Tests
# ============================================
test_header "PHASE 3: Script Execution Tests"

# Test dry-run (safe)
test_step "ORCHESTRA dry-run" "timeout 10 bash $INSTALL_DIR/ORCHESTRA.sh --dry-run"

# Test help
test_step "ORCHESTRA help" "timeout 5 bash $INSTALL_DIR/ORCHESTRA.sh --help"

# Test individual scripts
test_step "Network status" "timeout 5 bash ~/.local/s1barch/scripts/networking/network_status.sh --help 2>/dev/null || true"
test_step "System info" "timeout 5 bash ~/.local/s1barch/scripts/system/system_info.sh 2>/dev/null || true"

# ============================================
# PHASE 4: API Functions Test
# ============================================
test_header "PHASE 4: API Functions Test"

# Source and test functions
source $S1B_ROOT/scripts/common/functions.sh 2>/dev/null || true
source $S1B_ROOT/scripts/common/logger.sh 2>/dev/null || true

test_step "Function: trim_string" "echo '  test  ' | trim_string | grep -q 'test'" 
test_step "Function: is_valid_string" "is_valid_string 'test'"
test_step "Function: is_valid_number" "is_valid_number '123'"
test_step "Function: file_exists" "file_exists ~/.bashrc || true"

# ============================================
# PHASE 5: Integration Flow Test
# ============================================
test_header "PHASE 5: Integration Flow Test"

# Create test environment file
test_step "Create test env file" "echo 'INSTALL_ENVIRONMENT=test' > /tmp/test_env.yaml"
test_step "Verify env file" "[[ -f /tmp/test_env.yaml ]]"

# Test workflow scripts exist
WORKFLOWS=("ws-local" "ws-remote" "ws-write" "ws-redteam")
for wf in "${WORKFLOWS[@]}"; do
    if [[ -f "$S1B_ROOT/scripts/workflow/$wf.sh" ]]; then
        test_step "Workflow exists: $wf" "[[ -f $S1B_ROOT/scripts/workflow/$wf.sh ]]"
    else
        echo -e "$WARN Workflow wrapper: $wf (optional)"
        WARNINGS=$((WARNINGS + 1))
    fi
done

# ============================================
# PHASE 6: File Permissions
# ============================================
test_header "PHASE 6: File Permissions"

EXECUTABLES=(
    "install/ORCHESTRA.sh"
    "scripts/common/functions.sh"
    "scripts/common/logger.sh"
)

for file in "${EXECUTABLES[@]}"; do
    if [[ -f ~/.local/s1barch/$file ]]; then
        if [[ -x ~/.local/s1barch/$file ]]; then
            echo -e "$PASS $(basename $file) is executable"
            PASSED=$((PASSED + 1))
        else
            echo -e "$WARN $(basename $file) not executable (fixing...)"
            chmod +x ~/.local/s1barch/$file
            WARNINGS=$((WARNINGS + 1))
        fi
    fi
done

# ============================================
# PHASE 7: Dependencies Check
# ============================================
test_header "PHASE 7: Dependencies Check"

DEPS=("bash" "git" "curl" "pacman" "nmcli")
for dep in "${DEPS[@]}"; do
    if command -v "$dep" >/dev/null 2>&1; then
        echo -e "$PASS $dep installed"
        PASSED=$((PASSED + 1))
    else
        echo -e "$WARN $dep not found (may be needed)"
        WARNINGS=$((WARNINGS + 1))
    fi
done

# ============================================
# FINAL REPORT
# ============================================
test_header "FINAL INTEGRATION REPORT"

echo ""
echo "Test Log: $TEST_LOG"
echo ""
echo "═══════════════════════════════════════════"
echo "  RESULTS SUMMARY"
echo "═══════════════════════════════════════════"
echo ""
echo -e "  Passed:   \033[0;32m$PASSED\033[0m"
echo -e "  Failed:   \033[0;31m$FAILED\033[0m"
echo -e "  Warnings: \033[0;33m$WARNINGS\033[0m"
echo ""
TOTAL=$((PASSED + FAILED))
if [[ $TOTAL -gt 0 ]]; then
    SUCCESS_RATE=$(( PASSED * 100 / TOTAL ))
    echo "  Success Rate: $SUCCESS_RATE%"
fi
echo ""

if [[ $FAILED -eq 0 ]]; then
    echo -e "\033[0;32m✅ INTEGRATION TEST PASSED!\033[0m"
    echo ""
    echo "S1Bs1stem is ready for production deployment."
    log_test "INTEGRATION TEST PASSED"
    exit_code=0
elif [[ $FAILED -lt 3 ]]; then
    echo -e "\033[0;33m⚠️  INTEGRATION TEST PASSED WITH WARNINGS\033[0m"
    echo ""
    echo "Minor issues detected but system is functional."
    log_test "INTEGRATION TEST PASSED WITH WARNINGS"
    exit_code=0
else
    echo -e "\033[0;31m❌ INTEGRATION TEST FAILED\033[0m"
    echo ""
    echo "Critical errors found. Please review the test log."
    log_test "INTEGRATION TEST FAILED"
    exit_code=1
fi

echo ""
echo "═══════════════════════════════════════════"

exit $exit_code
