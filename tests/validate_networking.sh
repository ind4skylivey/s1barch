#!/bin/bash
# ============================================================
#  NETWORK VALIDATION - Test all networking scripts
#  Dependencies: All networking scripts must be installed
#  ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/functions.sh"
source "$SCRIPT_DIR/../common/logger.sh"
source "$SCRIPT_DIR/../common/colors.sh"

# Test results
PASSED=0
FAILED=0
TOTAL=0

# Test function
test_script() {
    local script_name="$1"
    local script_path="$SCRIPT_DIR/../networking/$script_name"
    local test_desc="$2"
    
    TOTAL=$((TOTAL + 1))
    
    echo ""
    log_info "Testing: $script_name"
    echo "  Description: $test_desc"
    
    if [ ! -f "$script_path" ]; then
        log_error "  Script not found: $script_path"
        FAILED=$((FAILED + 1))
        return 1
    fi
    
    # Test 1: Check syntax
    if bash -n "$script_path" 2>/dev/null; then
        log_success "  ✓ Syntax check passed"
    else
        log_error "  ✗ Syntax errors detected"
        FAILED=$((FAILED + 1))
        return 1
    fi
    
    # Test 2: Check for required functions
    if grep -q "source.*functions.sh" "$script_path"; then
        log_success "  ✓ Imports common functions"
    else
        log_warn "  ⚠ Missing common functions import"
    fi
    
    if grep -q "source.*logger.sh" "$script_path"; then
        log_success "  ✓ Imports logger"
    else
        log_warn "  ⚠ Missing logger import"
    fi
    
    # Test 3: Check for set -euo pipefail
    if grep -q "set -euo pipefail" "$script_path"; then
        log_success "  ✓ Has error handling (set -euo pipefail)"
    else
        log_warn "  ⚠ Missing strict error handling"
    fi
    
    PASSED=$((PASSED + 1))
}

log_section "Networking Scripts Validation"

# Test all networking scripts
test_script "network_status.sh" "Show network connection status"
test_script "dns_switch.sh" "Switch between DNS providers"
test_script "vpn_connect.sh" "Connect to VPN"
test_script "wifi_toggle.sh" "Toggle WiFi ON/OFF"
test_script "tailscale_toggle.sh" "Toggle Tailscale"
test_script "network_meter.sh" "Network bandwidth meter"
test_script "iphone_vnc.sh" "iPhone VNC connection"

# Summary
echo ""
echo "═════════════════════════════════════"
echo -e "${COLOR_BOLD}VALIDATION SUMMARY${COLOR_RESET}"
echo "═════════════════════════════════════"
echo ""
echo "Total Tests: $TOTAL"
echo -e "Passed: ${COLOR_GREEN}$PASSED${COLOR_RESET}"
echo -e "Failed: ${COLOR_RED}$FAILED${COLOR_RESET}"

if [ $FAILED -eq 0 ]; then
    log_success "All networking scripts validated successfully!"
    exit 0
else
    log_error "Some tests failed. Please review the output above."
    exit 1
fi
