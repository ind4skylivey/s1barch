#!/bin/bash
# ============================================================
#  S1barch - One-Line Installer
#  ============================================================
#  Usage: bash <(curl -fsSL https://raw.githubusercontent.com/ind4skylivey/s1barch/main/install.sh)
#  Or:    ./install.sh [--install-dir /path] [--skip-clone] [--help]
#  ============================================================

set -euo pipefail

# --- COLORS ---
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly MAUVE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly RESET='\033[0m'

# --- DEFAULTS ---
readonly REPO_URL="https://github.com/ind4skylivey/s1barch.git"
readonly REPO_NAME="s1barch"
DEFAULT_INSTALL_DIR="${HOME}/.local/${REPO_NAME}"

# --- ARGUMENTS ---
INSTALL_DIR=""
SKIP_CLONE=false
INTERACTIVE=true

show_help() {
    cat << EOF
${MAUVE}${BOLD}S1barch Installer${RESET}

${CYAN}Usage:${RESET}
  bash install.sh [OPTIONS]
  bash <(curl -fsSL <url>/install.sh)

${CYAN}Options:${RESET}
  ${GREEN}--install-dir DIR${RESET}   Installation directory (default: ~/.local/s1barch)
  ${GREEN}--skip-clone${RESET}        Skip git clone (use existing directory)
  ${GREEN}--non-interactive${RESET}   Run without prompts
  ${GREEN}--help, -h${RESET}          Show this help message

${CYAN}Examples:${RESET}
  # Default installation:
  bash install.sh

  # Custom location:
  bash install.sh --install-dir /opt/s1barch

  # One-liner:
  bash <(curl -fsSL https://raw.githubusercontent.com/ind4skylivey/s1barch/main/install.sh)

  # Re-run in existing directory:
  cd ~/.local/s1barch && bash install.sh --skip-clone

EOF
    exit 0
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --install-dir)
            INSTALL_DIR="$2"
            shift 2
            ;;
        --skip-clone)
            SKIP_CLONE=true
            shift
            ;;
        --non-interactive)
            INTERACTIVE=false
            shift
            ;;
        --help|-h)
            show_help
            ;;
        *)
            echo -e "${RED}Unknown option: $1${RESET}" >&2
            show_help
            ;;
    esac
done

# Use default if not specified
INSTALL_DIR="${INSTALL_DIR:-$DEFAULT_INSTALL_DIR}"

# --- BANNER ---
echo ""
echo -e "${MAUVE}${BOLD}╔══════════════════════════════════════════════════════╗${RESET}"
echo -e "${MAUVE}${BOLD}║              🚀 S1barch Installer                    ║${RESET}"
echo -e "${MAUVE}${BOLD}║       Advanced Automation for Arch Linux + DWM       ║${RESET}"
echo -e "${MAUVE}${BOLD}╚══════════════════════════════════════════════════════╝${RESET}"
echo ""

