#!/bin/bash
# ============================================================
#  S1Bs1stem - COMMON FUNCTIONS LIBRARY
#  ============================================================
#  Usage: source ~/Desktop/S1Bs1stem/scripts/common/functions.sh
#  Inspired by: S1B dotfiles
#  Author: S1B System
#  License: MIT
#  Version: 1.0.0
#  ============================================================

# --- CONSTANTS ---
readonly S1B_ROOT="$HOME/Desktop/S1Bs1stem"
# shellcheck disable=SC2034
readonly S1B_SCRIPTS="$S1B_ROOT/scripts"
# shellcheck disable=SC2034
readonly S1B_CONFIGS="$S1B_ROOT/configs"
# shellcheck disable=SC2034
readonly S1B_INSTALL="$S1B_ROOT/install"
readonly S1B_LOGS="$HOME/.s1b_logs"
readonly S1B_BACKUP="$HOME/.s1b_backup"

# Create directories if they don't exist
mkdir -p "$S1B_LOGS"
mkdir -p "$S1B_BACKUP"

# --- PATH RESOLUTION ---
get_script_dir() {
    local source="${BASH_SOURCE[0]}"
    while [ -h "$source" ]; do
        source="$(readlink "$source")"
    done
    echo "$(cd -P "$(dirname "$source")" && pwd)"
}

