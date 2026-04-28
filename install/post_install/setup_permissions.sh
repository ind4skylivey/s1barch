#!/bin/bash
# ============================================================
#  SETUP PERMISSIONS - Set correct permissions for all files
#  Purpose: Ensure executables and configs have proper permissions
#  ============================================================

set -euo pipefail

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/common/functions.sh"
source "$SCRIPT_DIR/../scripts/common/logger.sh"
source "$SCRIPT_DIR/../scripts/common/colors.sh"

log_info "Setting up file permissions..."

# Make all scripts executable
log_info "Making scripts executable..."

DIRECTORIES=(
    "$HOME/.config/dwm"
    "$HOME/.config/waybar"
    "$HOME/.config/rofi"
    "$HOME/.config/kitty"
    "$HOME/.config/zellij"
    "$HOME/.config/zsh"
    "$HOME/.config/fish"
    "$S1B_ROOT/scripts"
    "$HOME/.local/bin"
)

for dir in "${DIRECTORIES[@]}"; do
    if [ -d "$dir" ]; then
        find "$dir" -type f -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
        log_success "Made scripts executable in $dir"
    fi
done

# Set permissions for config files
log_info "Setting config file permissions..."

# .config directories
find "$HOME/.config" -type f -name "*.conf" -exec chmod 644 {} \; 2>/dev/null || true
find "$HOME/.config" -type f -name "*.json*" -exec chmod 644 {} \; 2>/dev/null || true
find "$HOME/.config" -type f -name "*.yaml" -exec chmod 644 {} \; 2>/dev/null || true
find "$HOME/.config" -type f -name "*.yml" -exec chmod 644 {} \; 2>/dev/null || true
find "$HOME/.config" -type f -name "*.toml" -exec chmod 644 {} \; 2>/dev/null || true
find "$HOME/.config" -type f -name "*.kdl" -exec chmod 644 {} \; 2>/dev/null || true

log_success "Config files permissions set"

# Set permissions for executables in .local/bin
if [ -d "$HOME/.local/bin" ]; then
    log_info "Setting .local/bin permissions..."
    find "$HOME/.local/bin" -type f -exec chmod +x {} \; 2>/dev/null || true
    log_success ".local/bin executables set"
fi

# Set permissions for S1Bs1stem scripts
if [ -d "$S1B_ROOT/scripts" ]; then
    log_info "Setting S1Bs1stem scripts permissions..."
    find "$S1B_ROOT/scripts" -type f -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
    log_success "S1Bs1stem scripts permissions set"
fi

# Set permissions for S1Bs1stem install scripts
if [ -d "$S1B_ROOT/install" ]; then
    log_info "Setting S1Bs1stem install scripts permissions..."
    find "$S1B_ROOT/install" -type f -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
    log_success "S1Bs1stem install scripts permissions set"
fi

# Special permissions for DWM config.h (if exists)
if [ -f "$HOME/.config/dwm/config.h" ]; then
    log_info "Setting DWM config.h permissions..."
    chmod 644 "$HOME/.config/dwm/config.h"
    log_success "DWM config.h permissions set"
fi

# Special permissions for SSH keys (keep private)
if [ -d "$HOME/.ssh" ]; then
    log_info "Checking SSH key permissions..."
    find "$HOME/.ssh" -name "id_*" ! -name "*.pub" -exec chmod 600 {} \; 2>/dev/null || true
    find "$HOME/.ssh" -name "*.pub" -exec chmod 644 {} \; 2>/dev/null || true
    chmod 700 "$HOME/.ssh" 2>/dev/null || true
    log_success "SSH key permissions verified"
fi

# Special permissions for GPG keys (keep private)
if [ -d "$HOME/.gnupg" ]; then
    log_info "Checking GPG key permissions..."
    chmod 700 "$HOME/.gnupg" 2>/dev/null || true
    find "$HOME/.gnupg" -name "*.gpg" -exec chmod 600 {} \; 2>/dev/null || true
    log_success "GPG key permissions verified"
fi

# Set permissions for Zellij layouts
if [ -d "$HOME/.config/zellij/layouts" ]; then
    log_info "Setting Zellij layouts permissions..."
    find "$HOME/.config/zellij/layouts" -type f -name "*.kdl" -exec chmod 644 {} \; 2>/dev/null || true
    log_success "Zellij layouts permissions set"
fi

# Set permissions for Doom Emacs
if [ -d "$HOME/.emacs.d" ]; then
    log_info "Setting Doom Emacs permissions..."
    find "$HOME/.emacs.d" -type f -name "*.el" -exec chmod 644 {} \; 2>/dev/null || true
    log_success "Doom Emacs permissions set"
fi

# Create permission check script
log_info "Creating permission check script..."

PERM_CHECK="$HOME/.local/bin/s1b-check-perms"
cat > "$PERM_CHECK" << 'EOF'
#!/bin/bash
# Check common permission issues

echo "Checking permissions..."

ISSUES=0

# Check scripts in .local/bin
find "$HOME/.local/bin" -type f ! -executable -print0 2>/dev/null | while IFS= read -r -d "" file; do
    echo "⚠️  Not executable: $file"
    ((ISSUES++))
done

# Check SSH keys
if [ -f "$HOME/.ssh/id_rsa" ] && [ "$(stat -c %a "$HOME/.ssh/id_rsa")" != "600" ]; then
    echo "⚠️  SSH key should be 600: $HOME/.ssh/id_rsa"
    ((ISSUES++))
fi

if [ -f "$HOME/.ssh/id_ed25519" ] && [ "$(stat -c %a "$HOME/.ssh/id_ed25519")" != "600" ]; then
    echo "⚠️  SSH key should be 600: $HOME/.ssh/id_ed25519"
    ((ISSUES++))
fi

if [ $ISSUES -eq 0 ]; then
    echo "✓ All permissions are correct"
else
    echo "❌ Found $ISSUES permission issue(s)"
    echo "Run: s1b-fix-perms"
fi
EOF

chmod +x "$PERM_CHECK"

# Create permission fix script
PERM_FIX="$HOME/.local/bin/s1b-fix-perms"
cat > "$PERM_FIX" << 'EOF'
#!/bin/bash
# Fix common permission issues

echo "Fixing permissions..."

# Fix scripts in .local/bin
find "$HOME/.local/bin" -type f ! -executable -exec chmod +x {} \;
echo "✓ Fixed .local/bin scripts"

# Fix SSH keys
find "$HOME/.ssh" -name "id_*" ! -name "*.pub" -exec chmod 600 {} \;
find "$HOME/.ssh" -name "*.pub" -exec chmod 644 {} \;
chmod 700 "$HOME/.ssh"
echo "✓ Fixed SSH key permissions"

# Fix GPG keys
chmod 700 "$HOME/.gnupg" 2>/dev/null || true
find "$HOME/.gnupg" -name "*.gpg" -exec chmod 600 {} \; 2>/dev/null || true
echo "✓ Fixed GPG key permissions"

echo ""
echo "Done! Run s1b-check-perms to verify."
EOF

chmod +x "$PERM_FIX"

log_success "Permission check/fix scripts created"
log_info "Check permissions: s1b-check-perms"
log_info "Fix permissions: s1b-fix-perms"

log_success "File permissions setup completed!"