# --- PRE-FLIGHT CHECKS ---
check_dependencies() {
    echo -e "${CYAN}[*] Checking dependencies...${RESET}"
    local missing=()

    for cmd in git bash curl; do
        if ! command -v "$cmd" &>/dev/null; then
            missing+=("$cmd")
        fi
    done

    if [[ ${#missing[@]} -gt 0 ]]; then
        echo -e "${RED}[!] Missing dependencies: ${missing[*]}${RESET}"
        echo -e "${YELLOW}    Install with: sudo pacman -S ${missing[*]}${RESET}"
        exit 1
    fi

    echo -e "${GREEN}[✓] All dependencies found${RESET}"
}

check_arch_linux() {
    if [[ ! -f /etc/arch-release ]]; then
        echo -e "${YELLOW}[!] Warning: This system does not appear to be Arch Linux.${RESET}"
        echo -e "${YELLOW}    S1barch is designed for Arch Linux. Continue at your own risk.${RESET}"
        if [[ "$INTERACTIVE" == true ]]; then
            read -r -p "    Continue anyway? [y/N]: " choice
            [[ "${choice,,}" != "y" ]] && exit 1
        fi
    else
        echo -e "${GREEN}[✓] Arch Linux detected${RESET}"
    fi
}

# --- CLONE ---
clone_repo() {
    echo ""
    echo -e "${CYAN}[*] Cloning S1barch to ${BOLD}${INSTALL_DIR}${RESET}..."

    if [[ -d "${INSTALL_DIR}/.git" ]]; then
        echo -e "${YELLOW}[!] Directory ${INSTALL_DIR} already exists with git repo${RESET}"
        if [[ "$INTERACTIVE" == true ]]; then
            read -r -p "    Pull latest changes? [Y/n]: " choice
            if [[ "${choice,,}" != "n" ]]; then
                git -C "$INSTALL_DIR" pull --ff-only 2>/dev/null || {
                    echo -e "${YELLOW}[!] Pull failed, using existing version${RESET}"
                }
            fi
        else
            git -C "$INSTALL_DIR" pull --ff-only 2>/dev/null || true
        fi
    else
        if [[ -d "${INSTALL_DIR}" ]]; then
            echo -e "${YELLOW}[!] Directory ${INSTALL_DIR} exists but is not a git repo${RESET}"
            if [[ "$INTERACTIVE" == true ]]; then
                read -r -p "    Remove and re-clone? [y/N]: " choice
                if [[ "${choice,,}" == "y" ]]; then
                    rm -rf "${INSTALL_DIR}"
                    git clone "$REPO_URL" "$INSTALL_DIR"
                else
                    echo -e "${RED}[!] Cannot continue. Remove ${INSTALL_DIR} manually or use --install-dir${RESET}"
                    exit 1
                fi
            else
                echo -e "${RED}[!] Cannot clone: ${INSTALL_DIR} exists and is not a git repo${RESET}"
                exit 1
            fi
        else
            git clone "$REPO_URL" "$INSTALL_DIR"
        fi
    fi

    echo -e "${GREEN}[✓] Repository ready at ${INSTALL_DIR}${RESET}"
}

# --- SETUP ---
setup_permissions() {
    echo ""
    echo -e "${CYAN}[*] Setting up permissions...${RESET}"

    # Make all .sh files executable
    find "${INSTALL_DIR}" -name "*.sh" -type f -exec chmod +x {} \; 2>/dev/null || true

    echo -e "${GREEN}[✓] Permissions set${RESET}"
}

setup_environment() {
    echo ""
    echo -e "${CYAN}[*] Setting up environment...${RESET}"

    # Export S1B_ROOT so all scripts can find it
    export S1B_ROOT="${INSTALL_DIR}"

    # Add to shell config if not already present
    local shell_rc="${HOME}/.zshrc"
    [[ -f "${HOME}/.bashrc" ]] && shell_rc="${HOME}/.bashrc"

    local s1b_line="export S1B_ROOT=\"${INSTALL_DIR}\""

    if [[ -f "$shell_rc" ]]; then
        if ! grep -qF "S1B_ROOT" "$shell_rc" 2>/dev/null; then
            echo "" >> "$shell_rc"
            echo "# S1barch root directory" >> "$shell_rc"
            echo "$s1b_line" >> "$shell_rc"
            echo -e "${GREEN}[✓] Added S1B_ROOT to ${shell_rc}${RESET}"
        else
            echo -e "${YELLOW}[!] S1B_ROOT already in ${shell_rc}${RESET}"
        fi
    fi

    echo -e "${GREEN}[✓] Environment configured${RESET}"
}

# --- RUN ORCHESTRATOR ---
run_orchestrator() {
    echo ""
    echo -e "${CYUAN}[*] Launching S1barch Orchestrator...${RESET}"
    echo -e "${CYAN}    Install directory: ${BOLD}${INSTALL_DIR}${RESET}"
    echo ""

    cd "${INSTALL_DIR}"

    if [[ -f "install/ORCHESTRA.sh" ]]; then
        bash install/ORCHESTRA.sh "$@"
    else
        echo -e "${RED}[!] ORCHESTRA.sh not found at ${INSTALL_DIR}/install/ORCHESTRA.sh${RESET}"
        echo -e "${YELLOW}    Make sure the repository was cloned correctly.${RESET}"
        exit 1
    fi
}

# --- MAIN ---
main() {
    check_dependencies
    check_arch_linux

    if [[ "$SKIP_CLONE" == false ]]; then
        clone_repo
    else
        echo -e "${YELLOW}[*] Skipping clone, using existing directory${RESET}"
        if [[ ! -d "${INSTALL_DIR}" ]]; then
            echo -e "${RED}[!] Directory ${INSTALL_DIR} does not exist${RESET}"
            exit 1
        fi
    fi

    setup_permissions
    setup_environment
    run_orchestrator "$@"
}

main "$@"