# --- DEPENDENCY CHECK ---
check_dependencies() {
    local missing=()
    for cmd in "$@"; do
        if ! command -v "$cmd" &>/dev/null; then
            missing+=("$cmd")
        fi
    done
    
    if [ ${#missing[@]} -gt 0 ]; then
        echo "ERROR: Missing dependencies: ${missing[*]}"
        return 1
    fi
    return 0
}

# --- SYSTEM CHECKS ---
check_dwm_running() {
    pgrep -x "dwm" &>/dev/null
}

check_waybar_running() {
    pgrep -x "waybar" &>/dev/null
}

check_git_repo() {
    git rev-parse --git-dir &>/dev/null
}

is_arch() {
    [ -f "/etc/arch-release" ]
}

# --- BACKUP HELPERS ---
backup_file() {
    local file="$1"
    local backup_dir
    backup_dir="$S1B_BACKUP/backup_$(date +%Y%m%d_%H%M%S)"
    
    if [ -e "$file" ] && [ ! -L "$file" ]; then
        mkdir -p "$backup_dir"
        cp "$file" "$backup_dir/"
        echo "$backup_dir/$(basename "$file")"
    fi
}

backup_dir() {
    local dir="$1"
    local backup_dir
    backup_dir="$S1B_BACKUP/backup_$(date +%Y%m%d_%H%M%S)"
    
    if [ -d "$dir" ]; then
        mkdir -p "$backup_dir"
        cp -r "$dir" "$backup_dir/$(basename "$dir")"
        echo "$backup_dir/$(basename "$dir")"
    fi
}

# --- LOCK FILE MANAGEMENT ---
acquire_lock() {
    local lock_file="$1"
    if [ -e "$lock_file" ]; then
        echo "ERROR: Lock file exists: $lock_file"
        echo "Another instance may be running"
        exit 1
    fi
    touch "$lock_file"
}

release_lock() {
    local lock_file="$1"
    if [ -f "$lock_file" ]; then
        rm -f "$lock_file" 2>/dev/null || true
    fi
}

# --- USER CONFIRMATION ---
confirm_action() {
    local message="$1"
    # shellcheck disable=SC2034
    local default="${2:-n}"
    
    echo -n "$message [y/N]: "
    read -r reply
    
    if [[ "$reply" =~ ^[Yy]$ ]]; then
        return 0
    else
        return 1
    fi
}

# --- SAFE EXECUTION ---
safe_source() {
    local file="$1"
    if [ -f "$file" ]; then
        # shellcheck source=/dev/null
        source "$file"
    else
        echo "ERROR: Cannot source: $file (file not found)"
        return 1
    fi
}

# --- WORKFLOW HELPERS ---
is_workflow() {
    local workflow="$1"
    [[ "$workflow" =~ ^(local|remote|write|redteam)$ ]]
}

get_workflow_config() {
    local workflow="$1"
    echo "$S1B_ROOT/workflow/profiles/${workflow}.md"
}

# --- DWM HELPERS ---
dwm_restart() {
    echo "INFO: Restarting DWM..."
    killall dwm
}

dwm_reload_config() {
    echo "INFO: Reloading DWM config..."
    killall -HUP dwm
}

# --- WAYBAR HELPERS ---
waybar_restart() {
    echo "INFO: Restarting Waybar..."
    killall waybar
    waybar &
}

waybar_reload() {
    echo "INFO: Reloading Waybar..."
    pkill -SIGUSR1 waybar
}

# --- STRING HELPERS ---
trim() {
    local var="$*"
    var="${var#"${var%%[![:space:]]*}"}"
    var="${var%"${var##*[![:space:]]}"}"
    printf '%s' "$var"
}

# --- PACKAGE HELPERS ---
is_package_installed() {
    pacman -Q "$1" &>/dev/null
}

install_package_if_missing() {
    local pkg="$1"
    if ! is_package_installed "$pkg"; then
        echo "INFO: Installing $pkg..."
        sudo pacman -S --needed --noconfirm "$pkg"
    else
        echo "INFO: $pkg is already installed"
    fi
}

# --- COLOR HELPERS ---
set_colors_if_terminal() {
    if [[ -t 1 ]] && command -v tput &>/dev/null; then
        if (( $(tput colors 2>/dev/null || echo 0) >= 8 )); then
            return 0
        fi
    fi
    return 1
}

# --- SYSTEM INFO ---
get_memory_usage() {
    free | awk '/Mem:/ {printf "%.0f%%", $3/$2 * 100.0}'
}

get_disk_usage() {
    df -h "$HOME" | awk 'NR==2 {print $5}'
}

get_cpu_cores() {
    nproc
}

get_gpu_info() {
    if command -v nvidia-smi &>/dev/null; then
        nvidia-smi --query-gpu=name --format=csv,noheader | head -1
    elif command -v lspci &>/dev/null; then
        lspci | grep -i vga | head -1
    else
        echo "Unknown GPU"
    fi
}

# --- FILE HELPERS ---
ensure_dir_exists() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
    fi
}

file_older_than_days() {
    local file="$1"
    local days="$2"
    
    if [ ! -f "$file" ]; then
        return 0
    fi
    
    local file_age
    file_age=$((($(date +%s) - $(stat -c %Y "$file")) / 86400))
    
    if [ $file_age -gt $days ]; then
        return 0
    else
        return 1
    fi
}

# --- NETWORK HELPERS ---
is_connected() {
    ping -c 1 -W 2 archlinux.org &>/dev/null
}

get_local_ip() {
    ip route get 1 | awk '{print $7}' | head -1
}

# --- HARDWARE DETECTION ---
has_battery() {
    upower -e 2>/dev/null | grep -q "battery_"
}

has_lid() {
    [ -e "/proc/acpi/button/lid/LID/state" ] || [ -e "/proc/acpi/button/lid/LID0/state" ]
}

get_battery_count() {
    upower -e 2>/dev/null | grep -c "battery_" || echo 0
}

# --- AUDIO SYSTEM DETECTION ---
has_pulseaudio() {
    command -v pactl &>/dev/null && pactl info &>/dev/null
}

has_pipewire() {
    command -v pw-cli &>/dev/null && pw-cli &>/dev/null
}

get_audio_system() {
    if has_pipewire; then
        echo "pipewire"
    elif has_pulseaudio; then
        echo "pulseaudio"
    else
        echo "none"
    fi
}

get_audio_command() {
    local audio_system
    audio_system="$(get_audio_system)"
    
    case "$audio_system" in
        pipewire|pulseaudio)
            echo "pactl"
            ;;
        *)
            echo "none"
            ;;
    esac
}

audio_volume_up() {
    local cmd
    cmd="$(get_audio_command)"
    
    if [ "$cmd" != "none" ]; then
        pactl set-sink-volume @DEFAULT_SINK@ +5%
    else
        echo "ERROR: No audio system detected"
        return 1
    fi
}

audio_volume_down() {
    local cmd
    cmd="$(get_audio_command)"
    
    if [ "$cmd" != "none" ]; then
        pactl set-sink-volume @DEFAULT_SINK@ -5%
    else
        echo "ERROR: No audio system detected"
        return 1
    fi
}

