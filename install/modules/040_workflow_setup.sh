#!/bin/bash
# ============================================================
#  WORKFLOW SETUP
#  Setup Eco-Workflow system with profiles
#  ============================================================

set -euo pipefail

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../scripts/common/functions.sh"
source "$SCRIPT_DIR/../../scripts/common/logger.sh"
source "$SCRIPT_DIR/../../scripts/common/colors.sh"

log_info "Setting up Eco-Workflow system..."

WORKFLOW_DIR="$S1B_ROOT/workflow"
WORKFLOW_PROFILES="$WORKFLOW_DIR/profiles"

ensure_dir_exists "$WORKFLOW_DIR"
ensure_dir_exists "$WORKFLOW_PROFILES"

# Create workflow profiles
log_info "Creating workflow profiles..."

# Local Development Profile
cat > "$WORKFLOW_PROFILES/local.md" << 'EOF'
# Eco-Workflow: Local Development
# Purpose: Local coding, file management, and testing

# Terminal Environment
export TERM=kitty
export EDITOR=nvim

# Key Applications
- Neovim: Development editor
- Zellij: Terminal multiplexing
- Kitty: Terminal emulator
- Yazi: File manager

# Zellij Layout: dev.kdl
# Waybar Profile: horizontal_nerdy

# Auto-start Commands
zellij attach --layout dev
EOF

# Remote Server Profile
cat > "$WORKFLOW_PROFILES/remote.md" << 'EOF'
# Eco-Workflow: Remote Server
# Purpose: SSH sessions and server management

# Terminal Environment
export TERM=kitty
export EDITOR=nvim

# Key Applications
- Tmux: Persistent SSH sessions
- Neovim: Remote editing
- Kitty: Terminal emulator

# Tmux Configuration
# Waybar Profile: horizontal_minimal

# Auto-start Commands
tmux attach || tmux new -s remote
EOF

# Deep Write Profile
cat > "$WORKFLOW_PROFILES/write.md" << 'EOF'
# Eco-Workflow: Deep Write
# Purpose: Distraction-free writing and org-mode

# Terminal Environment
export TERM=kitty
export EDITOR=emacsclient

# Key Applications
- Doom Emacs: Writing environment
- Yazi: File manager
- Kitty: Terminal emulator

# Zellij Layout: write.kdl
# Waybar Profile: horizontal_minimal

# Auto-start Commands
emacs --daemon
zellij attach --layout write
EOF

# Red Team Profile
cat > "$WORKFLOW_PROFILES/redteam.md" << 'EOF'
# Eco-Workflow: Red Team
# Purpose: Security research, CTF, and penetration testing

# Terminal Environment
export TERM=kitty
export EDITOR=nvim

# Key Applications
- Neovim: Exploit development
- Zellij: Terminal multiplexing
- Kitty: Terminal emulator
- Podman: Containerized environments

# Zellij Layout: redteam.kdl
# Waybar Profile: horizontal_block

# Auto-start Commands
zellij attach --layout redteam

# Container Environment
alias malware-box='podman run -it --rm --security-opt seccomp=unconfined --network malware-isolated archlinux'
EOF

log_success "Workflow profiles created"

# Create workflow switcher script
WORKFLOW_SWITCHER="$S1B_ROOT/scripts/workflow/switch_workflow.sh"

cat > "$WORKFLOW_SWITCHER" << 'EOFW'
#!/bin/bash
# Eco-Workflow Switcher
# Usage: ws-switch [local|remote|write|redteam]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/functions.sh"
source "$SCRIPT_DIR/../common/logger.sh"
source "$SCRIPT_DIR/../common/colors.sh"

WORKFLOW_NAME="${1:-local}"

if ! is_workflow "$WORKFLOW_NAME"; then
    log_error "Invalid workflow: $WORKFLOW_NAME"
    log_info "Valid workflows: local, remote, write, redteam"
    exit 1
fi

log_info "Switching to workflow: $WORKFLOW_NAME"

# Load workflow profile
WORKFLOW_FILE="$S1B_ROOT/workflow/profiles/${WORKFLOW_NAME}.md"

if [ -f "$WORKFLOW_FILE" ]; then
    # Set environment variables from profile
    export WORKFLOW_MODE="$WORKFLOW_NAME"
    
    # Start workflow-specific services
    case "$WORKFLOW_NAME" in
        local)
            log_info "Starting Local Development workflow..."
            ;;
        remote)
            log_info "Starting Remote Server workflow..."
            ;;
        write)
            log_info "Starting Deep Write workflow..."
            ;;
        redteam)
            log_info "Starting Red Team workflow..."
            ;;
    esac
    
    log_success "Workflow switched to: $WORKFLOW_NAME"
    log_info "Run your workflow commands now"
else
    log_error "Workflow profile not found: $WORKFLOW_FILE"
    exit 1
fi
EOFW

chmod +x "$WORKFLOW_SWITCHER"
log_success "Workflow switcher created"

# Create workflow menu (for Rofi)
WORKFLOW_MENU="$S1B_ROOT/scripts/workflow/ws-menu.sh"

cat > "$WORKFLOW_MENU" << 'EOFM'
#!/bin/bash
# Eco-Workflow Menu
# Usage: Launch with Rofi

WORKFLOW_DIR="$S1B_ROOT/workflow"
WORKFLOW_SWITCHER="$WORKFLOW_DIR/scripts/switch_workflow.sh"

WORKFACES=(
    "Local Development:local"
    "Remote Server:remote"
    "Deep Write:write"
    "Red Team:redteam"
)

CHOSEN=$(printf '%s\n' "${WORKFACES[@]}" | rofi -dmenu -p "Select Workflow:")
readonly CHOSEN

if [ -n "$CHOSEN" ]; then
    WORKFLOW_NAME=$(echo "$CHOSEN" | cut -d: -f2)
    bash "$WORKFLOW_SWITCHER" "$WORKFLOW_NAME"
fi
EOFM

chmod +x "$WORKFLOW_MENU"
log_success "Workflow menu created"

# Create aliases for workflows
ALIASES_FILE="$HOME/.s1b_workflow_aliases"

cat > "$ALIASES_FILE" << 'EOFA'
#!/bin/bash
# S1Bs1stem Workflow Aliases
# Source this file in your .zshrc or .bashrc

# Workflow Switcher
alias ws-switch='$S1B_ROOT/scripts/workflow/switch_workflow.sh'
alias ws-menu='$S1B_ROOT/scripts/workflow/ws-menu.sh'

# Quick Workflow Access
alias ws-local='ws-switch local'
alias ws-remote='ws-switch remote'
alias ws-write='ws-switch write'
alias ws-redteam='ws-switch redteam'

# Workflow Profiles
alias ws-info='cat $S1B_ROOT/workflow/profiles/$1.md 2>/dev/null || echo "Profile not found"'
EOFA

# Add to .zshrc
if ! grep -q "s1b_workflow_aliases" "$HOME/.zshrc" 2>/dev/null; then
    echo "" >> "$HOME/.zshrc"
    echo "# S1Bs1stem Workflow Aliases" >> "$HOME/.zshrc"
    echo "source $HOME/.s1b_workflow_aliases" >> "$HOME/.zshrc"
    log_success "Workflow aliases added to .zshrc"
fi

log_success "Workflow setup completed"
exit 0
