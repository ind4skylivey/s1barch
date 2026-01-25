#!/bin/bash
# ============================================================
#  S1Bs1stem - ROLLBACK & RECOVERY SYSTEM
#  ============================================================
#  Usage: source ~/Desktop/S1Bs1stem/scripts/common/rollback.sh
#  Purpose: Create, restore, and manage system snapshots
#  Inspired by: S1B rollback system
#  License: MIT
#  Version: 1.0.0
#  ============================================================

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/functions.sh"
source "$SCRIPT_DIR/logger.sh"
source "$SCRIPT_DIR/colors.sh"

# --- CONSTANTS ---
readonly SNAPSHOTS_DIR="$HOME/.s1b_snapshots"
readonly MAX_SNAPSHOTS=10

# Ensure snapshots directory exists
mkdir -p "$SNAPSHOTS_DIR"

# --- SNAPSHOT MANAGEMENT ---
create_snapshot() {
    local snapshot_name="$1"
    local snapshot_dir="$SNAPSHOTS_DIR/$snapshot_name"
    
    if [ -d "$snapshot_dir" ]; then
        log_error "Snapshot already exists: $snapshot_name"
        return 1
    fi
    
    mkdir -p "$snapshot_dir"
    
    log_info "Creating snapshot: $snapshot_name"
    progress_bar 1 5 30
    
    # Backup critical configs
    log_debug "Backing up DWM config..."
    if [ -d "$HOME/.config/dwm" ]; then
        cp -r "$HOME/.config/dwm" "$snapshot_dir/"
    fi
    progress_bar 2 5 30
    
    log_debug "Backing up Waybar config..."
    if [ -d "$HOME/.config/waybar" ]; then
        cp -r "$HOME/.config/waybar" "$snapshot_dir/"
    fi
    progress_bar 3 5 30
    
    log_debug "Backing up shell configs..."
    if [ -f "$HOME/.zshrc" ]; then
        cp "$HOME/.zshrc" "$snapshot_dir/"
    fi
    if [ -d "$HOME/.config/zsh" ]; then
        cp -r "$HOME/.config/zsh" "$snapshot_dir/"
    fi
    progress_bar 4 5 30
    
    log_debug "Backing up S1Bs1stem configs..."
    if [ -d "$S1B_ROOT/configs" ]; then
        cp -r "$S1B_ROOT/configs" "$snapshot_dir/"
    fi
    progress_bar 5 5 30
    
    # Create metadata
    cat > "$snapshot_dir/snapshot_info.txt" << EOF
S1Bs1stem Snapshot Information
================================
Snapshot Name: $snapshot_name
Created At: $(date)
Created By: $USER
Host: $(hostname)
Kernel: $(uname -r)
Distro: $(cat /etc/os-release | grep PRETTY_NAME | cut -d= -f2)
================================
Files Included:
- DWM config
- Waybar config
- Shell configs
- S1Bs1stem configs
EOF
    
    echo ""
    log_success "Snapshot created: $snapshot_name"
    log_info "Location: $snapshot_dir"
    
    # Cleanup old snapshots
    cleanup_old_snapshots
    
    return 0
}

restore_snapshot() {
    local snapshot_name="$1"
    local snapshot_dir="$SNAPSHOTS_DIR/$snapshot_name"
    
    if [ ! -d "$snapshot_dir" ]; then
        log_error "Snapshot not found: $snapshot_name"
        list_snapshots
        return 1
    fi
    
    # Confirm restoration
    box_title "Restore Snapshot"
    box_content "Snapshot: $snapshot_name"
    box_content "This will overwrite current configurations!"
    box_footer
    
    echo ""
    if ! confirm_action "Are you sure you want to restore?"; then
        log_info "Restoration cancelled"
        return 0
    fi
    
    log_info "Restoring snapshot: $snapshot_name"
    progress_bar 1 5 30
    
    # Restore DWM config
    if [ -d "$snapshot_dir/dwm" ]; then
        log_debug "Restoring DWM config..."
        cp -r "$snapshot_dir/dwm/"* "$HOME/.config/dwm/" 2>/dev/null || true
    fi
    progress_bar 2 5 30
    
    # Restore Waybar config
    if [ -d "$snapshot_dir/waybar" ]; then
        log_debug "Restoring Waybar config..."
        cp -r "$snapshot_dir/waybar/"* "$HOME/.config/waybar/" 2>/dev/null || true
    fi
    progress_bar 3 5 30
    
    # Restore shell configs
    if [ -f "$snapshot_dir/.zshrc" ]; then
        log_debug "Restoring ZSH config..."
        cp "$snapshot_dir/.zshrc" "$HOME/.zshrc"
    fi
    if [ -d "$snapshot_dir/zsh" ]; then
        log_debug "Restoring ZSH configs..."
        cp -r "$snapshot_dir/zsh/"* "$HOME/.config/zsh/" 2>/dev/null || true
    fi
    progress_bar 4 5 30
    
    # Restore S1Bs1stem configs
    if [ -d "$snapshot_dir/configs" ]; then
        log_debug "Restoring S1Bs1stem configs..."
        cp -r "$snapshot_dir/configs/"* "$S1B_ROOT/configs/" 2>/dev/null || true
    fi
    progress_bar 5 5 30
    
    echo ""
    log_success "Snapshot restored: $snapshot_name"
    log_info "You may need to restart DWM and Waybar for changes to take effect"
    
    return 0
}

