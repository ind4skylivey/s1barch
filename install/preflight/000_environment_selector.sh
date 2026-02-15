#!/bin/bash
# ============================================================
#  ENVIRONMENT SELECTOR
#  Ask user which environment(s) to install
#  ============================================================

echo ""
echo "🌌 S1Bs1stem Environment Selector"
echo "═══════════════════════════════════════════════════════"
echo ""
echo "Which environment(s) do you want to install?"
echo ""
echo "  1) 💻 FULL INSTALLATION (Wayland + DWM/X11)"
echo "     - All configs for both environments"
echo "     - Switch between them at login"
echo "     - Recommended for dual-session setups"
echo ""
echo "  2) 🌊 WAYLAND ONLY"
echo "     - Waybar + Wofi"
echo "     - GPU-accelerated compositing"
echo "     - Modern, lightweight"
echo ""
echo "  3) 🪟 DWM/X11 ONLY"
echo "     - DWM + Picom + Rofi + Systray"
echo "     - Classic, stable, minimal"
echo "     - Lightweight window manager"
echo ""
echo "  4) ⚙️  CUSTOM INSTALLATION"
echo "     - Choose specific modules individually"
echo "     - Fine-grained control"
echo ""
echo "  q) Quit"
echo ""
echo "═══════════════════════════════════════════════════════"
echo -n "Select option [1-4/q]: "

read -r SELECTION

case "$SELECTION" in
    1)
        export INSTALL_ENVIRONMENT="both"
        export INSTALL_MODE="full"
        echo ""
        echo "📦 Installing: Wayland + DWM/X11 (FULL)"
        ;;
    2)
        export INSTALL_ENVIRONMENT="wayland"
        export INSTALL_MODE="environment"
        echo ""
        echo "🌊 Installing: Wayland ONLY"
        ;;
    3)
        export INSTALL_ENVIRONMENT="dwm"
        export INSTALL_MODE="environment"
        echo ""
        echo "🪟 Installing: DWM/X11 ONLY"
        ;;
    4)
        export INSTALL_ENVIRONMENT="custom"
        export INSTALL_MODE="custom"
        echo ""
        echo "⚙️  Installing: CUSTOM (select modules individually)"
        ;;
    q|Q)
        echo ""
        echo "❌ Installation cancelled by user"
        exit 0
        ;;
    *)
        echo ""
        echo "❌ Invalid selection"
        exit 1
        ;;
esac

# Export to file for other modules
INSTALL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.."
echo "INSTALL_ENVIRONMENT=$INSTALL_ENVIRONMENT" > "$INSTALL_DIR/.env_selection"
echo "INSTALL_MODE=$INSTALL_MODE" >> "$INSTALL_DIR/.env_selection"

echo ""
echo "✓ Environment selected: $INSTALL_ENVIRONMENT"
echo ""
