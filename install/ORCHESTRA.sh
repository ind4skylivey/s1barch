#!/bin/bash
# ============================================================
#  S1Bs1stem - ORCHESTRATOR MASTER SCRIPT
#  ============================================================
#  Inspired by: S1B ORCHESTRA.sh
#  Purpose: Coordinated installation and configuration
#  Author: S1B System
#  License: MIT
#  Version: 1.0.0
#  ============================================================

set -euo pipefail

# --- CONSTANTS ---
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly S1B_ROOT="$(dirname "$SCRIPT_DIR")"
readonly STATE_FILE="$HOME/.s1b_install_state"
readonly LOG_FILE="$HOME/.s1b_install_$(date +%Y%m%d_%H%M%S).log"
readonly LOCK_FILE="/tmp/s1b_orchestra.lock"
readonly BACKUP_DIR="$HOME/.s1b_backup_$(date +%Y%m%d_%H%M%S)"

# --- SOURCE COMMON FUNCTIONS ---
source "$SCRIPT_DIR/../scripts/common/functions.sh"
source "$SCRIPT_DIR/../scripts/common/logger.sh"
source "$SCRIPT_DIR/../scripts/common/colors.sh"

# --- INSTALLATION SEQUENCE ---
# Format: MODE | script.sh [args]
# MODE: U = User, S = Sudo
readonly INSTALL_SEQUENCE=(
    # Phase 1: Pre-flight Checks
    "U | preflight/000_system_check.sh"
    "U | preflight/001_dependencies_check.sh"
    "U | preflight/002_disk_space_check.sh"
    "U | preflight/003_network_check.sh"
    
    # Phase 2: Core Setup
    "U | modules/010_dwm_setup.sh"
    "U | modules/020_shell_setup.sh"
    "U | modules/030_terminal_setup.sh"
    "U | modules/040_workflow_setup.sh"
    
    # Phase 3: UI Components
    "U | modules/050_waybar_setup.sh"
    "U | modules/060_rofi_setup.sh"
    "U | modules/070_zellij_setup.sh"
    
    # Phase 4: Security Tools
    "U | modules/080_security_tools.sh"
    
    # Phase 5: Finalization
    "U | modules/090_final_cleanup.sh"
    "U | post_install/setup_stow.sh"
    "U | post_install/setup_permissions.sh"
    "U | post_install/verify_installation.sh"
)

# --- SUDO MANAGEMENT ---
SUDO_PID=""

init_sudo() {
    log_info "Sudo privileges required. Please authenticate."
    if ! sudo -v; then
        log_error "Sudo authentication failed."
        exit 1
    fi
    
    # Refresh sudo periodically
    (while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null) &
    SUDO_PID=$!
    disown "$SUDO_PID"
}

cleanup_sudo() {
    if [ -n "$SUDO_PID" ]; then
        kill "$SUDO_PID" 2>/dev/null || true
    fi
}