list_snapshots() {
    log_info "=== Available Snapshots ==="
    echo ""
    
    local count=0
    for snapshot_dir in "$SNAPSHOTS_DIR"/*; do
        if [ -d "$snapshot_dir" ]; then
            local name
            name="$(basename "$snapshot_dir")"
            
            local info_file="$snapshot_dir/snapshot_info.txt"
            
            if [ -f "$info_file" ]; then
                local created_at
                created_at=$(grep "Created At:" "$info_file" | cut -d: -f2-)
                local host
                host=$(grep "Host:" "$info_file" | cut -d: -f2-)
                
                box_content "$name"
                echo -e "  ${COLOR_SUBTEXT}Created: $created_at${COLOR_RESET}"
                echo -e "  ${COLOR_SUBTEXT}Host: $host${COLOR_RESET}"
            else
                box_content "$name"
            fi
            echo ""
            ((count++))
        fi
    done
    
    if [ $count -eq 0 ]; then
        log_info "No snapshots found"
    fi
}

delete_snapshot() {
    local snapshot_name="$1"
    local snapshot_dir="$SNAPSHOTS_DIR/$snapshot_name"
    
    if [ ! -d "$snapshot_dir" ]; then
        log_error "Snapshot not found: $snapshot_name"
        return 1
    fi
    
    # Confirm deletion
    if ! confirm_action "Are you sure you want to delete snapshot: $snapshot_name?"; then
        log_info "Deletion cancelled"
        return 0
    fi
    
    rm -rf "$snapshot_dir"
    log_success "Snapshot deleted: $snapshot_name"
}

cleanup_old_snapshots() {
    log_debug "Cleaning up old snapshots..."
    
    local snapshot_count
    snapshot_count=$(ls -1 "$SNAPSHOTS_DIR" 2>/dev/null | wc -l)
    
    if [ $snapshot_count -gt $MAX_SNAPSHOTS ]; then
        local delete_count=$((snapshot_count - MAX_SNAPSHOTS))
        
        log_info "Found $snapshot_count snapshots, keeping $MAX_SNAPSHOTS"
        log_info "Removing $delete_count oldest snapshots..."
        
        # Delete oldest snapshots
        ls -1t "$SNAPSHOTS_DIR" | tail -n $delete_count | while read snapshot; do
            rm -rf "$SNAPSHOTS_DIR/$snapshot"
            log_debug "Removed old snapshot: $snapshot"
        done
    fi
}

# --- AUTO SNAPSHOT ---
create_auto_snapshot() {
    local prefix="${1:-auto}"
    local timestamp
    timestamp=$(date +%Y%m%d_%H%M%S)
    
    local snapshot_name="${prefix}_${timestamp}"
    
    log_info "Creating automatic snapshot: $snapshot_name"
    create_snapshot "$snapshot_name"
}

# --- SNAPSHOT COMPARISON ---
compare_snapshots() {
    local snapshot1="$1"
    local snapshot2="$2"
    
    log_info "Comparing snapshots: $snapshot1 vs $snapshot2"
    
    local dir1="$SNAPSHOTS_DIR/$snapshot1"
    local dir2="$SNAPSHOTS_DIR/$snapshot2"
    
    if [ ! -d "$dir1" ] || [ ! -d "$dir2" ]; then
        log_error "One or both snapshots not found"
        return 1
    fi
    
    # Use diff to compare
    diff -rq "$dir1" "$dir2" || true
}

# --- MAIN EXECUTION ---
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-help}" in
        create)
            if [ -z "$2" ]; then
                log_error "Usage: $0 create <snapshot_name>"
                exit 1
            fi
            create_snapshot "$2"
            ;;
        restore)
            if [ -z "$2" ]; then
                log_error "Usage: $0 restore <snapshot_name>"
                exit 1
            fi
            restore_snapshot "$2"
            ;;
        list)
            list_snapshots
            ;;
        delete)
            if [ -z "$2" ]; then
                log_error "Usage: $0 delete <snapshot_name>"
                exit 1
            fi
            delete_snapshot "$2"
            ;;
        auto)
            create_auto_snapshot "${2:-auto}"
            ;;
        compare)
            if [ -z "$2" ] || [ -z "$3" ]; then
                log_error "Usage: $0 compare <snapshot1> <snapshot2>"
                exit 1
            fi
            compare_snapshots "$2" "$3"
            ;;
        cleanup)
            cleanup_old_snapshots
            ;;
        help|--help|-h)
            cat << EOF
S1Bs1stem Snapshot Manager

Usage: $0 <command> [options]

Commands:
    create <name>      Create a new snapshot
    restore <name>     Restore from a snapshot
    list               List all snapshots
    delete <name>      Delete a snapshot
    auto [prefix]       Create automatic snapshot with timestamp
    compare <s1> <s2> Compare two snapshots
    cleanup             Remove old snapshots (keeps 10)
    help               Show this help message

Examples:
    $0 create before_upgrade
    $0 restore before_upgrade
    $0 list
    $0 delete old_snapshot
    $0 auto
    $0 compare snapshot1 snapshot2

EOF
            ;;
        *)
            log_error "Unknown command: $1"
            $0 help
            exit 1
            ;;
    esac
fi

# Export functions for use in other scripts
export -f create_snapshot
export -f restore_snapshot
export -f list_snapshots
export -f delete_snapshot
export -f cleanup_old_snapshots
export -f create_auto_snapshot
export -f compare_snapshots
