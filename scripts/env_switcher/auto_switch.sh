#!/bin/bash
# ============================================================
#  AUTO SWITCH - Auto-switch environment based on detection
#  Usage: bash ~/Desktop/S1Bs1stem/scripts/env_switcher/auto_switch.sh
#  ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/functions.sh"
source "$SCRIPT_DIR/../common/logger.sh"
source "$SCRIPT_DIR/../common/colors.sh"

# Detectar entorno actual
CURRENT_ENV_FILE="$HOME/Desktop/S1Bs1stem/config/current_env.yaml"

detect_and_switch() {
    local detected_env
    detected_env=$(bash "$SCRIPT_DIR/../detection/detect_env.sh" | head -1)
    
    case "$detected_env" in
        dwm:x11)
            log_info "Detected DWM (X11), staying on DWM"
            echo "dwm:x11"
            ;;
        hyprland|wayland)
            log_info "Detected Wayland/Waybar, staying on Wayland"
            echo "wayland"
            ;;
        gnom|kde)
            log_info "Detected $detected_env, not switching"
            echo "current"
            ;;
        *)
            log_warn "Unknown environment: $detected_env"
            echo "unknown"
            ;;
    esac
}

# Verificar si hay cambio necesario
check_needs_switch() {
    local detected_env
    detected_env=$(detect_and_switch)
    local current_env
    
    if [ ! -f "$CURRENT_ENV_FILE" ]; then
        return 0  # No hay config anterior, no hay cambio necesario
    fi
    
    current_env=$(cat "$CURRENT_ENV_FILE" | grep "^current:" | cut -d: -f2 | tr -d ' ')
    
    if [ "$current_env" != "$detected_env" ]; then
        log_info "Environment mismatch detected: current=$current_env vs detected=$detected_env"
        return 1  # Necesita cambio
    else
        log_info "Environment already correct: $current_env"
        return 0 # No cambio necesario
    fi
}

# Ejecutar cambio si es necesario
auto_switch() {
    if check_needs_switch; then
        local detected_env
        detected_env=$(detect_and_switch)
        
        case "$detected_env" in
            dwm:x11)
                log_info "Auto-switching to DWM..."
                bash "$SCRIPT_DIR/to_dwm.sh"
                ;;
            hyprland|wayland)
                log_info "Auto-switching to Wayland..."
                bash "$SCRIPT_DIR/to_wayland.sh"
                ;;
            *)
                log_warn "No auto-switch needed for: $detected_env"
                ;;
        esac
    else
        log_success "Environment is correct, no switch needed"
    fi
}

# Main
main() {
    local action="${1:-check}"
    
    case "$action" in
        detect)
            detect_and_switch
            ;;
        check|verify)
            check_needs_switch
            ;;
        switch|execute)
            auto_switch
            ;;
        *)
            log_error "Invalid action: $action"
            echo "Usage: $0 [detect|check|switch]"
            exit 1
            ;;
    esac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
