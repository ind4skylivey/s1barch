#!/bin/bash
# ============================================================
#  S1Bs1stem - ORCHESTRATOR MASTER SCRIPT (v1.5.0)
#  ============================================================
#  Inspired by: S1B ORCHESTRA.sh
#  Purpose: Coordinated installation and configuration with environment selection
#  Author: S1B System
#  License: MIT
#  Version: 1.5.0
#  ============================================================

set -euo pipefail

# --- CONSTANTS ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR

# --- SOURCE COMMON FUNCTIONS ---
source "$SCRIPT_DIR/../scripts/common/functions.sh"
source "$SCRIPT_DIR/../scripts/common/logger.sh"
source "$SCRIPT_DIR/../scripts/common/colors.sh"

# --- ADDITIONAL CONSTANTS ---
# Note: S1B_ROOT, LOG_DIR, LOG_FILE are already set by common libraries
readonly STATE_FILE="$HOME/.s1b_install_state"
INSTALL_LOG_FILE="$HOME/.s1b_install_$(date +%Y%m%d_%H%M%S).log"
readonly INSTALL_LOG_FILE
readonly LOCK_FILE="/tmp/s1b_orchestra.lock"
BACKUP_DIR="$HOME/.s1b_backup_$(date +%Y%m%d_%H%M%S)"
readonly BACKUP_DIR
readonly ENV_SELECTION_FILE="$SCRIPT_DIR/.env_selection"
readonly CUSTOM_SELECTION_FILE="$SCRIPT_DIR/.custom_selection"

# --- HELPERS ---
trim() {
    local var="$*"
    var="${var#"${var%%[![:space:]]*}"}"
    var="${var%"${var##*[![:space:]]}"}"
    printf '%s' "$var"
}

get_script_description() {
    local filename="$1"
    local desc
    desc=$(sed -n '2s/^#[[:space:]]*//p' "$SCRIPT_DIR/$filename" 2>/dev/null)
    if [[ -z "$desc" ]]; then
        desc=$(sed -n '3s/^#[[:space:]]*//p' "$SCRIPT_DIR/$filename" 2>/dev/null)
    fi
    printf "%s" "${desc:-No description available}"
}

preflight_check() {
    log_info "Performing pre-flight validation..."
    
    local missing=0
    local files_to_check=(
        "preflight/000_environment_selector.sh"
        "preflight/001_dependencies_check.sh"
        "preflight/002_disk_space_check.sh"
        "preflight/003_network_check.sh"
        "preflight/003_custom_selector.sh"
    )
    
    for filename in "${files_to_check[@]}"; do
        if [[ ! -f "$SCRIPT_DIR/$filename" ]]; then
            log_error "Missing file: ${filename}"
            ((missing++))
        fi
    done
    
    if ((missing > 0)); then
        log_error "$missing preflight script(s) are missing"
        read -r -p "Continue anyway? [y/N]: " _choice
        if [[ "${_choice,,}" != "y" ]]; then
            log_error "Aborting execution."
            exit 1
        fi
    else
        log_success "All preflight scripts verified."
    fi
}

# --- SUDO MANAGEMENT ---
SUDO_PID=""

init_sudo() {
    log_info "Sudo privileges required. Please authenticate."
    if ! sudo -v; then
        log_error "Sudo authentication failed."
        exit 1
    fi
    
    (while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null) &
    SUDO_PID=$!
    disown "$SUDO_PID"
}

cleanup_sudo() {
    if [ -n "$SUDO_PID" ]; then
        kill "$SUDO_PID" 2>/dev/null || true
    fi
}

# --- ARGUMENT HANDLING ---
show_help() {
    cat << EOF
${COLOR_MAuve}${COLOR_BOLD}S1Bs1stem Orchestrator v1.5.0${COLOR_RESET}

${COLOR_TEXT}Usage:${COLOR_RESET} $0 [OPTIONS]

${COLOR_TEXT}Options:${COLOR_RESET}
    ${COLOR_GREEN}--help, -h${COLOR_RESET}       Show this help message and exit
    ${COLOR_GREEN}--dry-run, -d${COLOR_RESET}    Preview execution plan without running anything
    ${COLOR_RESET}--reset          Clear progress state and start fresh
    ${COLOR_GREEN}--interactive, -i${COLOR_RESET} Run interactively (prompt before each script)
    ${COLOR_GREEN}--verbose, -v${COLOR_RESET}    Enable verbose output

${COLOR_TEXT}Description:${COLOR_RESET}
    This script orchestrates installation and configuration
    of S1Bs1stem system. You can choose to install:
    
    - Full Installation (Wayland + DWM/X11)
    - Wayland Only (Waybar + Wofi)
    - DWM/X11 Only (DWM + Picom + Rofi)
    - Custom Installation (select specific modules)

${COLOR_TEXT}Examples:${COLOR_RESET}
    $0                  # Normal run with environment selection
    $0 --dry-run       # Preview what would be executed
    $0 --reset         # Reset progress and start over
    $0 --interactive    # Run with prompts before each script

${COLOR_TEXT}Note:${COLOR_RESET} This script is designed to be run multiple times.
If you think something wasn't done right, you can run it again.
It will NOT re-download everything, but instead only download/configure
what might have failed the first time.
EOF
    exit 0
}

DRY_RUN=false
INTERACTIVE_MODE=false
VERBOSE=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --help|-h)
            show_help
            ;;
        --dry-run|-d)
            DRY_RUN=true
            shift
            ;;
        --reset)
            rm -f "$STATE_FILE" "$ENV_SELECTION_FILE" "$CUSTOM_SELECTION_FILE"
            log_info "State file reset. Starting fresh."
            shift
            ;;
        --interactive|-i)
            # shellcheck disable=SC2034
            INTERACTIVE_MODE=true
            shift
            ;;
        --verbose|-v)
            # shellcheck disable=SC2034
            VERBOSE=true
            set -x
            shift
            ;;
        *)
            log_error "Unknown option: $1"
            show_help
            ;;
    esac
