#!/bin/bash
# ============================================================
#  AUDIO SYSTEM DETECTION TEST
#  ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/common/functions.sh"
source "$SCRIPT_DIR/../scripts/common/logger.sh"
source "$SCRIPT_DIR/../scripts/common/colors.sh"

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║   Audio System Detection Test               ║"
echo "╚══════════════════════════════════════════╝"
echo ""

# Test 1: PulseAudio detection
echo "━━━ PulseAudio Detection ━━━"
if has_pulseaudio; then
    echo "✓ PulseAudio detected"
    pactl --version
else
    echo "⚠ PulseAudio not found"
fi

echo ""

# Test 2: PipeWire detection
echo "━━━ PipeWire Detection ━━━"
if has_pipewire; then
    echo "✓ PipeWire detected"
    if command -v pw-cli &>/dev/null; then
        pw-cli --version
    fi
else
    echo "⚠ PipeWire not found"
fi

echo ""

# Test 3: Get audio system
echo "━━━ Audio System Detection ━━━"
AUDIO_SYSTEM=$(get_audio_system)
readonly AUDIO_SYSTEM
echo "Detected audio system: $AUDIO_SYSTEM"

case "$AUDIO_SYSTEM" in
    pulseaudio)
        echo -e "${COLOR_GREEN}✓ Using PulseAudio${COLOR_RESET}"
        ;;
    pipewire)
        echo -e "${COLOR_GREEN}✓ Using PipeWire${COLOR_RESET}"
        ;;
    none)
        echo -e "${COLOR_RED}✗ No audio system found${COLOR_RESET}"
        ;;
esac

echo ""

# Test 4: Audio commands
echo "━━━ Audio Commands Test ━━━"

if [ "$AUDIO_SYSTEM" != "none" ]; then
    echo "Testing audio commands:"
    echo "  - get-default-sink: $(get_audio_command get-default-sink)"
    echo "  - set-default-sink: $(get_audio_command set-default-sink)"
    echo "  - get-sink-mute: $(get_audio_command get-sink-mute)"
    echo "  - set-sink-mute: $(get_audio_command set-sink-mute)"
    echo "  - list-sinks: $(get_audio_command list-sinks)"
fi

echo ""

# Test 5: Get current devices
echo "━━━ Current Audio Devices ━━━"

if [ "$AUDIO_SYSTEM" = "pulseaudio" ] || [ "$AUDIO_SYSTEM" = "pipewire" ]; then
    echo "Default Sink:"
    pactl get-default-sink 2>/dev/null || echo "  (Error getting sink)"
    echo ""
    echo "Default Source:"
    pactl get-default-source 2>/dev/null || echo "  (Error getting source)"
    echo ""
    echo "Available Sinks:"
    pactl list short sinks 2>/dev/null | head -5 || echo "  (Error listing sinks)"
    echo ""
    echo "Available Sources:"
    pactl list short sources 2>/dev/null | head -5 || echo "  (Error listing sources)"
else
    echo "⚠ No audio system available"
fi

echo ""

# Test 6: Volume control
echo "━━━ Volume Control Test ━━━"

if [ "$AUDIO_SYSTEM" = "pulseaudio" ] || [ "$AUDIO_SYSTEM" = "pipewire" ]; then
    echo "Testing volume up (+5%)..."
    audio_volume_up 5
    sleep 0.5

    echo "Testing volume down (-5%)..."
    audio_volume_down 5
    sleep 0.5

    echo "Testing toggle mute..."
    audio_toggle_mute
    sleep 0.5

    echo "Testing toggle mute (restore)..."
    audio_toggle_mute
else
    echo "⚠ Volume control not available"
fi

echo ""

# Test 7: Mic control
echo "━━━ Microphone Control Test ━━━"

if [ "$AUDIO_SYSTEM" = "pulseaudio" ] || [ "$AUDIO_SYSTEM" = "pipewire" ]; then
    echo "Testing mic toggle mute..."
    audio_mic_toggle_mute
    sleep 0.5

    echo "Testing mic toggle mute (restore)..."
    audio_mic_toggle_mute
else
    echo "⚠ Microphone control not available"
fi

echo ""

# Summary
echo "━━━ Summary ━━━"
echo ""
echo "Audio System: $AUDIO_SYSTEM"
echo "PulseAudio: $(has_pulseaudio && echo "Available" || echo "Not available")"
echo "PipeWire: $(has_pipewire && echo "Available" || echo "Not available")"
echo ""

if [ "$AUDIO_SYSTEM" != "none" ]; then
    echo -e "${COLOR_GREEN}✓ Audio system working correctly${COLOR_RESET}"
    exit 0
else
    echo -e "${COLOR_RED}✗ No audio system detected${COLOR_RESET}"
    echo ""
    echo "To install PulseAudio:"
    echo "  sudo pacman -S pulseaudio pulseaudio-alsa"
    echo ""
    echo "To install PipeWire:"
    echo "  sudo pacman -S pipewire pipewire-alsa pipewire-pulse wireplumber"
    exit 1
fi
