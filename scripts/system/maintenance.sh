#!/bin/bash
# ============================================================
#  SYSTEM MAINTENANCE - System update and maintenance
#  Dependencies: pacman, yay
#  ============================================================

set -euo pipefail

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/functions.sh"
source "$SCRIPT_DIR/../common/logger.sh"
source "$SCRIPT_DIR/../common/colors.sh"

log_info "Starting system maintenance..."

# Update system
update_system() {
    log_info "Updating system packages..."
    
    # Update official packages
    log_info "Updating official packages..."
    if sudo pacman -Syu --noconfirm; then
        log_success "Official packages updated"
    else
        log_error "Failed to update official packages"
    fi
    
    # Update AUR packages
    if command -v yay &>/dev/null; then
        log_info "Updating AUR packages..."
        yay -Syu --devel --noconfirm
        log_success "AUR packages updated"
    fi
    
    # Check for kernel updates
    log_info "Checking for kernel updates..."
    if pacman -Qu linux-lts 2>/dev/null; then
        log_info "Kernel update available: linux-lts"
        echo "Run: sudo pacman -S linux-lts"
    fi
    
    log_success "System update completed"
}

# Upgrade all packages
upgrade_all() {
    log_info "Upgrading all packages..."
    
    sudo pacman -Syu --needed --noconfirm
    yay -Syua --devel --noconfirm --removemake --removemakedeps
    
    log_success "All packages upgraded"
}

# Clean orphan packages
clean_orphans() {
    log_info "Removing orphan packages..."
    
    local orphans
    orphans=$(pacman -Qtdq)
    
    if [ -z "$orphans" ]; then
        log_info "No orphan packages found"
        return 0
    fi
    
    echo "Orphan packages:"
    echo "$orphans"
    echo ""
    
    local confirm
    read -p "Remove orphan packages? [y/N]: " confirm
    
    if [[ "$confirm" =~ ^[yY] ]]; then
        mapfile -t orphans < <(pacman -Qtdq 2>/dev/null || true)
        if [ ${#orphans[@]} -gt 0 ]; then
            # shellcheck disable=SC2046
            sudo pacman -Rns "${orphans[@]}"
        fi
        log_success "Orphan packages removed"
    else
        log_info "Orphan packages kept"
    fi
}

# Sync mirror list
sync_mirrors() {
    log_info "Syncing mirror list..."
    sudo pacman-mirrors --fasttrack --sort rate --save
    log_success "Mirror list synced"
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --update)
            update_system
            shift
            ;;
        --upgrade)
            upgrade_all
            shift
            ;;
        --orphans)
            clean_orphans
            shift
            ;;
        --mirrors)
            sync_mirrors
            shift
            ;;
        --all)
            update_system
            upgrade_all
            clean_orphans
            sync_mirrors
            shift
            ;;
        --dry-run)
            log_info "Dry-run mode - showing what would be done:"
            echo "1. Update system packages (pacman -Syu --noconfirm)"
            echo "2. Update AUR packages (yay -Syu --devel --noconfirm)"
            echo "3. Check for kernel updates"
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [--update|--upgrade|--orphans|--mirrors|--all|--dry-run|--help]"
            echo ""
            echo "Options:"
            echo "  --update        Update system packages"
            echo "  --upgrade       Upgrade all packages"
            echo "  --orphans       Remove orphan packages"
            echo "  --mirrors       Sync mirror list"
            echo "  --all           Run all maintenance tasks"
            echo "  --dry-run       Show what would be done"
            echo "  --help, -h     Show this help"
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Default: show dry-run and ask
read -p "Run system maintenance? [y/N]: " confirm
if [[ ! "$confirm" =~ ^[yY] ]]; then
    log_info "Maintenance cancelled"
    exit 0
fi

update_system

log_success "System maintenance completed"