done

# --- DRY RUN MODE ---
if [ "$DRY_RUN" = true ]; then
    echo ""
    box_title "DRY RUN MODE"
    echo ""
    log_info "Script directory: $SCRIPT_DIR"
    log_info "State file: $STATE_FILE"
    log_info "Selection file: $ENV_SELECTION_FILE"
    echo ""
    log_info "Available modules:"
    echo ""
    
    echo "  Environment-Specific:"
    echo "    - DWM/X11: 050_dwm_setup.sh, 051_picom_setup.sh, 052_rofi_setup.sh"
    echo "    - Wayland:  060_waybar_setup.sh, 061_wofi_setup.sh"
    echo ""
    echo "  Shared Modules:"
    echo "    - 070_qt_setup.sh (Qt Theme Engine)"
    echo "    - 071_warp_setup.sh (Warp Terminal)"
    echo "    - 072_browser_setup.sh (Zen Browser)"
    echo "    - 073_editor_setup.sh (Neovim, Doom Emacs, etc.)"
    echo "    - 074_filemanager_setup.sh (Yazi, PCManFM-Qt)"
    echo "    - 075_multiplexer_setup.sh (Tmux, Zellij)"
    echo "    - 076_monitor_setup.sh (BTop, Cava, Fastfetch, Materiatrack)"
    echo "    - 080_workflow_setup.sh (Eco-Workflow)"
    echo ""
    
    log_info "No changes will be made."
    log_info "Run without --dry-run to execute installation."
    exit 0
fi

