#!/bin/bash
# ============================================================
#  AUDIO OUTPUT - Switch between audio output devices
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

# Get current default sink
get_current_output() {
    pactl get-default-sink
}

# List all output devices
list_outputs() {
    pactl list short sinks
}

# Set default output device
set_output() {
    local sink_name="$1"
    pactl set-default-sink "$sink_name"
    log_info "Audio output set to: $sink_name"
    notify-send "Audio Output" "Switched to $sink_name" 2>/dev/null || true
}

# Move all streams to new output
move_streams() {
    local sink_name="$1"
    pactl move-sink-input @DEFAULT_SINK@ "$sink_name"
    log_info "Moved all audio streams to: $sink_name"
}

# Audio output menu
audio_menu() {
    local current
    current=$(get_current_output)
    
    local outputs
    outputs=$(list_outputs)
    
    local options
    options="Current: $current
---
$(echo "$outputs" | nl -v -w 4 -s '  ')
Move Streams to Selected
Refresh List
Exit"
    
    local choice
    choice=$(echo "$options" | rofi -dmenu -p "Select Output Device:" -theme "$HOME/.config/rofi/cyberpunk")
    
    case "$choice" in
        "Move Streams to Selected")
            local sink
            sink=$(echo "$outputs" | rofi -dmenu -p "Select destination sink:" -theme "$HOME/.config/rofi/cyberpunk")
            if [ -n "$sink" ]; then
                move_streams "$sink"
            fi
            ;;
        "Refresh List")
            audio_menu
            ;;
        "Exit")
            return 0
            ;;
        "Current: $current"|"Exit")
            return 0
            ;;
        *)
            local selected_sink
            selected_sink=$(echo "$choice" | awk '{print $2}')
            if [ -n "$selected_sink" ]; then
                set_output "$selected_sink"
            fi
            ;;
    esac
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --list)
            list_outputs
            shift
            ;;
        --set)
            if [ -n "$2" ]; then
                set_output "$2"
            fi
            shift 2
            ;;
        --move)
            if [ -n "$2" ]; then
                move_streams "$2"
            fi
            shift 2
            ;;
        --menu)
            audio_menu
            shift
            ;;
        *)
            log_error "Unknown option: $1"
            echo "Usage: $0 [--list|--set <sink>|--move <sink>|--menu]"
            exit 1
            ;;
    esac
done

# Default: show menu
audio_menu

log_success "Done"
