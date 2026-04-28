#!/bin/bash
# ============================================================
#  USER PROFILE SELECTOR
#  Select user profile for dotfiles-s1b installation
#  ============================================================
#  Based on: dotfiles-s1b packages (https://github.com/ind4skylivey/dotfiles-s1b)
#  ============================================================

echo ""
echo "👤 S1barch User Profile Selector"
echo "═══════════════════════════════════════════════════════"
echo ""
echo "Select your usage profile:"
echo ""
echo "  1) 💻 DEV"
echo "     - fish, zsh, neovim, git"
echo "     - kitty, alacritty, tmux"
echo "     - AUR: yazi, zellij, fastfetch"
echo ""
echo "  2) 🛡️ SECURITY"
echo "     - Same as DEV (dotfiles-s1b core tools)"
echo "     - Future: nmap, burp, metasploit, etc."
echo ""
echo "  3) ⚙️  MINIMAL"
echo "     - fish, zsh"
echo "     - stow, starship"
echo "     - No AUR packages"
echo ""
echo "  4) 🚀 S1B (FULL)"
echo "     - All essential packages"
echo "     - All AUR packages"
echo "     - Complete dotfiles-s1b setup"
echo ""
echo "  5) 🔧 CUSTOM"
echo "     - Select packages manually"
echo "     - Full control"
echo ""
echo "  q) Quit"
echo ""
echo "═══════════════════════════════════════════════════════"
echo -n "Select profile [1-5/q]: "

read -r SELECTION

case "$SELECTION" in
    1)
        export USER_PROFILE="dev"
        export PROFILE_PACKAGES="fish zsh neovim git kitty alacritty tmux rofi picom dunst btop starship stow base-devel pcmanfm-qt file-roller kvantum qt5ct"
        export PROFILE_AUR_PACKAGES="fastfetch yazi zellij"
        echo ""
        echo "💻 Profile: DEV selected"
        ;;
    2)
        export USER_PROFILE="security"
        export PROFILE_PACKAGES="fish zsh neovim git kitty alacritty tmux rofi picom dunst btop starship stow base-devel pcmanfm-qt file-roller kvantum qt5ct"
        export PROFILE_AUR_PACKAGES="fastfetch yazi zellij"
        echo ""
        echo "🛡️ Profile: SECURITY selected"
        ;;
    3)
        export USER_PROFILE="minimal"
        export PROFILE_PACKAGES="fish zsh stow starship"
        export PROFILE_AUR_PACKAGES=""
        echo ""
        echo "⚙️  Profile: MINIMAL selected"
        ;;
    4)
        export USER_PROFILE="s1b"
        export PROFILE_PACKAGES="fish zsh neovim git kitty alacritty tmux rofi picom dunst btop starship stow base-devel pcmanfm-qt file-roller kvantum qt5ct"
        export PROFILE_AUR_PACKAGES="fastfetch yazi zellij mcmojave-circle-icon-theme kvmojave-kde-theme"
        echo ""
        echo "🚀 Profile: S1B (FULL) selected"
        ;;
    5)
        export USER_PROFILE="custom"
        export PROFILE_PACKAGES=""
        export PROFILE_AUR_PACKAGES=""
        echo ""
        echo "🔧 Profile: CUSTOM selected"
        echo "   You will select packages manually after this"
        ;;
    q|Q)
        echo ""
        echo "❌ Cancelled by user"
        exit 0
        ;;
    *)
        echo ""
        echo "❌ Invalid selection"
        exit 1
        ;;
esac

# Save profile selection
echo "USER_PROFILE=$USER_PROFILE" > "$SCRIPT_DIR/.user_profile"
echo "PROFILE_PACKAGES=$PROFILE_PACKAGES" >> "$SCRIPT_DIR/.user_profile"
echo "PROFILE_AUR_PACKAGES=$PROFILE_AUR_PACKAGES" >> "$SCRIPT_DIR/.user_profile"

echo "✓ Profile saved: $USER_PROFILE"
echo ""