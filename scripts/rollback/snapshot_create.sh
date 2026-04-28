#!/bin/bash
# ============================================================
#  SNAPSHOT CREATE - Create system configuration snapshot
#  Usage: ./scripts/rollback/snapshot_create.sh [name]
#  ============================================================

set -euo pipefail

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/functions.sh"
source "$SCRIPT_DIR/../common/logger.sh"
source "$SCRIPT_DIR/../common/colors.sh"

# Configuration
readonly SNAPSHOTS_DIR="$HOME/.s1b_snapshots"
readonly MAX_SNAPSHOTS=10

# Ensure snapshots directory exists
mkdir -p "$SNAPSHOTS_DIR"

# Get snapshot name
if [ $# -eq 0 ]; then
    SNAPSHOT_NAME="snapshot_$(date +%Y%m%d_%H%M%S)"
else
    SNAPSHOT_NAME="$1"
fi

log_info "Creating snapshot: $SNAPSHOT_NAME..."

# Check if snapshot already exists
SNAPSHOT_DIR="$SNAPSHOTS_DIR/$SNAPSHOT_NAME"
if [ -d "$SNAPSHOT_DIR" ]; then
    log_error "Snapshot $SNAPSHOT_NAME already exists"
    exit 1
fi

# Create snapshot directory
mkdir -p "$SNAPSHOT_DIR"

# Files and directories to backup
CONFIG_LOCATIONS=(
    "$HOME/.config/dwm"
    "$HOME/.config/waybar"
    "$HOME/.config/rofi"
    "$HOME/.config/kitty"
    "$HOME/.config/zellij"
    "$HOME/.config/zsh"
    "$HOME/.config/fish"
    "$HOME/.config/nvim"
    "$HOME/.config/emacs"
    "$S1B_ROOT/workflow"
    "$HOME/.zshrc"
    "$HOME/.p10k.zsh"
)

# Backup each location
for location in "${CONFIG_LOCATIONS[@]}"; do
    if [ -e "$location" ]; then
        log_info "Backing up: $location"
        cp -r "$location" "$SNAPSHOT_DIR/" || log_warn "Failed to backup $location"
    fi
done

# Create snapshot metadata
METADATA="$SNAPSHOT_DIR/metadata.txt"
cat > "$METADATA" << EOF
========================================
 S1Bs1stem Snapshot Metadata
========================================

Snapshot Name: $SNAPSHOT_NAME
Created: $(date)
System: $(uname -sr)
Kernel: $(uname -r)
Shell: $(basename $SHELL)
User: $USER

Backuped Locations:
$(for loc in "${CONFIG_LOCATIONS[@]}"; do
    if [ -e "$loc" ]; then
        echo "  ✓ $loc"
    fi
done)

Snapshot Size:
$(du -sh "$SNAPSHOT_DIR" | cut -f1)

========================================
EOF

log_success "Snapshot metadata created"

# Rotate old snapshots (keep only MAX_SNAPSHOTS)
log_info "Rotating old snapshots (keeping $MAX_SNAPSHOTS)..."

SNAPSHOT_COUNT=$(find "$SNAPSHOTS_DIR" -mindepth 1 -maxdepth 1 -type d | wc -l)
readonly SNAPSHOT_COUNT

if [ $SNAPSHOT_COUNT -gt $MAX_SNAPSHOTS ]; then
    log_info "Found $SNAPSHOT_COUNT snapshots, removing $((SNAPSHOT_COUNT - MAX_SNAPSHOTS)) oldest..."
    
    # Find and remove oldest snapshots
    find "$SNAPSHOTS_DIR" -mindepth 1 -maxdepth 1 -type d -printf '%T@ %p\n' | \
        sort -n | \
        head -n -$((SNAPSHOT_COUNT - MAX_SNAPSHOTS)) | \
        cut -d' ' -f2- | \
        xargs -I {} rm -rf {}
    
    log_success "Old snapshots rotated"
else
    log_info "No rotation needed ($SNAPSHOT_COUNT/$MAX_SNAPSHOTS snapshots)"
fi

# Create snapshot manifest
MANIFEST="$SNAPSHOTS_DIR/manifest.txt"
echo "$SNAPSHOT_NAME:$(date +%s)" >> "$MANIFEST"

log_success "Snapshot created successfully!"
echo ""
echo "${COLOR_TEXT}Snapshot Location:${COLOR_RESET} $SNAPSHOT_DIR"
echo "${COLOR_TEXT}Snapshot Size:${COLOR_RESET} $(du -sh "$SNAPSHOT_DIR" | cut -f1)"
echo "${COLOR_TEXT}Total Snapshots:${COLOR_RESET} $(find "$SNAPSHOTS_DIR" -mindepth 1 -maxdepth 1 -type d | wc -l)"
echo ""
echo "${COLOR_TEXT}Restore with:${COLOR_RESET} s1b-restore $SNAPSHOT_NAME"