# --- MAIN EXECUTION ---
main() {
    # Check if running as root (should not happen)
    if [[ $EUID -eq 0 ]]; then
        log_error "This script must NOT be run as root!"
        log_error "The script handles sudo privileges internally."
        exit 1
    fi
    
    # Acquire lock
    acquire_lock "$LOCK_FILE"
    # shellcheck disable=SC2064
    trap "release_lock '$LOCK_FILE'" EXIT
    
    # Setup logging
    log_info "🚀 S1Bs1stem Orchestrator v1.5.0 Starting..."
    log_info "Install log: $INSTALL_LOG_FILE"
    log_info "System log: $LOG_FILE"
    
    # Pre-flight check
    preflight_check
    
    # --- STEP 1: Environment Selection ---
    log_info "Step 1/6: Environment Selection"
    source "$SCRIPT_DIR/preflight/000_environment_selector.sh"
    
    # Read selection
    if [ -f "$ENV_SELECTION_FILE" ]; then
        # shellcheck source=/dev/null
        source "$ENV_SELECTION_FILE"
        log_info "Environment: $INSTALL_ENVIRONMENT ($INSTALL_MODE)"
    else
        log_error "Environment selection failed!"
        exit 1
    fi
    
    # --- STEP 2: User Profile Selection ---
    log_info "Step 2/6: User Profile Selection"
    source "$SCRIPT_DIR/preflight/004_user_profile_selector.sh"
    
    # Read profile selection
    if [ -f "$SCRIPT_DIR/.user_profile" ]; then
        # shellcheck source=/dev/null
        source "$SCRIPT_DIR/.user_profile"
        log_info "User Profile: $USER_PROFILE"
    else
        log_error "User profile selection failed!"
        exit 1
    fi
    
    # --- STEP 3: Base Modules (ALWAYS EXECUTE) ---
    log_info "Step 3/6: Installing Base Modules..."
    source "$SCRIPT_DIR/preflight/001_dependencies_check.sh"
    source "$SCRIPT_DIR/preflight/002_disk_space_check.sh"
    source "$SCRIPT_DIR/preflight/003_network_check.sh"
    
    source "$SCRIPT_DIR/modules/020_shell_setup.sh"
    source "$SCRIPT_DIR/modules/030_terminal_setup.sh"
    
    # --- STEP 4: Environment-Specific Modules ---
    log_info "Step 4/6: Installing Environment-Specific Modules..."
    
    if [ "$INSTALL_MODE" = "custom" ]; then
        # Custom mode: load individual selections
        log_info "Processing custom module selection..."
        source "$SCRIPT_DIR/preflight/003_custom_selector.sh"
        
        # Read and execute selected modules
        if [ -f "$CUSTOM_SELECTION_FILE" ]; then
            log_info "Executing selected modules..."
            while IFS= read -r module; do
                case "$module" in
                    shell)
                        source "$SCRIPT_DIR/modules/020_shell_setup.sh"
                        ;;
                    terminal)
                        source "$SCRIPT_DIR/modules/030_terminal_setup.sh"
                        ;;
                    dwm)
                        source "$SCRIPT_DIR/modules/010_dwm_setup.sh"
                        ;;
                    picom)
                        log_info "Picom setup included in DWM module"
                        ;;
                    rofi)
                        source "$SCRIPT_DIR/../scripts/rofi/setup.sh"
                        ;;
                    waybar)
                        source "$SCRIPT_DIR/modules/040_workflow_setup.sh"
                        ;;
                    wofi)
                        source "$SCRIPT_DIR/modules/061_wofi_setup.sh"
                        ;;
                    qt)
                        source "$SCRIPT_DIR/modules/070_qt_setup.sh"
                        ;;
                    warp)
                        source "$SCRIPT_DIR/modules/071_warp_setup.sh"
                        ;;
                    browser)
                        source "$SCRIPT_DIR/../scripts/browser/setup.sh"
                        ;;
                    editor)
                        source "$SCRIPT_DIR/../scripts/editor/setup.sh"
                        ;;
                    filemanager)
                        source "$SCRIPT_DIR/../scripts/filemanager/setup.sh"
                        ;;
                    multiplexer)
                        source "$SCRIPT_DIR/../scripts/multiplexer/setup.sh"
                        ;;
                    monitor)
                        source "$SCRIPT_DIR/../scripts/monitor/setup.sh"
                        ;;
                    workflow)
                        source "$SCRIPT_DIR/modules/040_workflow_setup.sh"
                        ;;
                esac
            done < "$CUSTOM_SELECTION_FILE"
        fi
    else
        # Full or environment-specific mode
        if [ "$INSTALL_ENVIRONMENT" = "both" ] || [ "$INSTALL_ENVIRONMENT" = "dwm" ]; then
            log_info "Installing DWM/X11 environment..."
            source "$SCRIPT_DIR/modules/010_dwm_setup.sh"
            source "$SCRIPT_DIR/../scripts/dwm/setup.sh"
            source "$SCRIPT_DIR/../scripts/rofi/setup.sh"
        fi
        
        if [ "$INSTALL_ENVIRONMENT" = "both" ] || [ "$INSTALL_ENVIRONMENT" = "wayland" ]; then
            log_info "Installing Wayland environment..."
            source "$SCRIPT_DIR/modules/040_workflow_setup.sh"
            source "$SCRIPT_DIR/modules/061_wofi_setup.sh"
        fi
    fi
    
    # --- STEP 5: Shared Modules (ALWAYS EXECUTE in non-custom mode) ---
    if [ "$INSTALL_MODE" != "custom" ]; then
        log_info "Step 5/6: Installing Shared Modules..."
        source "$SCRIPT_DIR/modules/070_qt_setup.sh"
        source "$SCRIPT_DIR/modules/071_warp_setup.sh"
        source "$SCRIPT_DIR/../scripts/browser/setup.sh"
        source "$SCRIPT_DIR/../scripts/editor/setup.sh"
        source "$SCRIPT_DIR/../scripts/filemanager/setup.sh"
        source "$SCRIPT_DIR/../scripts/multiplexer/setup.sh"
        source "$SCRIPT_DIR/../scripts/monitor/setup.sh"
        source "$SCRIPT_DIR/modules/040_workflow_setup.sh"
    fi
    
    # --- STEP 6: Post-Install ---
    log_info "Step 6/6: Post-Install Configuration..."
    if [ -f "$SCRIPT_DIR/modules/090_final_cleanup.sh" ]; then
        source "$SCRIPT_DIR/modules/090_final_cleanup.sh"
    fi
    if [ -f "$SCRIPT_DIR/post_install/setup_stow.sh" ]; then
        source "$SCRIPT_DIR/post_install/setup_stow.sh"
    fi
    
    # Summary
    echo ""
    box_title "🎉 ORCHESTRATION COMPLETED"
    echo ""
    log_success "Environment: $INSTALL_ENVIRONMENT ($INSTALL_MODE)"
    log_info "Install log: $INSTALL_LOG_FILE"
    log_info "System log: $LOG_FILE"
    log_info "Backup location: $BACKUP_DIR"
    echo ""
    log_info "Next steps:"
    echo "  1. Logout and login to apply shell changes"
    echo "  2. Restart your session (DWM or Wayland)"
    echo "  3. Run 'ws-menu' to launch your first workflow"
    echo ""
}

# Run main
main "$@"
