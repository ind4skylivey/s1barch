#!/bin/bash
# ============================================================
#  VOLUME SLIDER - Volume control with wofi/rofi
#  Dependencies: pactl, rofi or wofi, notify-send
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

# Configuration
INCREMENT=5
MAX_VOLUME=150

# Get current volume
get_current_volume() {
    pactl get-sink-volume @DEFAULT_SINK@
}

# Set volume
set_volume() {
    local vol="$1"
    pactl set-sink-volume @DEFAULT_SINK@ "$vol"
    log_info "Volume set to $vol%"
}

# Mute/Unmute
toggle_mute() {
    audio_toggle_mute
}

# Volume slider menu
volume_menu() {
    local current
    current=$(get_current_volume)
    
    local options="Up (+5%)
Down (-5%)
Toggle Mute
Set Custom
Exit"
    
    local choice
    choice=$(echo -e "$options" | rofi -dmenu -p "Volume: ${current}%" -theme "$HOME/.config/rofi/cyberpunk")
    
    case "$choice" in
        "Up (+5%)")
            local new_vol=$((current + INCREMENT))
            [ "$new_vol" -gt "$MAX_VOLUME" ] && new_vol="$MAX_VOLUME"
            set_volume "$new_vol"
            ;;
        "Down (-5%)")
            local new_vol=$((current - INCREMENT))
            [ "$new_vol" -lt 0 ] && new_vol=0
            set_volume "$new_vol"
            ;;
        "Toggle Mute")
            toggle_mute
            ;;
        "Set Custom")
            local custom_vol
            custom_vol=$(echo "" | rofi -dmenu -p "Set volume (0-$MAX_VOLUME):" -theme "$HOME/.config/rofi/cyberpunk")
            if [[ "$custom_vol" =~ ^[0-9]+$ ]]; then
                [ "$custom_vol" -gt "$MAX_VOLUME" ] && custom_vol="$MAX_VOLUME"
                set_volume "$custom_vol"
            fi
            ;;
        "Exit")
            return 0
            ;;
    esac
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --up)
            audio_volume_up "$INCREMENT"
            shift
            ;;
        --down)
            audio_volume_down "$INCREMENT"
            shift
            ;;
        --toggle)
            toggle_mute
            shift
            ;;
        --set)
            if [ -n "$2" ] && [[ "$2" =~ ^[0-9]+$ ]]; then
                vol="$2"
                [ "$vol" -gt "$MAX_VOLUME" ] && vol="$MAX_VOLUME"
                set_volume "$vol"
            fi
            shift 2
            ;;
        --menu)
            volume_menu
            shift
            ;;
        *)
            log_error "Unknown option: $1"
            echo "Usage: $0 [--up|--down|--toggle|--set <vol>|--menu]"
            exit 1
            ;;
    esac
done

# Default: show menu
volume_menu

log_success "Done"
