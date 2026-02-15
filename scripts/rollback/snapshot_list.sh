#!/bin/bash
# ============================================================
#  SNAPSHOT LIST - List all available snapshots
#  Usage: ./scripts/rollback/snapshot_list.sh
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

# Function to list snapshots
list_snapshots() {
    local snapshots
    mapfile -t snapshots < <(find "$SNAPSHOTS_DIR" -mindepth 1 -maxdepth 1 -type d | sort)
    
    if [ ${#snapshots[@]} -eq 0 ]; then
        echo "${COLOR_YELLOW}No snapshots found${COLOR_RESET}"
        return 0
    fi
    
    echo "${COLOR_BOLD}${COLOR_Mauve}╔══════════════════════════════════════════╗${COLOR_RESET}"
    echo "${COLOR_BOLD}${COLOR_Mauve}║         Available Snapshots               ║${COLOR_RESET}"
    echo "${COLOR_BOLD}${COLOR_Mauve}╚══════════════════════════════════════════╝${COLOR_RESET}"
    echo ""
    
    local index=1
    for snapshot in "${snapshots[@]}"; do
        snapshot_name=$(basename "$snapshot")
        
        # Get snapshot metadata
        if [ -f "$snapshot/metadata.txt" ]; then
            created=$(grep "Created:" "$snapshot/metadata.txt" | cut -d: -f2- | xargs)
            system=$(grep "System:" "$snapshot/metadata.txt" | cut -d: -f2- | xargs)
        else
            created=$(stat -c %y "$snapshot" | cut -d' ' -f1,2)
            system="N/A"
        fi
        
        # Get snapshot size
        size=$(du -sh "$snapshot" | cut -f1)
        
        # Display snapshot info
        echo "${COLOR_BOLD}${COLOR_GREEN}[${index}]${COLOR_RESET} ${COLOR_BOLD}${snapshot_name}${COLOR_RESET}"
        echo "    ${COLOR_TEXT}Created:${COLOR_RESET} $created"
        echo "    ${COLOR_TEXT}System:${COLOR_RESET} $system"
        echo "    ${COLOR_TEXT}Size:${COLOR_RESET} $size"
        echo ""
        
        ((index++))
    done
    
    echo "${COLOR_TEXT}Total Snapshots:${COLOR_RESET} ${#snapshots[@]}"
    echo ""
    echo "${COLOR_TEXT}Commands:${COLOR_RESET}"
    echo "  ${COLOR_GREEN}Restore:${COLOR_RESET} s1b-restore <snapshot_name>"
    echo "  ${COLOR_RED}Delete:${COLOR_RESET} s1b-delete <snapshot_name>"
    echo ""
}

# List all snapshots
list_snapshots

exit 0
