#!/bin/bash
# ============================================================
#  SNAPSHOT DELETE - Delete a snapshot
#  Usage: ./scripts/rollback/snapshot_delete.sh <snapshot_name>
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
    log_error "Please specify a snapshot name to delete"
    echo ""
    echo "${COLOR_TEXT}Usage:${COLOR_RESET} $0 <snapshot_name>"
    echo ""
    echo "${COLOR_TEXT}Available snapshots:${COLOR_RESET}"
    "$SCRIPT_DIR/snapshot_list.sh"
    exit 1
fi

SNAPSHOT_NAME="$1"
SNAPSHOT_DIR="$SNAPSHOTS_DIR/$SNAPSHOT_NAME"

# Check if snapshot exists
if [ ! -d "$SNAPSHOT_DIR" ]; then
    log_error "Snapshot not found: $SNAPSHOT_NAME"
    echo ""
    log_info "Available snapshots:"
    "$SCRIPT_DIR/snapshot_list.sh"
    exit 1
fi

# Display snapshot info
log_info "Snapshot to delete: $SNAPSHOT_NAME"
echo ""

if [ -f "$SNAPSHOT_DIR/metadata.txt" ]; then
    echo "${COLOR_BOLD}${COLOR_Mauve}Snapshot Information:${COLOR_RESET}"
    cat "$SNAPSHOT_DIR/metadata.txt"
    echo ""
fi

# Get snapshot size
SIZE=$(du -sh "$SNAPSHOT_DIR" | cut -f1)
readonly SIZE
echo "${COLOR_TEXT}Size:${COLOR_RESET} $SIZE"
echo ""

# Confirm deletion
echo "${COLOR_RED}⚠️  WARNING: This action cannot be undone!${COLOR_RESET}"
echo ""
read -r -p "${COLOR_TEXT}Are you sure you want to delete this snapshot? Type 'yes' to confirm: ${COLOR_RESET}" CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    log_info "Deletion cancelled by user"
    exit 0
fi

# Delete snapshot
log_info "Deleting snapshot: $SNAPSHOT_NAME..."

if rm -rf "$SNAPSHOT_DIR"; then
    log_success "Snapshot deleted successfully!"
    
    # Update manifest
    if [ -f "$SNAPSHOTS_DIR/manifest.txt" ]; then
        sed -i "/$SNAPSHOT_NAME:/d" "$SNAPSHOTS_DIR/manifest.txt"
        log_success "Manifest updated"
    fi
    
    # Count remaining snapshots
    REMAINING=$(find "$SNAPSHOTS_DIR" -mindepth 1 -maxdepth 1 -type d | wc -l)
    echo ""
    echo "${COLOR_TEXT}Remaining snapshots:${COLOR_RESET} $REMAINING"
    echo ""
else
    log_error "Failed to delete snapshot"
    exit 1
fi
