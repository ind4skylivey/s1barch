# Audio Management System

Complete guide for audio management in S1Bs1stem with automatic PipeWire/PulseAudio detection.

## Table of Contents
- [Audio System Detection](#audio-system-detection)
- [Audio Scripts](#audio-scripts)
- [Usage Examples](#usage-examples)
- [Troubleshooting](#troubleshooting)

---

## Audio System Detection

### How Detection Works

S1Bs1stem automatically detects which audio system is installed:

| Audio System | Detection Method | Support |
|:---|:---|:---:|
| **PipeWire** | `pw-cli` command | ✅ Full support |
| **PulseAudio** | `pactl` command | ✅ Full support |
| **None** | No command available | ⚠️ Audio disabled |

### Detection Functions

All audio scripts use these helper functions from `scripts/common/functions.sh`:

| Function | Returns | Description |
|:---|:---:|:---:|
| `has_pipewire()` | 0/1 (false/true) | Check if PipeWire is installed |
| `has_pulseaudio()` | 0/1 (false/true) | Check if PulseAudio is installed |
| `get_audio_system()` | "pipewire", "pulseaudio", or "none" | Get detected audio system |
| `get_audio_command()` | "pactl" or "none" | Get appropriate command |

### Usage Example

```bash
# Source common functions
source ~/Desktop/S1Bs1stem/scripts/common/functions.sh

# Check audio system
AUDIO_SYSTEM=$(get_audio_system)
echo "Audio system: $AUDIO_SYSTEM"  # pipewire, pulseaudio, or none

# Check if command available
AUDIO_CMD=$(get_audio_command)
echo "Audio command: $AUDIO_CMD"  # pactl or none

# Use appropriate command automatically
case "$AUDIO_SYSTEM" in
    pipewire|pulseaudio)
        echo "Audio system is $AUDIO_SYSTEM (supports: pactl)"
        ;;
    none)
        echo "No audio system detected. Audio scripts will not work."
        ;;
esac
```

---

## Audio Scripts

### Script Overview

| Script | Description | Status |
|:---|:---|:---:|
| **audio_output.sh** | Audio output device switching | ✅ Complete |
| **volume_slider.sh** | Volume control (up, down, set, mute) | ✅ Complete |
| **mic_switch.sh** | Microphone toggle | ✅ Complete |
| **audio_switch_dwm.sh** | DWM-specific audio switching | ✅ Complete |
| **audio_switch_wayland.sh** | Wayland-specific audio switching | ✅ Complete |

### Script Locations

All audio scripts are in `~/Desktop/S1Bs1stem/scripts/audio/`

---

## Usage Examples

### Volume Control

```bash
# Volume up by 5%
~/Desktop/S1Bs1stem/scripts/audio/volume_slider.sh up

# Volume down by 5%
~/Desktop/S1Bs1stem/scripts/audio/volume_slider.sh down

# Set volume to 50%
~/Desktop/S1Bs1stem/scripts/audio/volume_slider.sh set 50

# Toggle mute
~/Desktop/S1Bs1stem/scripts/audio/volume_slider.sh mute

# Get current volume
~/Desktop/S1Bs1stem/scripts/audio/volume_slider.sh get
```

### Microphone Toggle

```bash
# Toggle microphone mute/unmute
~/Desktop/S1Bs1stem/scripts/audio/mic_switch.sh
```

### Audio Output Switching

```bash
# Launch Rofi menu to select output device
~/Desktop/S1Bs1Bs1stem/scripts/audio/audio_output.sh --menu

# List all available output devices
~/Desktop/S1Bs1stem/scripts/audio/audio_output.sh --list

# Set specific output device by name
~/Desktop/S1Bs1stem/scripts/audio_output.sh --set "alsa_output.pci-0000_00"

# Move all streams to specific output
~/Desktop/S1Bs1stem/scripts/audio/audio_output.sh --move "alsa_output.pci-0000_00"
```

### Desktop Environment Scripts

```bash
# DWM-specific audio switching
~/Desktop/S1Bs1stem/scripts/audio/audio_switch_dwm.sh

# Wayland-specific audio switching
~/Desktop/S1Bs1stem/scripts/audio_switch_wayland.sh
```

---

## Troubleshooting

### No Audio System Found

**Problem:** Scripts say "No audio system found"

**Diagnosis:** PipeWire or PulseAudio is not installed

**Solution:**
```bash
# Check if PipeWire is installed
command -v pactl || echo "pactl NOT INSTALLED"
command -v pw-cli || echo "pw-cli NOT INSTALLED"

# Check if PulseAudio is installed
command -v pulseaudio || echo "pulseaudio NOT INSTALLED"

# Install PipeWire (recommended for Wayland)
sudo pacman -S pipewire pipewire-pulseaudio wireplumber

# Install PulseAudio (alternative for X11)
sudo pacman -S pulseaudio pulseaudio-alsa

# Restart audio service
systemctl --user restart pipewire pipewire-pulseaudio wireplumber
# OR
systemctl --user restart pulseaudio

# Test audio
pactl info  # Should show audio devices
```

### Volume Not Changing

**Problem:** Volume slider doesn't change volume

**Diagnosis:** Audio system not detected or wrong device

**Solution:**
```bash
# Check audio system
source ~/Desktop/S1Bs1stem/scripts/common/functions.sh
get_audio_system

# List audio devices
pactl list short sinks
pactl list short sources

# Check if default sink exists
pactl get-default-sink
pactl get-default-source

# Manually set volume
pactl set-sink-volume @DEFAULT_SINK@ +5%

# Test volume command
pactl set-sink-mute @DEFAULT_SINK@ toggle
```

### Audio Output Not Switching

**Problem:** Can't switch between audio outputs

**Diagnosis:** Wrong device name or device not available

**Solution:**
```bash
# List all output devices with their names
~/Desktop/S1Bs1Bs1stem/scripts/audio/audio_output.sh --list

# Find correct device name
# Note: Names are in format: "name.description"
# Example: "alsa_output.pci-0000_00"

# Test switching manually
pactl set-default-sink "alsa_output.pci-0000_00"

# Move all streams to new device
pactl move-sink-input @DEFAULT_SINK@ "alsa_output.pci-0000_00"
```

### Microphone Toggle Not Working

**Problem:** Microphone mute/unmute doesn't work

**Diagnosis:** No default source or wrong source

**Solution:**
```bash
# List all audio sources
pactl list short sources

# Get current default source
pactl get-default-source

# Get current source mute state
pactl get-source-mute @DEFAULT_SOURCE@

# Toggle mute manually
pactl set-source-mute @DEFAULT_SOURCE@ toggle

# Test with specific source
pactl set-source-mute alsa_input.pci-0000_00 toggle
```

### PipeWire vs PulseAudio Conflicts

**Problem:** Both PipeWire and PulseAudio installed, causing conflicts

**Diagnosis:** Multiple audio servers running simultaneously

**Solution:**
```bash
# Check running audio services
systemctl --user status pipewire pipewire-pulseaudio wireplumber pulseaudio pulseaudio.socket

# Stop PulseAudio if using PipeWire
systemctl --user stop pulseaudio pulseaudio.socket

# OR stop PipeWire if using PulseAudio
systemctl --user stop pipewire pipewire-pulseaudio wireplumber

# Restart audio system
systemctl --user restart pipewire pipewire-pulseaudio wireplumber

# Verify active system
pactl info
```

### Desktop vs Audio Server Integration

**Problem:** DWM/Waybar not showing audio controls

**Diagnosis:** Audio scripts not integrated with WM

**Solution:**

For DWM:
```bash
# Check DWM config includes audio keybindings
cat ~/.config/dwm/config.h | grep -i audio

# Add audio keybindings to config.h if missing
# Then recompile:
cd ~/.config/dwm
sudo make clean install
```

For Waybar:
```bash
# Check Waybar audio modules exist
ls ~/.config/waybar/scripts/audio*

# Restart Waybar
killall waybar && waybar &
```

---

## Advanced Usage

### Custom Volume Steps

Edit volume script to change default step size:

```bash
# Edit volume_slider.sh
nano ~/Desktop/S1Bs1Bs1stem/scripts/audio/volume_slider.sh

# Find and modify this line:
VOLUME_STEP=5  # Change to your preference (1, 2, 10, etc.)
```

### Default Output Device

Set default output device in PipeWire configuration:

```bash
# Using wp-cli (PipeWire)
wpctl set-default @DEFAULT_AUDIO_SINK@

# Using pactl (PulseAudio)
pactl set-default-sink @DEFAULT_AUDIO_SINK@
```

### System-Wide Audio Configuration

```bash
# System-wide audio settings (affects all users)
sudoedit /etc/pipewire/pipewire.conf

# User audio settings (affects only current user)
~/.config/pipewire/pipewire.conf
~/.config/pulse/default.pa
```

---

## Quick Reference

| Task | Command | System |
|:---|:---|:---:|
| **Volume Up** | `~/Desktop/S1Bs1stem/scripts/audio/volume_slider.sh up` | Both |
| **Volume Down** | `~/Desktop/S1Bs1stem/scripts/audio/volume_slider.sh down` | Both |
| **Volume Set** | `~/Desktop/S1Bs1Bs1stem/scripts/audio/volume_slider.sh set 50` | Both |
| **Volume Mute** | `~/Desktop/S1Bs1Bs1stem/scripts/audio/volume_slider.sh mute` | Both |
| **Mic Toggle** | `~/Desktop/S1Bs1Bs1stem/scripts/audio/mic_switch.sh` | Both |
| **Output Menu** | `~/Desktop/S1Bs1Bs1stem/scripts/audio/audio_output.sh --menu` | Both |
| **List Outputs** | `~/Desktop/S1Bs1Bs1stem/scripts/audio/audio_output.sh --list` | Both |
| **Set Output** | `~/Desktop/S1Bs1stem/scripts/audio/audio_output.sh --set <name>` | Both |
| **DWM Switch** | `~/Desktop/S1Bs1Bs1stem/scripts/audio/audio_switch_dwm.sh` | DWM |
| **Wayland Switch** | `~/Desktop/S1Bs1Bs1stem/scripts/audio/audio_switch_wayland.sh` | Wayland |

---

## Integration with Window Manager

### DWM Keybindings

Add to `~/.config/dwm/config.h`:

```c
// Audio keybindings
static const char *volumemute[] = { "XF86AudioMute", 0 };
static const char *volumedown[] = { "XF86AudioLowerVolume", 0 };
static const char *volumeup[] = { "XF86AudioRaiseVolume", 0 };
static const char *micmute[] = { "XF86AudioMicMute", 0 };

static Key keys[] = {
    // ...
    [KEY_MUTE] = volumemute,
    [KEY_VOLUMEDOWN] = volumedown,
    [KEY_VOLUMEUP] = volumeup,
    [KEY_MICMUTE] = micmute,
};
```

### Waybar Modules

Waybar modules for audio are in `~/.config/waybar/scripts/audio/`:

| Module | Purpose | Status |
|:---|:---|:---:|
| **volume.sh** | Show volume with slider | ✅ Included |
| **mic.sh** | Show microphone state | ✅ Included |
| **output.sh** | Show active output | ✅ Included |

---

## Hardware Support

### USB Audio Devices

S1Bs1stem automatically detects and supports:
- USB sound cards
- USB headsets
- USB microphones
- External audio interfaces

### Bluetooth Audio

Bluetooth audio devices work seamlessly with:
- PipeWire: Automatic via `wireplumber`
- PulseAudio: Automatic via `pulseaudio-bluetooth`

Configuration:
```bash
# Check if Bluetooth audio is active
pactl list short sinks | grep -i bluetooth

# Enable Bluetooth audio
pactl set-card-profile <card_name> off
pactl set-card-profile <card_name> a2dp_sink
```

### HDMI/DisplayPort Audio

DisplayPort audio is detected and available as output:
```bash
# List all outputs
pactl list short sinks | grep -E "hdmi|displayport|dp"

# Set HDMI as default
pactl set-default-sink <hdmi_device_name>
```

---

## For More Information

- [Main README](../README.md)
- [DWM Setup Guide](02_DWM_SETUP.md)
- [Battery Management Guide](04_BATTERY.md)
- [Display Management Guide](05_DISPLAY.md)
- [Troubleshooting Guide](11_TROUBLESHOOTING.md)
- [API Reference](12_API_REFERENCE.md)
