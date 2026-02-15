#!/bin/bash
# ============================================================
#  AUDIO SWITCH WAYLAND - Audio switch for Wayland/Waybar
#  Uses: pactl, jq, swayosd-client (for notifications)
#  ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/functions.sh"
source "$SCRIPT_DIR/../common/logger.sh"
source "$SCRIPT_DIR/../common/colors.sh"

# Check environment
ENV_FILE="$HOME/Desktop/S1Bs1stem/config/current_env.yaml"
CURRENT_ENV=$(grep "^current:" "$ENV_FILE" 2>/dev/null | cut -d: -f2)
readonly CURRENT_ENV

if [ "$CURRENT_ENV" != "wayland" ] && [ "$CURRENT_ENV" != "waybar" ]; then
    log_error "This script requires Wayland/Waybar environment"
    log_info "Current environment: $CURRENT_ENV"
    exit 1
fi

# Get current default sink
current_sink=$(pactl get-default-sink 2>/dev/null || echo "")

# Get all available sinks with JSON
sinks_data=$(pactl -f json list sinks 2>/dev/null)

if [ -z "$sinks_data" ]; then
    log_error "No audio sinks found"
    exit 1
fi

# Parse sinks and find next one
next_sink=$(echo "$sinks_data" | jq -r --arg current "$current_sink" '
  [.[] | select((.ports | length == 0) or ([.ports[]? | .availability != "not available"] | any))]
  | sort_by(.name)
  | ($sinks | map(.name) | index($current)) as $idx
  | if $idx == null then 0 else ($idx + 1) % length end)
  | .[$sinks | map(.name)[.]]
')

if [ -z "$next_sink" ]; then
    log_error "Could not determine next audio sink"
    exit 1
fi

# Get sink description
next_desc=$(echo "$sinks_data" | jq -r --arg name "$next_sink" '
  .[] | select(.name == $name)
  | (.description // .properties."device.description" // .properties."node.description" // .properties."device.product.name" // .name)
')

log_info "Switching to: $next_desc"

# Set default sink
if ! pactl set-default-sink "$next_sink" 2>/dev/null; then
    log_error "Failed to set default sink: $next_sink"
    exit 1
fi

# Move all playing streams to new sink
while IFS=$'\t' read -r input_id _; do
    [[ -n "$input_id" ]] && pactl move-sink-input "$input_id" "$next_sink" 2>/dev/null || true
done < <(pactl list short sink-inputs 2>/dev/null)

# Show notification (Waybar integration)
if command -v swayosd-client &>/dev/null; then
    swayosd-client --custom-message "Audio: $next_desc" --custom-icon "audio-volume-high-symbolic" &>/dev/null || true
elif command -v notify-send &>/dev/null; then
    notify-send "Audio Output" "Switched to: $next_desc" --icon="audio-volume-high" --urgity=normal &>/dev/null || true
fi

log_success "Audio switched to: $next_desc"
exit 0
