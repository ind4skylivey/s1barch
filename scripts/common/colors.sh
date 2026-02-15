#!/bin/bash
# ============================================================
#  S1Bs1stem - COLOR DEFINITIONS
#  ============================================================
#  Usage: source ~/Desktop/S1Bs1stem/scripts/common/colors.sh
#  Purpose: Consistent color scheme across all scripts
#  Inspired by: Catppuccin theme
#  License: MIT
#  Version: 1.0.0
#  ============================================================

# --- GUARD AGAINST RE-SOURCING ---
if [ -n "${COLORS_SOURCED:-}" ]; then
    return 0
fi
readonly COLORS_SOURCED=true

# --- TERMINAL COLOR SUPPORT ---
if [[ -t 1 ]] && command -v tput &>/dev/null; then
    if (( $(tput colors 2>/dev/null || echo 0) >= 8 )); then
        COLOR_SUPPORT=true
    else
        COLOR_SUPPORT=false
    fi
else
    COLOR_SUPPORT=false
fi

# --- CATPPUCCIN MAUVE THEME COLORS ---
if [ "$COLOR_SUPPORT" = true ]; then
    # Backgrounds
    COLOR_BASE="${COLOR_BASE:-'\033[38;5;24m'}"      # #1e1e2e
    COLOR_MANTLE="${COLOR_MANTLE:-'\033[38;5;25m'}"   # #181825
    COLOR_SURFACE="${COLOR_SURFACE:-'\033[38;5;26m'}"   # #313244
    
    # Foregrounds
    COLOR_TEXT="${COLOR_TEXT:-'\033[38;5;27m'}"         # #cdd6f4
    COLOR_SUBTEXT="${COLOR_SUBTEXT:-'\033[38;5;28m'}"  # #a6adc8
    
    # Accents (Mauve)
    COLOR_MAuve="${COLOR_MAuve:-'\033[38;5;35m'}"     # #cba6f7
    COLOR_RED="${COLOR_RED:-'\033[38;5;167m'}"        # #e38c8f
    COLOR_PEACH="${COLOR_PEACH:-'\033[38;5;203m'}"    # #fab387
    COLOR_YELLOW="${COLOR_YELLOW:-'\033[38;5;208m'}"   # #f9e2af
    COLOR_GREEN="${COLOR_GREEN:-'\033[38;5;150m'}"     # #a6e3a1
    COLOR_TEAL="${COLOR_TEAL:-'\033[38;5;108m'}"      # #94e2d5
    COLOR_SKY="${COLOR_SKY:-'\033[38;5;103m'}"        # #89dceb
    COLOR_LAVENDER="${COLOR_LAVENDER:-'\033[38;5;36m'}" # #b4befe
    
    # Formatting
    COLOR_BOLD="${COLOR_BOLD:-'\033[1m'}"
    COLOR_DIM="${COLOR_DIM:-'\033[2m'}"
    COLOR_ITALIC="${COLOR_ITALIC:-'\033[3m'}"
    COLOR_UNDERLINE="${COLOR_UNDERLINE:-'\033[4m'}"
    COLOR_RESET="${COLOR_RESET:-'\033[0m'}"
    
    # Special formatting
    COLOR_INFO="${COLOR_INFO:-'$COLOR_BLUE'}"
    COLOR_SUCCESS="${COLOR_SUCCESS:-'$COLOR_GREEN'}"
    COLOR_WARNING="${COLOR_WARNING:-'$COLOR_YELLOW'}"
    COLOR_ERROR="${COLOR_ERROR:-'$COLOR_RED'}"
    COLOR_DEBUG="${COLOR_DEBUG:-'$COLOR_LAVENDER'}"
else
    # No color support
    COLOR_BASE=''
    COLOR_MANTLE=''
    COLOR_SURFACE=''
    COLOR_TEXT=''
    COLOR_SUBTEXT=''
    COLOR_MAuve=''
    COLOR_Mauve=''
    COLOR_RED=''
    COLOR_PEACH=''
    COLOR_YELLOW=''
    COLOR_GREEN=''
    COLOR_TEAL=''
    COLOR_SKY=''
    COLOR_LAVENDER=''
    COLOR_BOLD=''
    COLOR_DIM=''
    COLOR_ITALIC=''
    COLOR_UNDERLINE=''
    COLOR_RESET=''
