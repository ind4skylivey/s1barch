#!/bin/bash
# ============================================================
#  IRIDEX PRISM BACKUP - Backup & Restore Iridex Prism Terminal config
#  Purpose: Backup/Restore ~/.config/prism without overwriting
#  ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/functions.sh"
source "$SCRIPT_DIR/../common/logger.sh"
source "$SCRIPT_DIR/../common/colors.sh"

readonly PRISM_DIR="$HOME/.config/prism"
readonly BACKUP_DIR="$HOME/.s1b_backups/prism"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
readonly TIMESTAMP

log_info "Timestamp: $TIMESTAMP"

# --- BACKUP FUNCTION ---
backup_prism() {
    log_info "Backing up Iridex Prism Terminal configuration..."
    
    if [ ! -d "$PRISM_DIR" ]; then
        log_warn "Iridex Prism Terminal not found at $PRISM_DIR"
        log_info "Nothing to backup"
        return 1
    fi
    
    # Create backup directory
    local backup_path="$BACKUP_DIR/$TIMESTAMP"
    mkdir -p "$backup_path"
    
    # Backup all files in ~/.config/prism
    log_info "Creating backup: $backup_path"
    
    if [ "$(ls -A "$PRISM_DIR" | wc -l)" -eq 0 ]; then
        log_warn "Directory is empty, skipping"
        return 1
    fi
    
    # Backup using rsync (preserves permissions)
    rsync -av "$PRISM_DIR/" "$backup_path/prism/" 2>/dev/null
    
    # Create backup manifest
    cat > "$backup_path/MANIFEST.md" << EOF
# Iridex Prism Terminal Backup Manifest
- **Backup Date:** $(date)
- **Backup Location:** $backup_path
- **Source:** $PRISM_DIR
- **Files Backed Up:** $(ls -1 "$backup_path/prism/" | wc -l)

## Restore Instructions
\`\`\`bash
cd ~/.local/s1barch
./scripts/prism/backup_prism.sh restore <backup-timestamp>
\`\`\`

EOF
    
    log_success "Backup completed: $backup_path"
    log_info "Files backed up: $(ls -1 "$backup_path/prism/" | wc -l)"
    echo ""
    echo "${COLOR_TEXT}Backup location:${COLOR_RESET} $backup_path"
    
    return 0
}

# --- RESTORE FUNCTION ---
restore_prism() {
    local backup_name="$1"
    local backup_path="$BACKUP_DIR/$backup_name"
    
    if [ $# -eq 0 ]; then
        log_error "Please specify a backup timestamp to restore"
        echo ""
        list_backups
        exit 1
    fi
    
    if [ ! -d "$backup_path" ]; then
        log_error "Backup not found: $backup_path"
        exit 1
    fi
    
    if [ ! -d "$backup_path/prism" ]; then
        log_error "No prism directory in backup"
        exit 1
    fi
    
    # Display backup info
    if [ -f "$backup_path/MANIFEST.md" ]; then
        echo ""
        cat "$backup_path/MANIFEST.md"
        echo ""
    fi
    
    # Confirm restoration
    echo "${COLOR_RED}⚠️  WARNING: This will OVERWRITE your current Iridex Prism Terminal configuration!${COLOR_RESET}"
    echo ""
    read -r -p "${COLOR_TEXT}Are you sure? Type 'yes' to restore: ${COLOR_RESET}" CONFIRM
    if [ "$CONFIRM" != "yes" ]; then
        log_info "Restoration cancelled by user"
        exit 0
    fi
    
    log_info "Restoring Iridex Prism Terminal configuration..."
    
    # Restore using rsync
    rsync -av "$backup_path/prism/" "$PRISM_DIR/"
    
    log_success "Iridex Prism Terminal restored from: $backup_path"
    log_info "Please restart Iridex Prism Terminal to apply changes"
    
    return 0
}

# --- LIST BACKUPS FUNCTION ---
list_backups() {
    log_info "Available Iridex Prism Terminal backups..."
    
    if [ ! -d "$BACKUP_DIR" ]; then
        log_warn "No backups found"
        echo ""
        echo "${COLOR_TEXT}No backups available in $BACKUP_DIR${COLOR_RESET}"
        return 0
    fi
    
    local backups
    mapfile -t backups < <(find "$BACKUP_DIR" -maxdepth 1 -type d -printf '%T@\n' | sort -rn | head -10)
    
    if [ ${#backups[@]} -eq 0 ]; then
        log_warn "No backups found"
        return 0
    fi
    
    echo ""
    echo "${COLOR_BOLD}${COLOR_Mauve}Available Backups:${COLOR_RESET}"
    echo ""
    
    for backup in "${backups[@]}"; do
        local backup_name
        backup_name=$(basename "$backup")
        local backup_date
        backup_date=$(basename "$backup" | sed 's/_/ / at /')
        local size
        size=$(du -sh "$backup" | cut -f1)
        
        echo "${COLOR_GREEN}✓${COLOR_RESET} $backup_name"
        echo "    ${COLOR_TEXT}Created:${COLOR_RESET} $backup_date"
        echo "    ${COLOR_TEXT}Size:${COLOR_RESET} $size"
        echo "    ${COLOR_TEXT}Location:${COLOR_RESET} $backup"
        echo ""
    done
}

# --- DELETE BACKUP FUNCTION ---
delete_backup() {
    local backup_name="$1"
    local backup_path="$BACKUP_DIR/$backup_name"
    
    if [ ! -d "$backup_path" ]; then
        log_error "Backup not found: $backup_path"
        exit 1
    fi
    
    echo "${COLOR_RED}⚠️  WARNING: This cannot be undone!${COLOR_RESET}"
    echo ""
    read -r -p "${COLOR_TEXT}Delete backup: $backup_name? Type 'yes' to confirm: ${COLOR_RESET}" CONFIRM
    if [ "$CONFIRM" != "yes" ]; then
        log_info "Deletion cancelled by user"
        exit 0
    fi
    
    log_info "Deleting backup: $backup_name..."
    rm -rf "$backup_path"
    log_success "Backup deleted"
    
    echo ""
    echo "${COLOR_TEXT}Remaining backups:${COLOR_RESET} $(find "$BACKUP_DIR" -maxdepth 1 -type d | wc -l)"
}

# --- MAIN LOGIC ---
case "${1:-backup}" in
    backup)
        backup_prism
        ;;
    restore)
        restore_prism "$2"
        ;;
    list)
        list_backups
        ;;
    delete)
        delete_backup "$2"
        ;;
    help|--help|-h)
        cat << EOF
${COLOR_BOLD}${COLOR_Mauve}Iridex Prism Terminal Backup/Restore${COLOR_RESET}

${COLOR_TEXT}Usage:${COLOR_RESET} $0 <command> [backup-name]

${COLOR_TEXT}Commands:${COLOR_RESET}
  ${COLOR_GREEN}backup${COLOR_RESET}        - Create backup of current Iridex Prism Terminal config
  ${COLOR_GREEN}restore${COLOR_RESET}       <name>  - Restore from backup
  ${COLOR_GREEN}list${COLOR_RESET}          - List all available backups
  ${COLOR_GREEN}delete${COLOR_RESET}        <name> - Delete a backup

${COLOR_TEXT}Examples:${COLOR_RESET}
  $0 backup                          # Create new backup
  $0 list                            # List all backups
  $0 restore 20260125_123045             # Restore from backup
  $0 delete 20260125_123045             # Delete backup

${COLOR_TEXT}Note:${COLOR_RESET} Iridex Prism Terminal is a separate project from dotfiles-s1b.
This script only backups/restores, does not install Iridex Prism Terminal.
EOF
        ;;
    *)
        echo "Unknown command: $1"
        $0 help
        exit 1
        ;;
esac