audio_toggle_mute() {
    local cmd
    cmd="$(get_audio_command)"
    
    if [ "$cmd" != "none" ]; then
        pactl set-sink-mute @DEFAULT_SINK@ toggle
    else
        echo "ERROR: No audio system detected"
        return 1
    fi
}

audio_mic_toggle_mute() {
    local cmd
    cmd="$(get_audio_command)"
    
    if [ "$cmd" != "none" ]; then
        pactl set-source-mute @DEFAULT_SOURCE@ toggle
    else
        echo "ERROR: No audio system detected"
        return 1
    fi
}

# --- WORKFLOW SWITCHING ---
switch_workflow() {
    local workflow="$1"
    
    if ! is_workflow "$workflow"; then
        echo "ERROR: Invalid workflow: $workflow"
        echo "Valid workflows: local, remote, write, redteam"
        return 1
    fi
    
    echo "INFO: Switching to workflow: $workflow"
    
    # Read workflow profile
    local config_file
    config_file="$(get_workflow_config "$workflow")"
    
    if [ -f "$config_file" ]; then
        echo "INFO: Loading workflow config from: $config_file"
        # shellcheck source=/dev/null
        source "$config_file"
    else
        echo "ERROR: Workflow config not found: $config_file"
        return 1
    fi
}

# --- SESSION MANAGEMENT ---
start_session() {
    local session_name="$1"
    local log_file
    log_file="$S1B_LOGS/sessions/${session_name}_$(date +%Y%m%d_%H%M%S).log"
    
    mkdir -p "$(dirname "$log_file")"
    
    echo "=== Session started at $(date) ===" > "$log_file"
    echo "INFO: Session $session_name started"
    
    echo "$log_file"
}

end_session() {
    local log_file="$1"
    if [ -f "$log_file" ]; then
        echo "=== Session ended at $(date) ===" >> "$log_file"
        echo "INFO: Session logged to: $log_file"
    fi
}

# --- ADDITIONAL UTILITY FUNCTIONS (Documented API) ---

# Alias for trim() to match documentation
trim_string() {
    trim "$@"
}

# Check if string is valid (non-empty, not just whitespace)
is_valid_string() {
    local str="$1"
    if [[ -z "${str// }" ]]; then
        return 1
    fi
    return 0
}

# Check if input is a valid number (integer or float)
is_valid_number() {
    local num="$1"
    if [[ "$num" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
        return 0
    fi
    return 1
}

# Check if path is valid and exists
is_valid_path() {
    local path="$1"
    if [[ -e "$path" ]]; then
        return 0
    fi
    return 1
}

# Check if file exists
file_exists() {
    local file="$1"
    [[ -f "$file" ]]
}

# Check if directory exists
dir_exists() {
    local dir="$1"
    [[ -d "$dir" ]]
}

# Alias for ensure_dir_exists() to match documentation
create_dir() {
    ensure_dir_exists "$1"
}

# Check/create directory with logging
check_dir() {
    local dir="$1"
    local msg="${2:-Directory}"
    
    if dir_exists "$dir"; then
        log_info "$msg already exists: $dir"
        return 0
    else
        log_info "Creating $msg: $dir"
        create_dir "$dir"
        return 0
    fi
}

# --- EXPORTED FUNCTIONS (for use in other scripts) ---
export -f get_script_dir
export -f check_dependencies
export -f check_dwm_running
export -f check_waybar_running
export -f backup_file
export -f backup_dir
export -f acquire_lock
export -f release_lock
export -f confirm_action
export -f safe_source
export -f switch_workflow
export -f is_workflow
export -f is_package_installed
export -f install_package_if_missing
export -f trim
export -f ensure_dir_exists
export -f file_older_than_days
export -f is_connected
export -f get_local_ip
export -f has_battery
export -f has_lid
export -f get_battery_count
export -f has_pulseaudio
export -f has_pipewire
export -f get_audio_system
export -f get_audio_command
export -f audio_volume_up
export -f audio_volume_down
export -f audio_toggle_mute
export -f audio_mic_toggle_mute

# New documented API functions
export -f trim_string
export -f is_valid_string
export -f is_valid_number
export -f is_valid_path
export -f file_exists
export -f dir_exists
export -f create_dir
export -f check_dir
