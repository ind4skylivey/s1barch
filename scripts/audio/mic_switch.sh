#!/bin/bash
# ============================================================
#  MIC SWITCH - Switch between microphones
#  Dependencies: pactl, rofi or wofi
#  ============================================================

set -euo pipefail

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/functions.sh"
source "$SCRIPT_DIR/../common/logger.sh"
source "$SCRIPT_DIR/../common/colors.sh"

# Check audio system
AUDIO_SYSTEM=$(get_audio_system)
readonly AUDIO_SYSTEM
if [ "$AUDIO_SYSTEM" = "none" ]; then
    log_error "No audio system found (PulseAudio or PipeWire)"
    log_info "Install: sudo pacman -S pulseaudio (or pipewire wireplumber)"
    exit 1
fi

log_info "Audio system: $AUDIO_SYSTEM"

# Get current default microphone
get_current_mic() {
    pactl get-default-source
}

# List all microphones
list_microphones() {
    pactl list short sources | grep -i input
}

# Set default microphone
set_mic() {
    local mic_name="$1"
    pactl set-default-source "$mic_name"
    log_info "Microphone set to: $mic_name"
    notify-send "Microphone" "Switched to $mic_name" 2>/dev/null || true
}

# Mute/Unmute microphone
toggle_mute_mute() {
    audio_mic_toggle_mute
    notify-send "Microphone" "Toggled mute" 2>/dev/null || true
}

# Microphone menu
mic_menu() {
    local current
    current=$(get_current_mic)
    
    local mics
    mics=$(list_microphones)
    
    local options
    options="Current: $current
---
$(echo "$mics" | nl -v -w 4 -s '  ')
Toggle Mute
Refresh List
Exit"
    
    local choice
    choice=$(echo "$options" | rofi -dmenu -p "Select Microphone:" -theme "$HOME/.config/rofi/cyberpunk")
    
    case "$choice" in
        "Toggle Mute")
            toggle_mute_mute
            ;;
        "Refresh List")
            mic_menu
            ;;
        "Exit")
            return 0
            ;;
        "Current: $current"|"Exit")
            return 0
            ;;
        *)
            local selected_mic
            selected_mic=$(echo "$choice" | awk '{print $2}')
            if [ -n "$selected_mic" ]; then
                set_mic "$selected_mic"
            fi
            ;;
    esac
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --list)
            list_microphones
            shift
            ;;
        --set)
            if [ -n "$2" ]; then
                set_mic "$2"
            fi
            shift 2
            ;;
        --toggle)
            toggle_mute_mute
            shift
            ;;
        --menu)
            mic_menu
            shift
            ;;
        *)
            log_error "Unknown option: $1"
            echo "Usage: $0 [--list|--set <mic>|--toggle|--menu]"
            exit 1
            ;;
    esac
done

# Default: show menu
mic_menu

log_success "Done"