# --- HELPERS ---
trim() {
    local var="$*"
    var="${var#"${var%%[![:space:]]*"}"
    var="${var%"${var##*[![:space:]]"}"
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
    for entry in "${INSTALL_SEQUENCE[@]}"; do
        local rest="${entry#*|}"
        rest=$(trim "$rest")
        local filename args
        read -r filename args <<< "$rest"
        
        if [[ ! -f "$SCRIPT_DIR/$filename" ]]; then
            log_error "Missing file: ${filename}"
            ((missing++))
        fi
    done
    
    if ((missing > 0)); then
        log_error "$missing script(s) are missing from $SCRIPT_DIR"
        read -r -p "Continue anyway? [y/N]: " _choice
        if [[ "${_choice,,}" != "y" ]]; then
            log_error "Aborting execution."
            exit 1
        fi
    else
        log_success "All sequence files verified."
    fi
}

# --- ARGUMENT HANDLING ---
show_help() {
    cat << EOF
${COLOR_MAuve}${COLOR_BOLD}S1Bs1stem Orchestrator${COLOR_RESET}

${COLOR_TEXT}Usage:${COLOR_RESET} $0 [OPTIONS]

${COLOR_TEXT}Options:${COLOR_RESET}
    ${COLOR_GREEN}--help, -h${COLOR_RESET}       Show this help message and exit
    ${COLOR_GREEN}--dry-run, -d${COLOR_RESET}    Preview execution plan without running anything
    ${COLOR_RESET}--reset          Clear progress state and start fresh
    ${COLOR_GREEN}--interactive, -i${COLOR_RESET} Run interactively (prompt before each script)
    ${COLOR_GREEN}--verbose, -v${COLOR_RESET}    Enable verbose output

${COLOR_TEXT}Description:${COLOR_RESET}
    This script orchestrates the installation and configuration
    of S1Bs1stem system. It tracks completed scripts and
    can resume from where it left off if interrupted.

${COLOR_TEXT}Examples:${COLOR_RESET}
    $0                  # Normal run
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
            rm -f "$STATE_FILE"
            log_info "State file reset. Starting fresh."
            shift
            ;;
        --interactive|-i)
            INTERACTIVE_MODE=true
            shift
            ;;
        --verbose|-v)
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
    echo ""
    log_info "Execution plan:"
    echo ""
    
    local i=0
    for entry in "${INSTALL_SEQUENCE[@]}"; do
        ((++i))
        local mode="${entry%%|*}"
        local rest="${entry#*|}"
        mode=$(trim "$mode")
        rest=$(trim "$rest")
        
        local filename args
        read -r filename args <<< "$rest"
        
        local mode_label="USER"
        [[ "$mode" == "S" ]] && mode_label="SUDO"
        
        local status="PENDING"
        if [[ -f "$STATE_FILE" ]] && grep -Fxq "$filename" "$STATE_FILE" 2>/dev/null; then
            status="${COLOR_GREEN}DONE${COLOR_RESET}"
        fi
        
        printf "  %3d. [%s] %-45s %s\n" "$i" "$mode_label" "${filename}${args:+ $args}" "$status"
    done
    
    echo ""
    log_info "No changes will be made."
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
    trap "release_lock '$LOCK_FILE'" EXIT
    
    # Setup logging
    log_info "Starting S1Bs1stem Orchestrator"
    log_info "Log file: $LOG_FILE"
    
    # Pre-flight check
    preflight_check
    
    # Check for sudo requirement
    local needs_sudo=0
    for entry in "${INSTALL_SEQUENCE[@]}"; do
        if [[ "$entry" == S* ]]; then needs_sudo=1; break; fi
    done
    
    if [[ $needs_sudo -eq 1 ]]; then
        init_sudo
        trap "cleanup_sudo; release_lock '$LOCK_FILE'" EXIT
    fi
    
    # Session recovery prompt
    if [[ -s "$STATE_FILE" ]]; then
        echo ""
        log_warn ">>> PREVIOUS SESSION DETECTED <<<"
        read -r -p "Do you want to [C]ontinue where you left off or [S]tart over? [C/s]: " _session_choice
        if [[ "${_session_choice,,}" == "s" || "${_session_choice,,}" == "start" ]]; then
            rm -f "$STATE_FILE"
            touch "$STATE_FILE"
            log_info "State file reset. Starting fresh."
        else
            log_info "Continuing from previous session."
        fi
    fi
    
    # Execution mode selection
    if [[ $INTERACTIVE_MODE -eq 1 ]]; then
        echo ""
        log_info ">>> INTERACTIVE MODE <<<"
        log_info "You will be asked before each script."
    else
        log_info ">>> AUTONOMOUS MODE <<<"
        log_info "Running all scripts without confirmation."
    fi
    
    # Start timer
    local start_ts=$SECONDS
    touch "$STATE_FILE"
    
    # Execute scripts
    local total_scripts=${#INSTALL_SEQUENCE[@]}
    local current_index=0
    local SKIPPED_OR_FAILED=()
    
    for entry in "${INSTALL_SEQUENCE[@]}"; do
        ((++current_index))
        
        local mode="${entry%%|*}"
        local rest="${entry#*|}"
        mode=$(trim "$mode")
        rest=$(trim "$rest")
        
        local filename args
        read -r filename args <<< "$rest"
        
        # Check if script exists
        if [[ ! -f "$SCRIPT_DIR/$filename" ]]; then
            log_error "Script not found: $filename"
            log_error "Looked in: $SCRIPT_DIR"
            read -r -p "Do you want to [S]kip to next, [R]etry check, or [Q]uit? (s/r/q): " _choice
            case "${_choice,,}" in
                s|skip)
                    SKIPPED_OR_FAILED+=("$filename")
                    continue
                    ;;
                r|retry)
                    log_info "Retrying check for $filename..."
                    sleep 1
                    ;;
                *)
                    log_info "Stopping execution."
                    exit 1
                    ;;
            esac
        fi
        
        # Check if already completed
        if grep -Fxq "$filename" "$STATE_FILE" 2>/dev/null; then
            log_warn "[${current_index}/${total_scripts}] Skipping $filename (Already Completed)"
            continue
        fi
        
        # Interactive mode prompt
        if [[ $INTERACTIVE_MODE -eq 1 ]]; then
            local desc
            desc=$(get_script_description "$filename")
            
            echo ""
            log_info ">>> NEXT SCRIPT [${current_index}/${total_scripts}]: $filename ${args:+ $args} ($mode)"
            echo "    ${COLOR_SUBTEXT}Description: $desc${COLOR_RESET}"
            
            read -r -p "Do you want to [P]roceed, [S]kip, or [Q]uit? (p/s/q): " _user_confirm
            case "${_user_confirm,,}" in
                s|skip)
                    log_warn "Skipping $filename (User Selection)"
                    SKIPPED_OR_FAILED+=("$filename")
                    continue
                    ;;
                q|quit)
                    log_info "User requested exit."
                    exit 0
                    ;;
                *)
                    # Proceed
                    ;;
            esac
        fi
        
        # Execute with retry loop
        while true; do
            log_run "[${current_index}/${total_scripts}] Executing: $filename $args ($mode)"
            
            local result=0
            if [[ "$mode" == "S" ]]; then
                sudo bash "$SCRIPT_DIR/$filename" $args || result=$?
            elif [[ "$mode" == "U" ]]; then
                bash "$SCRIPT_DIR/$filename" $args || result=$?
            else
                log_error "Invalid mode '$mode' in config. Use 'S' or 'U'."
                exit 1
            fi
            
            if [[ $result -eq 0 ]]; then
                echo "$filename" >> "$STATE_FILE"
                log_success "Finished $filename"
                sleep 1
                break
            else
                log_error "Failed $filename (Exit Code: $result)."
                
                echo ""
                log_warn "Action Required: Script execution failed."
                read -r -p "Do you want to [S]kip to next, [R]etry, or [Q]uit? (s/r/q): " _fail_choice
                case "${_fail_choice,,}" in
                    s|skip)
                        log_warn "Skipping $filename (User Selection). NOT marking as complete."
                        SKIPPED_OR_FAILED+=("$filename")
                        break
                        ;;
                    r|retry)
                        log_info "Retrying $filename..."
                        sleep 1
                        continue
                        ;;
                    *)
                        log_info "Stopping execution as requested."
                        exit 1
                        ;;
                esac
            fi
        done
    done
    
    # Calculate elapsed time
    local end_ts=$SECONDS
    local duration=$((end_ts - start_ts))
    local minutes=$((duration / 60))
    local seconds=$((duration % 60))
    
    # Summary
    echo ""
    box_title "ORCHESTRATION COMPLETED"
    echo ""
    log_info "Execution Time: ${minutes}m ${seconds}s"
    log_info "Log file: $LOG_FILE"
    echo ""
    
    if [[ ${#SKIPPED_OR_FAILED[@]} -gt 0 ]]; then
        log_warn "Some scripts were skipped or failed:"
        for f in "${SKIPPED_OR_FAILED[@]}"; do
            echo "  - $f"
        done
        echo ""
    fi
    
    log_success "Installation completed successfully!"
    echo ""
    log_info "Next steps:"
    echo "  1. Logout and login to apply shell changes"
    echo "  2. Restart DWM (if running)"
    echo "  3. Run 's1b-doctor' to verify system health"
    echo ""
    log_info "Backup location: $BACKUP_DIR"
    echo ""
}

# Run main
main "$@"
