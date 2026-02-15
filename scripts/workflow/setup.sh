#!/bin/bash
# ============================================================
#  WORKFLOW SETUP - Orchestrate Workflow installation from dotfiles-s1b
#  Purpose: Sync workflow profiles and layouts from dotfiles-s1b
#  ============================================================

set -euo pipefail

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/functions.sh"
source "$SCRIPT_DIR/../common/logger.sh"
source "$SCRIPT_DIR/../common/colors.sh"

# Configuration
readonly DOTFILES_S1B="$HOME/Desktop/dotfiles-s1b"
readonly WORKFLOW_SOURCE="$DOTFILES_S1B/workflow"
readonly WORKFLOW_TARGET="$HOME/Desktop/S1Bs1stem/workflow"

# Ensure directories exist
ensure_dir_exists "$WORKFLOW_TARGET/profiles"
ensure_dir_exists "$WORKFLOW_TARGET/zellij/layouts"

# Sync workflows
log_info "Syncing Workflows from dotfiles-s1b..."

if [ ! -d "$WORKFLOW_SOURCE" ]; then
    log_error "Workflow source directory not found: $WORKFLOW_SOURCE"
    log_warn "Ensure dotfiles-s1b is cloned at $DOTFILES_S1B"
    exit 1
fi

# Copy workflow profiles
log_info "Copying workflow profiles..."
if [ -d "$WORKFLOW_SOURCE/profiles" ]; then
    rsync -av "$WORKFLOW_SOURCE/profiles/" "$WORKFLOW_TARGET/profiles/"
else
    log_warn "Workflow profiles directory not found"
fi

# Copy Zellij layouts
log_info "Copying Zellij layouts..."
if [ -d "$WORKFLOW_SOURCE/zellij/layouts" ]; then
    rsync -av "$WORKFLOW_SOURCE/zellij/layouts/" "$WORKFLOW_TARGET/zellij/layouts/"
else
    log_warn "Zellij layouts directory not found"
fi

log_success "Workflows synced from dotfiles-s1b"
log_info "Location: $WORKFLOW_TARGET"
