#!/bin/bash
# ============================================================
#  S1barch Config CLI
#  Quick access to post-install configuration
#  ============================================================
#  Usage: s1b-config [option]
#  
#  Options:
#    configure   - Open configuration menu
#    status      - Show current status
#    profile     - Show/change profile
#    env         - Show/change environment
#    help        - Show this help
#  ============================================================

set -euo pipefail

# Find S1B_ROOT
S1B_ROOT="${S1B_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RESET='\033[0m'

show_help() {
    cat << EOF
${CYAN}S1barch Config CLI${RESET}

Usage: s1b-config [option]

Options:
  configure   Open configuration menu
  status      Show current status
  profile     Show current profile
  env         Show current environment
  help        Show this help

Examples:
  s1b-config           # Open configuration menu
  s1b-config status     # Show status
  s1b-config profile    # Show profile
EOF
}

show_status() {
    echo "S1barch Status:"
    echo ""
    
    if [ -f "$HOME/.s1b_user_profile" ]; then
        echo -e "  Profile: ${GREEN}$(cat "$HOME/.s1b_user_profile")${RESET}"
    else
        echo -e "  Profile: ${RED}Not set${RESET}"
    fi
    
    if [ -f "$HOME/.s1b_environment" ]; then
        echo -e "  Environment: ${GREEN}$(cat "$HOME/.s1b_environment")${RESET}"
    else
        echo -e "  Environment: ${RED}Not set${RESET}"
    fi
    
    if [ -d "$S1B_ROOT/workflow/profiles" ]; then
        echo -e "  Workflows:"
        ls "$S1B_ROOT/workflow/profiles/" 2>/dev/null | sed 's/^/    - /' || true
    fi
}

show_profile() {
    if [ -f "$HOME/.s1b_user_profile" ]; then
        echo "$(cat "$HOME/.s1b_user_profile")"
    else
        echo "Not set"
    fi
}

show_env() {
    if [ -f "$HOME/.s1b_environment" ]; then
        echo "$(cat "$HOME/.s1b_environment")"
    else
        echo "Not set"
    fi
}

# Main
case "${1:-configure}" in
    configure|config)
        if [ -f "$S1B_ROOT/install/post_install/configure.sh" ]; then
            bash "$S1B_ROOT/install/post_install/configure.sh"
        else
            echo "Configure script not found"
            exit 1
        fi
        ;;
    status)
        show_status
        ;;
    profile)
        show_profile
        ;;
    env|environment)
        show_env
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo "Unknown option: $1"
        show_help
        exit 1
        ;;
esac