#!/bin/bash
# ============================================================
#  SNAPSHOT RESTORE - Restore system configuration from snapshot
#  Usage: ./scripts/rollback/snapshot_restore.sh [name]
#  ============================================================

set -euo pipefail

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/functions.sh"
source "$SCRIPT_DIR/../common/logger.sh"
source "$SCRIPT_DIR/../common/colors.sh"

# Configuration
readonly SNAPSHOTS_DIR="$HOME/.s1b_snapshots"

# Ensure snapshots directory exists
if [ ! -d "$SNAPSHOTS_DIR" ]; then
    log_error "Snapshots directory not found: $SNAPSHOTS_DIR"
    exit 1
fi

# Get snapshot name
if [ $# -eq 0 ]; then
    log_error "Please specify a snapshot name"
    echo ""
    echo "${COLOR_TEXT}Usage:${COLOR_RESET} $0 <snapshot_name>"
    echo ""
    echo "${COLOR_TEXT}Available snapshots:${COLOR_RESET}"
    list_snapshots
    exit 1
fi

SNAPSHOT_NAME="$1"
SNAPSHOT_DIR="$SNAPSHOTS_DIR/$SNAPSHOT_NAME"

# Check if snapshot exists
if [ ! -d "$SNAPSHOT_DIR" ]; then
    log_error "Snapshot not found: $SNAPSHOT_NAME"
    echo ""
    log_info "Available snapshots:"
    list_snapshots
    exit 1
fi

# Display snapshot info
log_info "Restoring snapshot: $SNAPSHOT_NAME..."

if [ -f "$SNAPSHOT_DIR/metadata.txt" ]; then
    echo ""
    echo "${COLOR_BOLD}${COLOR_Mauve}Snapshot Information:${COLOR_RESET}"
    cat "$SNAPSHOT_DIR/metadata.txt"
    echo ""
fi

# Confirm restoration
echo "${COLOR_RED}⚠️  WARNING: This will overwrite your current configuration!${COLOR_RESET}"
echo ""
read -r -p "${COLOR_TEXT}Are you sure you want to restore? Type 'yes' to confirm: ${COLOR_RESET}" CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    log_info "Restoration cancelled by user"
    exit 0
fi

log_info "Restoring configuration from snapshot..."

# Create backup of current config before restore
BACKUP_DIR="$SNAPSHOTS_DIR/pre_restore_$(date +%Y%m%d_%H%M%S)"
log_info "Creating backup of current config: $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

# Backup current configs
for backup_item in "$HOME/.config/dwm" "$HOME/.config/waybar" "$HOME/.config/rofi"; do
    if [ -e "$backup_item" ]; then
        cp -r "$backup_item" "$BACKUP_DIR/" || log_warn "Failed to backup $backup_item"
    fi
done

# Restore from snapshot
RESTORED=0
FAILED=0

for item in "$SNAPSHOT_DIR"/*; do
    if [ -d "$item" ] && [ "$(basename "$item")" != "metadata" ]; then
        item_name=$(basename "$item")
        target="$HOME/$item_name"
        
        log_info "Restoring: $item_name"
        
        # Remove existing
        if [ -e "$target" ]; then
            rm -rf "$target" 2>/dev/null || log_warn "Failed to remove $target"
        fi
        
        # Copy from snapshot
        if cp -r "$item" "$HOME/"; then
            ((RESTORED++))
        else
            ((FAILED++))
            log_error "Failed to restore $item_name"
        fi
    fi
done

# Restore home-level files
for file in "$HOME/.zshrc" "$HOME/.p10k.zsh"; do
    if [ -f "$SNAPSHOT_DIR/$(basename "$file")" ]; then
        log_info "Restoring: $(basename $file)"
        cp "$SNAPSHOT_DIR/$(basename "$file")" "$HOME/"
        ((RESTORED++))
    fi
done

log_success "Restoration completed!"
echo ""
echo "${COLOR_GREEN}✓ Restored:$COLOR_RESET} $RESTORED items"
if [ $FAILED -gt 0 ]; then
    echo "${COLOR_RED}✗ Failed:$COLOR_RESET} $FAILED items"
fi
echo ""
echo "${COLOR_TEXT}Previous config backup:${COLOR_RESET} $BACKUP_DIR"
echo ""
echo "${COLOR_TEXT}Next steps:${COLOR_RESET}"
echo "  1. Restart DWM or logout/login"
echo "  2. Run: s1b-doctor (to verify restoration)"
echo ""
