# API Reference

Complete API reference for S1Bs1stem automation scripts and functions.

## Table of Contents
- [Common Functions](#common-functions)
- [Logger Functions](#logger-functions)
- [Color Functions](#color-functions)
- [Hardware Detection Functions](#hardware-detection-functions)
- [Audio System Functions](#audio-system-functions)
- [Script APIs](#script-apis)
- [Configuration Files](#configuration-files)
- [Environment Variables](#environment-variables)

---

## Common Functions

### Overview

Common utility functions used across all S1Bs1stem scripts.

### Location

`~/.local/s1barch/scripts/common/functions.sh`

### Functions Reference

#### String Trimming

```bash
trim_string()
```
Removes leading and trailing whitespace from a string.

**Parameters:**
- `$1` - String to trim

**Returns:**
- Trimmed string via echo

**Example:**
```bash
trimmed=$(trim_string "  hello  world  ")
echo "$trimmed"  # Output: "hello  world"
```

---

#### String Validation

```bash
is_valid_string()
```
Checks if a string is valid (non-empty, not just whitespace).

**Parameters:**
- `$1` - String to validate

**Returns:**
- 0 (true) if valid
- 1 (false) if invalid

**Example:**
```bash
if is_valid_string "$input"; then
    echo "Input is valid"
fi
```

---

#### Number Validation

```bash
is_valid_number()
```
Checks if input is a valid number.

**Parameters:**
- `$1` - Input to validate

**Returns:**
- 0 (true) if number
- 1 (false) if not number

**Example:**
```bash
if is_valid_number "$age"; then
    echo "Age is valid: $age"
fi
```

---

#### Path Validation

```bash
is_valid_path()
```
Checks if a path exists and is valid.

**Parameters:**
- `$1` - Path to validate

**Returns:**
- 0 (true) if valid path
- 1 (false) if invalid path

**Example:**
```bash
if is_valid_path "$HOME/Documents"; then
    echo "Path exists"
fi
```

---

#### Command Execution Check

```bash
run_command()
```
Executes a command and returns exit code.

**Parameters:**
- `$@` - Command and arguments to execute

**Returns:**
- Exit code of command

**Example:**
```bash
if run_command "ping -c 4 archlinux.org"; then
    echo "Network is reachable"
fi
```

---

#### File Existence Check

```bash
file_exists()
```
Checks if a file exists.

**Parameters:**
- `$1` - File path

**Returns:**
- 0 (true) if exists
- 1 (false) if not exists

**Example:**
```bash
if file_exists "$HOME/.zshrc"; then
    source "$HOME/.zshrc"
fi
```

---

#### Directory Existence Check

```bash
dir_exists()
```
Checks if a directory exists.

**Parameters:**
- `$1` - Directory path

**Returns:**
- 0 (true) if exists
- 1 (false) if not exists

**Example:**
```bash
if dir_exists "$HOME/Pictures/screenshots"; then
    echo "Screenshots directory exists"
else
    mkdir -p "$HOME/Pictures/screenshots"
fi
```

---

#### Create Directory

```bash
create_dir()
```
Creates directory if it doesn't exist.

**Parameters:**
- `$1` - Directory path

**Returns:**
- 0 on success
- 1 on failure

**Example:**
```bash
create_dir "$HOME/.local/bin"
```

---

#### Directory Check

```bash
check_dir()
```
Creates directory if not exists and logs message.

**Parameters:**
- `$1` - Directory path
- `$2` - Log message (optional)

**Returns:**
- 0 on success
- 1 on failure

**Example:**
```bash
check_dir "$HOME/Pictures/wallpapers" "Wallpapers directory"
```

---

## Logger Functions

### Overview

Logging functions for consistent and colorized logging across all scripts.

### Location

`~/.local/s1barch/scripts/common/logger.sh`

### Functions Reference

#### Info Logging

```bash
log_info()
```
Logs informational message (green).

**Parameters:**
- `$1` - Message to log

**Example:**
```bash
log_info "Starting installation process"
```

---

#### Success Logging

```bash
log_success()
```
Logs success message (green bold).

**Parameters:**
- `$1` - Message to log

**Example:**
```bash
log_success "Installation completed successfully"
```

---

#### Warning Logging

```bash
log_warning()
```
Logs warning message (yellow).

**Parameters:**
- `$1` - Message to log

**Example:**
```bash
log_warning "Package already installed, skipping"
```

---

#### Error Logging

```bash
log_error()
```
Logs error message (red).

**Parameters:**
- `$1` - Error message to log

**Example:**
```bash
log_error "Failed to install package: $package_name"
```

---

#### Critical Error Logging

```bash
log_critical()
```
Logs critical error message (red bold) and exits.

**Parameters:**
- `$1` - Critical error message
- `$2` - Exit code (default: 1)

**Example:**
```bash
log_critical "Installation failed" 1
```

---

#### Debug Logging

```bash
log_debug()
```
Logs debug message (cyan) when DEBUG is set.

**Parameters:**
- `$1` - Debug message

**Example:**
```bash
DEBUG=1
log_debug "Variable value: $var"
```

---

#### Section Header

```bash
log_section()
```
Logs section header (blue bold).

**Parameters:**
- `$1` - Section title

**Example:**
```bash
log_section "Installing Dependencies"
```

---

#### Subsection Header

```bash
log_subsection()
```
Logs subsection header (magenta).

**Parameters:**
- `$1` - Subsection title

**Example:**
```bash
log_subsection "Checking for existing installation"
```

---

#### Progress Indicator

```bash
log_progress()
```
Logs progress message (cyan).

**Parameters:**
- `$1` - Progress message

**Example:**
```bash
log_progress "Installing package: $package"
```

---

#### Command Logging

```bash
log_command()
```
Logs command being executed (gray).

**Parameters:**
- `$@` - Command to log

**Example:**
```bash
log_command "sudo pacman -S $package"
```

---

#### Recent Logs

```bash
log_recent()
```
Shows recent log entries.

**Parameters:**
- `$1` - Number of lines to show (default: 20)

**Example:**
```bash
log_recent 50
```

---

#### Last Errors

```bash
log_last_errors()
```
Shows last N error log entries.

**Parameters:**
- `$1` - Number of errors to show (default: 10)

**Example:**
```bash
log_last_errors 20
```

---

#### Last Warnings

```bash
log_last_warns()
```
Shows last N warning log entries.

**Parameters:**
- `$1` - Number of warnings to show (default: 10)

**Example:**
```bash
log_last_warns 20
```

---

#### Log Statistics

```bash
log_stats()
```
Shows log statistics (total lines, errors, warnings).

**Example:**
```bash
log_stats
```

---

#### Follow Logs

```bash
log_tail()
```
Follows log file in real-time (tail -f).

**Example:**
```bash
log_tail
```

---

#### Log Rotation

```bash
log_rotate()
```
Rotates log file when size exceeds limit.

**Example:**
```bash
log_rotate
```

---

## Color Functions

### Overview

Color definitions and functions for consistent color usage.

### Location

`~/.local/s1barch/scripts/common/colors.sh`

### Color Constants

```bash
readonly COLOR_RED='\033[0;31m'
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_YELLOW='\033[0;33m'
readonly COLOR_BLUE='\033[0;34m'
readonly COLOR_PURPLE='\033[0;35m'
readonly COLOR_CYAN='\033[0;36m'
readonly COLOR_WHITE='\033[0;37m'
readonly COLOR_BLACK='\033[0;30m'
readonly COLOR_GRAY='\033[0;90m'

readonly COLOR_BOLD_RED='\033[1;31m'
readonly COLOR_BOLD_GREEN='\033[1;32m'
readonly COLOR_BOLD_YELLOW='\033[1;33m'
readonly COLOR_BOLD_BLUE='\033[1;34m'
readonly COLOR_BOLD_PURPLE='\033[1;35m'
readonly COLOR_BOLD_CYAN='\033[1;36m'
readonly COLOR_BOLD_WHITE='\033[1;37m'

readonly COLOR_BG_RED='\033[41m'
readonly COLOR_BG_GREEN='\033[42m'
readonly COLOR_BG_YELLOW='\033[43m'
readonly COLOR_BG_BLUE='\033[44m'
readonly COLOR_BG_MAGENTA='\033[45m'
readonly COLOR_BG_CYAN='\033[46m'

readonly COLOR_RESET='\033[0m'
readonly COLOR_RESET_BOLD='\033[21m'
readonly COLOR_RESET_UNDERLINE='\033[24m'
readonly COLOR_RESET_BLINK='\033[25m'
readonly COLOR_RESET_REVERSE='\033[27m'
```

### Functions Reference

#### Color Text

```bash
color_text()
```
Colors text with specified color.

**Parameters:**
- `$1` - Color code
- `$2` - Text to color

**Returns:**
- Colored text via echo

**Example:**
```bash
colored=$(color_text "$COLOR_RED" "Error message")
echo "$colored"
```

---

#### Success Text

```bash
success_text()
```
Returns text in success color (green bold).

**Parameters:**
- `$1` - Text to color

**Returns:**
- Colored text via echo

**Example:**
```bash
echo "$(success_text "Operation successful")"
```

---

#### Error Text

```bash
error_text()
```
Returns text in error color (red bold).

**Parameters:**
- `$1` - Text to color

**Returns:**
- Colored text via echo

**Example:**
```bash
echo "$(error_text "Operation failed")"
```

---

#### Warning Text

```bash
warning_text()
```
Returns text in warning color (yellow).

**Parameters:**
- `$1` - Text to color

**Returns:**
- Colored text via echo

**Example:**
```bash
echo "$(warning_text "Warning message")"
```

---

#### Info Text

```bash
info_text()
```
Returns text in info color (cyan).

**Parameters:**
- `$1` - Text to color

**Returns:**
- Colored text via echo

**Example:**
```bash
echo "$(info_text "Information message")"
```

---

## Hardware Detection Functions

### Overview

Functions for detecting hardware capabilities (battery, lid, audio system).

### Location

`~/.local/s1barch/scripts/common/functions.sh`

### Functions Reference

#### Battery Detection

```bash
has_battery()
```
Checks if system has battery.

**Returns:**
- 0 (true) if battery found
- 1 (false) if no battery

**Example:**
```bash
if has_battery; then
    echo "Battery detected"
else
    echo "Desktop PC detected (no battery)"
fi
```

---

#### Battery Count

```bash
get_battery_count()
```
Returns number of batteries in system.

**Returns:**
- Number of batteries (0 if none)

**Example:**
```bash
battery_count=$(get_battery_count)
echo "System has $battery_count batteries"
```

---

#### Lid Detection

```bash
has_lid()
```
Checks if system has lid switch (laptop).

**Returns:**
- 0 (true) if lid found
- 1 (false) if no lid

**Example:**
```bash
if has_lid; then
    echo "Laptop detected (lid switch present)"
else
    echo "Desktop PC detected (no lid switch)"
fi
```

---

## Audio System Functions

### Overview

Functions for detecting and managing audio systems (PulseAudio, PipeWire).

### Location

`~/.local/s1barch/scripts/common/functions.sh`

### Functions Reference

#### Audio System Detection

```bash
get_audio_system()
```
Detects active audio system.

**Returns:**
- "pipewire" if PipeWire is running
- "pulseaudio" if PulseAudio is running (but not PipeWire)
- "none" if no audio system detected

**Example:**
```bash
audio_sys=$(get_audio_system)
echo "Audio system: $audio_sys"
```

---

#### PulseAudio Detection

```bash
has_pulseaudio()
```
Checks if PulseAudio is installed.

**Returns:**
- 0 (true) if PulseAudio found
- 1 (false) if not found

**Example:**
```bash
if has_pulseaudio; then
    echo "PulseAudio is installed"
fi
```

---

#### PipeWire Detection

```bash
has_pipewire()
```
Checks if PipeWire is installed.

**Returns:**
- 0 (true) if PipeWire found
- 1 (false) if not found

**Example:**
```bash
if has_pipewire; then
    echo "PipeWire is installed"
fi
```

---

#### Audio Command

```bash
get_audio_command()
```
Returns appropriate audio command based on system.

**Returns:**
- "pactl" if audio system detected
- "none" if no audio system

**Example:**
```bash
audio_cmd=$(get_audio_command)
if [ "$audio_cmd" != "none" ]; then
    $audio_cmd set-sink-mute @DEFAULT_SINK@ toggle
fi
```

---

#### Volume Up

```bash
audio_volume_up()
```
Increases volume by 5%.

**Example:**
```bash
audio_volume_up
```

---

#### Volume Down

```bash
audio_volume_down()
```
Decreases volume by 5%.

**Example:**
```bash
audio_volume_down
```

---

#### Toggle Mute

```bash
audio_toggle_mute()
```
Toggles mute state.

**Example:**
```bash
audio_toggle_mute
```

---

#### Mic Toggle Mute

```bash
audio_mic_toggle_mute()
```
Toggles microphone mute state.

**Example:**
```bash
audio_mic_toggle_mute
```

---

## Script APIs

### Audio Scripts

#### audio_status.sh

**Location:** `~/.local/s1barch/scripts/audio/audio_status.sh`

**API:**

```bash
# Show full audio status
~/.local/s1barch/scripts/audio/audio_status.sh

# Show short status
~/.local/s1barch/scripts/audio/audio_status.sh --short

# Show device list
~/.local/s1barch/scripts/audio/audio_status.sh --devices

# Show volume only
~/.local/s1barch/scripts/audio/audio_status.sh --volume
```

---

#### audio_control.sh

**Location:** `~/.local/s1barch/scripts/audio/audio_control.sh`

**API:**

```bash
# Volume up (default: 5%)
~/.local/s1barch/scripts/audio/audio_control.sh up
~/.local/s1barch/scripts/audio/audio_control.sh up 10

# Volume down (default: 5%)
~/.local/s1barch/scripts/audio/audio_control.sh down
~/.local/s1barch/scripts/audio/audio_control.sh down 10

# Set volume
~/.local/s1barch/scripts/audio/audio_control.sh set 50

# Toggle mute
~/.local/s1barch/scripts/audio/audio_control.sh mute

# Toggle mic mute
~/.local/s1barch/scripts/audio/audio_control.sh micmute

# Unmute
~/.local/s1barch/scripts/audio/audio_control.sh unmute
```

---

### Battery Scripts

#### battery_status.sh

**Location:** `~/.local/s1barch/scripts/battery/battery_status.sh`

**API:**

```bash
# Show full battery status
~/.local/s1barch/scripts/battery/battery_status.sh

# Show short status
~/.local/s1barch/scripts/battery/battery_status.sh --short

# Show battery percentage only
~/.local/s1barch/scripts/battery/battery_status.sh --percentage

# Show battery time remaining
~/.local/s1barch/scripts/battery/battery_status.sh --time

# Show battery health
~/.local/s1barch/scripts/battery/battery_status.sh --health
```

---

#### battery_threshold.sh

**Location:** `~/.local/s1barch/scripts/battery/battery_threshold.sh`

**API:**

```bash
# Set low threshold (default: 20)
~/.local/s1barch/scripts/battery/battery_threshold.sh low 20

# Set critical threshold (default: 10)
~/.local/s1barch/scripts/battery/battery_threshold.sh critical 10

# Check threshold
~/.local/s1barch/scripts/battery/battery_threshold.sh check

# Show current thresholds
~/.local/s1barch/scripts/battery/battery_threshold.sh show
```

---

### Networking Scripts

#### network_status.sh

**Location:** `~/.local/s1barch/scripts/networking/network_status.sh`

**API:**

```bash
# Show full network status
~/.local/s1barch/scripts/networking/network_status.sh

# Show short status
~/.local/s1barch/scripts/networking/network_status.sh --short

# Show connection type only
~/.local/s1barch/scripts/networking/network_status.sh --type

# Show IP addresses
~/.local/s1barch/scripts/networking/network_status.sh --ip

# Show signal strength (WiFi)
~/.local/s1barch/scripts/networking/network_status.sh --signal
```

---

#### dns_switch.sh

**Location:** `~/.local/s1barch/scripts/networking/dns_switch.sh`

**API:**

```bash
# Switch to Cloudflare DNS
~/.local/s1barch/scripts/networking/dns_switch.sh cloudflare

# Switch to Google DNS
~/.local/s1barch/scripts/networking/dns_switch.sh google

# Switch to Quad9 DNS
~/.local/s1barch/scripts/networking/dns_switch.sh quad9

# Restore system DNS
~/.local/s1barch/scripts/networking/dns_switch.sh restore

# Show current DNS
~/.local/s1barch/scripts/networking/dns_switch.sh --current

# Show DNS menu
~/.local/s1barch/scripts/networking/dns_switch.sh
```

---

### System Scripts

#### system_info.sh

**Location:** `~/.local/s1barch/scripts/system/system_info.sh`

**API:**

```bash
# Show full system info
~/.local/s1barch/scripts/system/system_info.sh

# Show CPU info only
~/.local/s1barch/scripts/system/system_info.sh --cpu

# Show memory info only
~/.local/s1barch/scripts/system/system_info.sh --memory

# Show disk info only
~/.local/s1barch/scripts/system/system_info.sh --disk

# Show uptime only
~/.local/s1barch/scripts/system/system_info.sh --uptime
```

---

#### service_status.sh

**Location:** `~/.local/s1barch/scripts/system/service_status.sh`

**API:**

```bash
# Show all services
~/.local/s1barch/scripts/system/service_status.sh

# Show specific service
~/.local/s1barch/scripts/system/service_status.sh --service NetworkManager

# Show failed services
~/.local/s1barch/scripts/system/service_status.sh --failed

# Show enabled services
~/.local/s1barch/scripts/system/service_status.sh --enabled

# Show disabled services
~/.local/s1barch/scripts/system/service_status.sh --disabled
```

---

## Configuration Files

### DWM Configuration

#### config.h

**Location:** `~/.local/src/dwm/config.h`

**Key settings:**

```c
// Modifier key (Mod1 = Alt, Mod4 = Super/Windows)
#define MODKEY Mod4

// Fonts
static const char *fonts[] = {
    "JetBrains Mono:size=10:antialias=true:autohint=true",
    "Noto Color Emoji:size=10:antialias=true:autohint=true"
};

// Colors
static const char *colors[][3] = {
    /* fg        bg        border */
    [SchemeNorm] = { "#bbbbbb", "#222222", "#444444" },
    [SchemeSel]  = { {"#eeeeee", "#005577", "#005577" }
};
```

---

#### autostart.sh

**Location:** `~/.config/dwm/autostart.sh`

**Purpose:** Autostart applications when DWM starts

---

#### dwm_bar.sh

**Location:** `~/.config/dwm/dwm_bar.sh`

**Purpose:** Status bar script

---

### Shell Configuration

#### Zsh

**Location:** `~/.zshrc`

**Purpose:** Zsh shell configuration

---

#### Fish

**Location:** `~/.config/fish/config.fish`

**Purpose:** Fish shell configuration

---

### Application Configuration

#### Alacritty

**Location:** `~/.config/alacritty/alacritty.yml`

**Purpose:** Alacritty terminal configuration

---

#### Kitty

**Location:** `~/.config/kitty/kitty.conf`

**Purpose:** Kitty terminal configuration

---

#### Rofi

**Location:** `~/.config/rofi/config.rasi`

**Purpose:** Rofi launcher configuration

---

#### Waybar

**Location:** `~/.config/waybar/config`

**Purpose:** Waybar panel configuration

---

## Environment Variables

### S1Bs1stem Variables

```bash
# Project root
S1B_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"  # Auto-detect

# Scripts directory
S1B_SCRIPTS="$S1B_ROOT/scripts"

# Common directory
S1B_COMMON="$S1B_SCRIPTS/common"

# Log directory
S1B_LOG_DIR="$HOME/.s1b_logs"

# Log file
S1B_LOG_FILE="$S1B_LOG_DIR/s1b_system.log"
```

---

### Logger Variables

```bash
# Log file (can be overridden)
LOG_FILE="$S1B_LOG_DIR/s1b_system.log"

# Log level (optional)
LOG_LEVEL="${LOG_LEVEL:-INFO}"  # DEBUG, INFO, WARNING, ERROR, CRITICAL

# Debug mode (optional)
DEBUG="${DEBUG:-0}"  # 0 = off, 1 = on

# Log rotation
LOG_MAX_SIZE="${LOG_MAX_SIZE:-10485760}"  # 10MB
LOG_MAX_FILES="${LOG_MAX_FILES:-5}"
```

---

### Audio Variables

```bash
# Audio system (auto-detected)
AUDIO_SYSTEM="${AUDIO_SYSTEM:-}"  # pipewire, pulseaudio, none

# Audio command (auto-detected)
AUDIO_CMD="${AUDIO_CMD:-}"  # pactl, none
```

---

### Hardware Variables

```bash
# Battery status (auto-detected)
HAS_BATTERY="${HAS_BATTERY:-}"
BATTERY_COUNT="${BATTERY_COUNT:-}"

# Lid status (auto-detected)
HAS_LID="${HAS_LID:-}"

# Audio system (auto-detected)
HAS_PULSEAUDIO="${HAS_PULSEAUDIO:-}"
HAS_PIPEWIRE="${HAS_PIPEWIRE:-}"
```

---

## Exit Codes

### Standard Exit Codes

```bash
# Success
0    - Operation successful

# General errors
1    - General error
2    - Misuse of shell command (rare)
126  - Command invoked cannot execute
127  - Command not found
128  - Invalid argument to exit

# Signal exits
130  - Script terminated by Control-C (SIGINT)
137  - Script killed by SIGKILL
143  - Script terminated by SIGTERM

# S1Bs1stem specific
10   - Installation failed
20   - Dependency missing
30   - Permission denied
40   - Invalid argument
50   - Configuration error
60   - Hardware not detected
70   - Service not running
80   - Network error
90   - Audio error
100  - File system error
```

---

## Quick Reference

### Common Functions

| Function | Description | Location |
|:---|:---|:---:|
| `trim_string()` | Trim whitespace | functions.sh |
| `is_valid_string()` | Validate string | functions.sh |
| `is_valid_number()` | Validate number | functions.sh |
| `is_valid_path()` | Validate path | functions.sh |
| `file_exists()` | Check file exists | functions.sh |
| `dir_exists()` | Check dir exists | functions.sh |
| `create_dir()` | Create directory | functions.sh |
| `check_dir()` | Check/create dir | functions.sh |

### Logger Functions

| Function | Description | Color |
|:---|:---|:---:|
| `log_info()` | Info message | Green |
| `log_success()` | Success message | Green bold |
| `log_warning()` | Warning message | Yellow |
| `log_error()` | Error message | Red |
| `log_critical()` | Critical + exit | Red bold |
| `log_debug()` | Debug message | Cyan |
| `log_section()` | Section header | Blue bold |
| `log_subsection()` | Subsection | Magenta |
| `log_progress()` | Progress message | Cyan |
| `log_command()` | Command executed | Gray |
| `log_recent()` | Recent logs | N/A |
| `log_last_errors()` | Last errors | N/A |
| `log_last_warns()` | Last warnings | N/A |
| `log_stats()` | Log statistics | N/A |
| `log_tail()` | Follow logs | N/A |
| `log_rotate()` | Rotate logs | N/A |

### Hardware Detection

| Function | Returns | Description |
|:---|:---:|:---:|
| `has_battery()` | 0/1 | Battery detection |
| `get_battery_count()` | N | Battery count |
| `has_lid()` | 0/1 | Lid detection |
| `get_audio_system()` | string | Audio system name |
| `has_pulseaudio()` | 0/1 | PulseAudio detection |
| `has_pipewire()` | 0/1 | PipeWire detection |
| `get_audio_command()` | string | Audio command |
| `audio_volume_up()` | N/A | Volume +5% |
| `audio_volume_down()` | N/A | Volume -5% |
| `audio_toggle_mute()` | N/A | Toggle mute |
| `audio_mic_toggle_mute()` | N/A | Toggle mic mute |

---

## For More Information

- [Main README](../README.md)
- [Installation Guide](01_INSTALLATION.md)
- [DWM Setup Guide](02_DWM_SETUP.md)
- [Audio Management](03_AUDIO.md)
- [Battery Management](04_BATTERY.md)
- [Display Management](05_DISPLAY.md)
- [DWM Window Management](06_DWM_WINDOW_MANAGEMENT.md)
- [Networking](07_NETWORKING.md)
- [System Management](08_SYSTEM.md)
- [Workflows](09_WORKFLOWS.md)
- [Customization](10_CUSTOMIZATION.md)
- [Troubleshooting](11_TROUBLESHOOTING.md)
