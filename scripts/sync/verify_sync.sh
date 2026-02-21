#!/bin/bash
# ============================================================
#  VERIFY SYNC - Verify sync was successful
#  ============================================================

set -euo pipefail

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/functions.sh"
source "$SCRIPT_DIR/../common/logger.sh"
source "$SCRIPT_DIR/../common/colors.sh"

verify_dwm_sync() {
    log_info "Verifying DWM sync..."
    
    local dwm_config="$HOME/.config/dwm/config.h"
    local s1b_config="$HOME/Desktop/S1Bs1stem/configs/dwm/config.h"
    
    if [ -f "$dwm_config" ]; then
        log_success "DWM config found: $dwm_config"
    else
        log_warn "DWM config not found (may not be from dotfiles-s1b)"
    fi
    
    if [ -f "$s1b_config" ]; then
        log_info "S1Bs1stem DWM config: $s1b_config"
    else
        log_info "S1Bs1stem DWM config not found"
    fi
}

verify_waybar_sync() {
    log_info "Verifying Waybar sync..."
    
    local waybar_config="$HOME/.config/waybar/config"
    
    if [ -f "$waybar_config" ]; then
        log_success "Waybar config found: $waybar_config"
    else
        log_warn "Waybar config not found"
    fi
}

verify_kitty_sync() {
    log_info "Verifying Kitty sync..."
    
    local kitty_config="$HOME/.config/kitty/kitty.conf"
    
    if [ -f "$kitty_config" ]; then
        log_success "Kitty config found: $kitty_config"
    else
        log_warn "Kitty config not found"
    fi
}

verify_workflows_sync() {
    log_info "Verifying workflows sync..."
    
    local workflows_dir="$HOME/Desktop/S1Bs1stem/workflow"
    
    if [ -d "$workflows_dir" ]; then
        local count
        count=$(ls -1 "$workflows_dir/profiles" 2>/dev/null | wc -l)
        log_info "Found $count workflow profiles"
    else
        log_warn "Workflows directory not found"
    fi
}

# Generate sync report
generate_report() {
    # shellcheck disable=SC2155
    local report_file="$HOME/.s1b_sync_report_$(date +%Y%m%d_%H%M%S).txt"
    
    cat > "$report_file" << EOF
S1Bs1stem Sync Verification Report
=========================================
Date: $(date)
User: $(whoami)
Host: $(hostname)

Environment Info:
EOF

    # Add environment info
    source "$SCRIPT_DIR/../detection/detect_env.sh"
    env_info=$(get_env_full)
    echo "$env_info" >> "$report_file"
    
    echo "" >> "$report_file"
    echo "DWM Sync:" >> "$report_file"
    verify_dwm_sync 2>&1 | tee -a "$report_file"
    
    echo "" >> "$report_file"
    echo "Waybar Sync:" >> "$report_file"
    verify_waybar_sync 2>&1 | tee -a "$report_file"
    
    echo "" >> "$report_file"
    echo "Kitty Sync:" >> "$report_file"
    verify_kitty_sync 2>&1 | tee -a "$report_file"
    
    echo "" >> "$report_file"
    echo "Workflows Sync:" >> "$report_file"
    verify_workflows_sync 2>&1 | tee -a "$report_file"
    
    echo "" >> "$report_file"
    echo "========================================="
    
    log_success "Report saved: $report_file"
    echo "$report_file"
}

main() {
    local action="${1:-all}"
    
    case "$action" in
        all|full|report)
            generate_report
            ;;
        dwm)
            verify_dwm_sync
            ;;
        waybar)
            verify_waybar_sync
            ;;
        kitty)
            verify_kitty_sync
            ;;
        workflows)
            verify_workflows_sync
            ;;
        *)
            log_error "Invalid action: $action"
            echo "Usage: $0 [all|dwm|waybar|kitty|workflows|report]"
            exit 1
            ;;
    esac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi

export -f verify_dwm_sync
export -f verify_waybar_sync
export -f verify_kitty_sync
export -f verify_workflows_sync
export -f generate_report
