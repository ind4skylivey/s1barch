#!/bin/bash
# ============================================================
#  AUDIO SWITCH DWM - Audio switch for DWM (X11)
#  Uses: xdotool, xrandr
#  ============================================================

set -euo pipefail

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

# Check environment
ENV_FILE="$HOME/Desktop/S1Bs1stem/config/current_env.yaml"
CURRENT_ENV=$(cat "$ENV_FILE" 2>/dev/null | grep "^current:" | cut -d: -f2 | tr -d ' ')
readonly CURRENT_ENV

if [ "$CURRENT_ENV" != "dwm" ]; then
    log_error "This script requires DWM (X11) environment"
    log_warn "Detected environment: $CURRENT_ENV"
    exit 1
fi

# Get current default sink with pactl (if available)
if command -v pactl &>/dev/null; then
    current_sink=$(pactl get-default-sink 2>/dev/null || echo "")
    
    # Get all sinks
    sinks_data=$(pactl -f json list sinks 2>/dev/null)
    
    if [ -z "$sinks_data" ]; then
        log_error "No audio sinks found"
        exit 1
    fi
    
    # Parse and find next sink
    next_sink=$(echo "$sinks_data" | jq -r --arg current "$current_sink" '
      [.[] | select((.ports | length == 0) or ([.ports[]? | .availability != "not available"] | any))]
      | sort_by(.name)
      | ($sinks | map(.name) | index($current)) as $idx
      | (if $idx == null then 0 else ($idx + 1) % length end)
      | .[$sinks | map(.name)[.]]
    ')
    
    if [ -z "$next_sink" ]; then
        log_error "Could not determine next audio sink"
        exit 1
    fi
    
    # Set default sink
    pactl set-default-sink "$next_sink" 2>/dev/null
    log_success "Audio switched to: $next_sink"
    
    # Show notification (optional)
    if command -v notify-send &>/dev/null; then
        notify-send "Audio" "Switched to: $next_sink" --icon="audio-volume-high" --urgity=low
    fi
else
    log_warn "PulseAudio (pactl) not found, audio switching unavailable"
    log_info "To enable audio switching, install: sudo pacman -S pulseaudio"
fi
