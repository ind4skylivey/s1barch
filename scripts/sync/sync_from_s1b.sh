#!/bin/bash
# ============================================================
#  SYNC FROM S1B - Sync configs from dotfiles-s1b
#  Strategy: OVERWRITE (per user's choice)
#  Usage: bash ~/.local/s1barch/scripts/sync/sync_from_s1b.sh
#  ============================================================

set -euo pipefail

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/functions.sh"
source "$SCRIPT_DIR/../common/logger.sh"
source "$SCRIPT_DIR/../common/colors.sh"

# Configuration
readonly DOTFILES_S1B="$HOME/Desktop/dotfiles-s1b"
readonly CONFIG_CACHE="$S1B_ROOT/config_cache"
readonly BACKUP_DIR="$HOME/.s1b_sync_backups"

# Ensure directories exist
ensure_dir_exists "$CONFIG_CACHE"
ensure_dir_exists "$BACKUP_DIR"

# Get sync strategy from config
get_sync_strategy() {
    local config_file="$S1B_ROOT/config/sync_config.yaml"
    
    if [ -f "$config_file" ]; then
        grep "^sync_strategy:" "$config_file" 2>/dev/null | cut -d: -f2 | tr -d ' '
    else
        echo "overwrite"  # Default
    fi
}

# Backup before sync
backup_before_sync() {
    # shellcheck disable=SC2155
    local backup_name="pre_sync_$(date +%Y%m%d_%H%M%S)"
    local backup_path="$BACKUP_DIR/$backup_name"
    
    log_info "Creating pre-sync backup: $backup_name"
    mkdir -p "$backup_path"
    
    # Backup DWM config
    if [ -d "$HOME/.config/dwm" ]; then
        cp -r "$HOME/.config/dwm" "$backup_path/" || true
    fi
    
    # Backup Waybar config
    if [ -d "$HOME/.config/waybar" ]; then
        cp -r "$HOME/.config/waybar" "$backup_path/" || true
    fi
    
    # Backup Kitty config
    if [ -f "$HOME/.config/kitty/kitty.conf" ]; then
        cp "$HOME/.config/kitty/kitty.conf" "$backup_path/" || true
    fi
    
    log_success "Pre-sync backup created"
    echo "$backup_path"
}

# Sync DWM config
sync_dwm() {
    log_info "Syncing DWM config from dotfiles-s1b..."
    
    local dwm_source="$DOTFILES_S1B/.config/dwm"
    local dwm_target="$HOME/.config/dwm"
    
    if [ ! -d "$dwm_source" ]; then
        log_warn "DWM config not found in dotfiles-s1b"
        return 1
    fi
    
    # Backup existing
    local backup
    backup=$(backup_file "$dwm_target" 2>/dev/null || true)
    
    # Copy from dotfiles-s1b
    rsync -av --delete "$dwm_source/" "$dwm_target/"
    
    log_success "DWM config synced from dotfiles-s1b"
    return 0
}

# Sync Waybar config
sync_waybar() {
    log_info "Syncing Waybar config from dotfiles-s1b..."
    
    local waybar_source="$DOTFILES_S1B/.config/waybar"
    local waybar_target="$HOME/.config/waybar"
    
    if [ ! -d "$waybar_source" ]; then
        log_warn "Waybar config not found in dotfiles-s1b"
        return 1
    fi
    
    # Backup existing
    local backup
    backup=$(backup_file "$waybar_target/config-dp1.jsonc" 2>/dev/null || true)
    
    # Copy from dotfiles-s1b
    rsync -av --delete "$waybar_source/" "$waybar_target/"
    
    log_success "Waybar config synced from dotfiles-s1b"
    return 0
}

# Sync Kitty config
sync_kitty() {
    log_info "Syncing Kitty config from dotfiles-s1b..."
    
    local kitty_source="$DOTFILES_S1B/.config/kitty"
    local kitty_target="$HOME/.config/kitty"
    
    if [ ! -d "$kitty_source" ]; then
        log_warn "Kitty config not found in dotfiles-s1b"
        return 1
    fi
    
    # Backup existing
    local backup
    # shellcheck disable=SC2034
    backup=$(backup_file "$kitty_target/kitty.conf" 2>/dev/null || true)
    
    # Copy from dotfiles-s1b
    rsync -av --delete "$kitty_source/" "$kitty_target/"
    
    log_success "Kitty config synced from dotfiles-s1b"
    return 0
}

# Sync workflows
sync_workflows() {
    log_info "Syncing workflows from dotfiles-s1b..."
    
    local workflows_source="$DOTFILES_S1B/workflow"
    local workflows_target="$S1B_ROOT/workflow"
    
    if [ ! -d "$workflows_source" ]; then
        log_warn "Workflows not found in dotfiles-s1b"
        return 1
    fi
    
    # Copy workflows
    rsync -av "$workflows_source/" "$workflows_target/"
    
    log_success "Workflows synced from dotfiles-s1b"
    return 0
}

# Sync all configs
sync_all() {
    log_info "Syncing all configs from dotfiles-s1b..."
    
    local strategy
    strategy=$(get_sync_strategy)
    
    local backup_dir
    if [ "$strategy" != "none" ]; then
        # shellcheck disable=SC2034
        backup_dir=$(backup_before_sync)
    fi
    
    local synced=0
    local failed=0
    
    # Sync DWM
    if sync_dwm; then
        ((synced++))
    else
        ((failed++))
    fi
    
    # Sync Waybar
    if sync_waybar; then
        ((synced++))
    else
        ((failed++))
    fi
    
    # Sync Kitty
    if sync_kitty; then
        ((synced++))
    else
        ((failed++))
    fi
    
    # Sync Workflows
    if sync_workflows; then
        ((synced++))
    else
        ((failed++))
    fi
    
    # Update last sync timestamp
    local current_env
    # shellcheck disable=SC2034
    current_env=$(source "$SCRIPT_DIR/../detection/get_active_env.sh" && get_env)
    
    if [ -f "$S1B_ROOT/config/current_env.yaml" ]; then
        sed -i "s/^last_sync:.*/last_sync: $(date -Iseconds)/" "$S1B_ROOT/config/current_env.yaml"
    else
        echo "last_sync: $(date -Iseconds)" >> "$S1B_ROOT/config/current_env.yaml"
    fi
    
    log_info "Sync complete: $synced synced, $failed failed"
}

# Main function
main() {
    local action="${1:-all}"
    
    case "$action" in
        all|everything)
            sync_all
            ;;
        dwm)
            sync_dwm
            ;;
        waybar)
            sync_waybar
            ;;
        kitty)
            sync_kitty
            ;;
        workflows)
            sync_workflows
            ;;
        *)
            log_error "Invalid action: $action"
            echo "Usage: $0 [all|dwm|waybar|kitty|workflows]"
            exit 1
            ;;
    esac
}

# Run main if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi

# Export functions for sourcing
export -f sync_dwm
export -f sync_waybar
export -f sync_kitty
export -f sync_workflows
export -f sync_all
export -f main
