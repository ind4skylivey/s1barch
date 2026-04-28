#!/bin/bash
# ============================================================
#  S1barch Post-Install Configuration
#  Change profile, environment, or theme after installation
#  ============================================================

set -euo pipefail

# --- COLORS ---
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly CYAN='\033[0;36m'
readonly MAUVE='\033[0;35m'
readonly BOLD='\033[1m'
readonly RESET='\033[0m'

# --- CONSTANTS ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
S1B_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# --- FUNCTIONS ---
log_info() { echo -e "${CYAN}[INFO]${RESET} $1"; }
log_success() { echo -e "${GREEN}[OK]${RESET} $1"; }
log_error() { echo -e "${RED}[ERROR]${RESET} $1"; }
log_warning() { echo -e "${YELLOW}[WARN]${RESET} $1"; }

show_banner() {
    echo ""
    echo -e "${MAUVE}${BOLD}╔══════════════════════════════════════════════════════╗${RESET}"
    echo -e "${MAUVE}${BOLD}║       ⚙️  S1barch Post-Install Configuration         ║${RESET}"
    echo -e "${MAUVE}${BOLD}╚══════════════════════════════════════════════════════╝${RESET}"
    echo ""
}

show_menu() {
    echo -e "${CYAN}Current configuration:${RESET}"
    echo "  Profile: ${GREEN}$USER_PROFILE${RESET}"
    echo "  Environment: ${GREEN}$INSTALL_ENVIRONMENT${RESET}"
    echo ""
    echo -e "${CYAN}Available options:${RESET}"
    echo "  1. Change user profile"
    echo "  2. Change environment (DWM ↔ Wayland)"
    echo "  3. View current status"
    echo "  4. Re-run installer"
    echo "  5. Open control center (if installed)"
    echo "  q. Quit"
    echo ""
    echo -n "Select option: "
}

change_profile() {
    echo ""
    log_info "Changing user profile..."
    source "$SCRIPT_DIR/../preflight/004_user_profile_selector.sh"
    
    if [ -f "$SCRIPT_DIR/../.user_profile" ]; then
        log_success "Profile changed to: $USER_PROFILE"
        log_info "Run installer again to apply changes"
    else
        log_error "Failed to change profile"
    fi
}

change_environment() {
    echo ""
    log_info "Changing environment..."
    source "$SCRIPT_DIR/../preflight/000_environment_selector.sh"
    
    if [ -f "$SCRIPT_DIR/../.env_selection" ]; then
        log_success "Environment changed to: $INSTALL_ENVIRONMENT"
        log_info "Run installer again to apply changes"
    else
        log_error "Failed to change environment"
    fi
}

show_status() {
    echo ""
    log_info "Current S1barch Status:"
    echo ""
    
    if [ -f "$HOME/.s1b_user_profile" ]; then
        echo -e "  ${CYAN}Profile:${RESET} $(cat "$HOME/.s1b_user_profile")"
    else
        echo -e "  ${CYAN}Profile:${RESET} Not set"
    fi
    
    if [ -f "$HOME/.s1b_environment" ]; then
        echo -e "  ${CYAN}Environment:${RESET} $(cat "$HOME/.s1b_environment")"
    else
        echo -e "  ${CYAN}Environment:${RESET} Not set"
    fi
    
    if [ -d "$S1B_ROOT/workflow" ]; then
        echo -e "  ${CYAN}Workflows available:${RESET}"
        ls "$S1B_ROOT/workflow/profiles/" 2>/dev/null | sed 's/^/    - /' || true
    fi
    
    echo ""
}

rerun_installer() {
    log_info "Re-running installer..."
    cd "$S1B_ROOT"
    bash install/ORCHESTRA.sh
}

open_control_center() {
    if [ -f "$S1B_ROOT/ui/launch.sh" ]; then
        log_info "Launching control center..."
        bash "$S1B_ROOT/ui/launch.sh"
    elif [ -f "$S1B_ROOT/ui/s1b_control_center.py" ]; then
        log_info "Launching control center..."
        python3 "$S1B_ROOT/ui/s1b_control_center.py"
    else
        log_warning "Control center not found"
    fi
}

# --- MAIN ---
main() {
    show_banner
    
    # Load current configuration if exists
    if [ -f "$HOME/.s1b_user_profile" ]; then
        USER_PROFILE=$(cat "$HOME/.s1b_user_profile")
    else
        USER_PROFILE="Not set"
    fi
    
    if [ -f "$HOME/.s1b_environment" ]; then
        INSTALL_ENVIRONMENT=$(cat "$HOME/.s1b_environment")
    else
        INSTALL_ENVIRONMENT="Not set"
    fi
    
    while true; do
        show_menu
        read -r choice
        
        case "$choice" in
            1) change_profile ;;
            2) change_environment ;;
            3) show_status ;;
            4) rerun_installer ;;
            5) open_control_center ;;
            q|Q) 
                echo ""
                log_info "Goodbye!"
                exit 0
                ;;
            *) 
                log_error "Invalid option"
                ;;
        esac
        
        echo ""
    done
}

main "$@"