fi

# Add alias for backward compatibility (COLOR_Mauve vs COLOR_MAuve)
if [ -z "${COLOR_Mauve:-}" ] && [ -n "${COLOR_MAuve:-}" ]; then
    COLOR_Mauve="$COLOR_MAuve"
fi

# --- LOGGING WITH COLORS ---
color_log() {
    local level="$1"
    local message="$2"
    
    case "$level" in
        INFO)
            echo -e "${COLOR_SKY}[INFO]${COLOR_RESET} $message"
            ;;
        SUCCESS)
            echo -e "${COLOR_GREEN}[SUCCESS]${COLOR_RESET} $message"
            ;;
        WARNING)
            echo -e "${COLOR_YELLOW}[WARNING]${COLOR_RESET} $message"
            ;;
        ERROR)
            echo -e "${COLOR_RED}[ERROR]${COLOR_RESET} $message" >&2
            ;;
        DEBUG)
            echo -e "${COLOR_LAVENDER}[DEBUG]${COLOR_RESET} $message"
            ;;
        TITLE)
            echo -e "${COLOR_MAuve}${COLOR_BOLD}$message${COLOR_RESET}"
            ;;
        SUBTITLE)
            echo -e "${COLOR_TEXT}${message}${COLOR_RESET}"
            ;;
        *)
            echo "$message"
            ;;
    esac
}

# --- STATUS INDICATORS ---
status_ok() {
    echo -e "${COLOR_GREEN}✓${COLOR_RESET} $*"
}

status_fail() {
    echo -e "${COLOR_RED}✗${COLOR_RESET} $*"
}

status_info() {
    echo -e "${COLOR_SKY}ℹ${COLOR_RESET} $*"
}

status_warn() {
    echo -e "${COLOR_YELLOW}⚠${COLOR_RESET} $*"
}

# --- PROGRESS BAR ---
progress_bar() {
    local current=$1
    local total=$2
    local width=${3:-40}
    
    local percentage=$((current * 100 / total))
    local filled=$((width * percentage / 100))
    local empty=$((width - filled))
    
    echo -en "\r["
    printf "%${filled}s" | tr ' ' '='
    printf "%${empty}s" | tr ' ' ' '
    echo -en "] ${percentage}%"
}

# --- BOX DRAWING ---
box_title() {
    local title="$1"
    local length=${#title}
    local padding=2
    local total_length=$((length + padding * 2 + 2))
    
    echo -e "${COLOR_MAuve}${COLOR_BOLD}┌$(printf '─%.0s' $(seq 1 $total_length))┐${COLOR_RESET}"
    echo -e "${COLOR_MAuve}${COLOR_BOLD}│ ${COLOR_TEXT}${title} ${COLOR_MAuve}${COLOR_BOLD}│${COLOR_RESET}"
    echo -e "${COLOR_MAuve}${COLOR_BOLD}└$(printf '─%.0s' $(seq 1 $total_length))┘${COLOR_RESET}"
}

box_content() {
    local content="$1"
    echo -e "${COLOR_SURFACE}│ ${COLOR_TEXT}$content${COLOR_RESET}"
}

box_footer() {
    echo -e "${COLOR_SURFACE}└$(printf '─%.0s' $(seq 1 40))┘${COLOR_RESET}"
}

# --- MARK VARIABLES READONLY (only on first load) ---
if [ -z "${COLORS_READONLY_DONE:-}" ]; then
    readonly COLOR_BASE COLOR_MANTLE COLOR_SURFACE
    readonly COLOR_TEXT COLOR_SUBTEXT
    readonly COLOR_MAuve COLOR_Mauve COLOR_RED COLOR_PEACH COLOR_YELLOW COLOR_GREEN COLOR_TEAL COLOR_SKY COLOR_LAVENDER
    readonly COLOR_BOLD COLOR_DIM COLOR_ITALIC COLOR_UNDERLINE COLOR_RESET
    readonly COLOR_INFO COLOR_SUCCESS COLOR_WARNING COLOR_ERROR COLOR_DEBUG
    readonly COLORS_READONLY_DONE=true
fi

# --- EXPORT FUNCTIONS ---
export -f color_log
export -f status_ok
export -f status_fail
export -f status_info
export -f status_warn
export -f progress_bar
export -f box_title
export -f box_content
export -f box_footer
