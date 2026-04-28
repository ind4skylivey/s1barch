# Display Management System

Complete guide for display management in S1Bs1stem including screenshots and wallpaper management.

## Table of Contents
- [Screenshot Tool](#screenshot-tool)
- [Wallpaper Management](#wallpaper-management)
- [Usage Examples](#usage-examples)
- [Troubleshooting](#troubleshooting)

---

## Screenshot Tool

### Overview

S1Bs1stem provides a comprehensive screenshot tool with multiple capture modes.

### Features

| Feature | Description |
|:---|:---:|
| **Full Screen** | Capture entire screen |
| **Selection** | Select area to capture |
| **Window** | Capture focused window |
| **Clipboard** | Copy screenshot to clipboard |
| **Multiple Tools** | Supports grim (Wayland), maim, scrot (X11) |
| **Automatic Detection** | Detects available tools automatically |

### Script Location

`~/.local/s1barch/scripts/display/screenshot.sh`

---

## Screenshot Usage

### Full Screen Capture

```bash
# Capture full screen
~/Desktop/S1Bs1Bs1stem/scripts/display/screenshot.sh full

# Save to specific directory
OUTPUT_DIR="$HOME/Pictures/screenshots"
mkdir -p "$OUTPUT_DIR"

~/.local/s1barch/scripts/display/screenshot.sh full --output "$OUTPUT_DIR"
```

### Selection Capture

```bash
# Capture selected area
~/Desktop/S1Bs1Bs1stem/scripts/display/screenshot.sh selection

# Selection capture with slurp (Wayland only)
slurp | grim -g - $(slurp)
```

### Window Capture

```bash
# Capture focused window
~/Desktop/S1Bs1Bs1stem/scripts/display/screenshot.sh window

# Capture window by name
~/Desktop/S1Bs1Bs1Bs1Bs1Bs1stem/scripts/display/screenshot.sh window --window "Alacritty"
```

### Clipboard Capture

```bash
# Capture to clipboard
~/Desktop/S1Bs1Bs1Bs1Bs1stem/scripts/display/screenshot.sh clipboard

# Capture selection to clipboard
~/Desktop/S1Bs1Bs1Bs1Bs1stem/scripts/display/screenshot.sh selection --clipboard

# Capture window to clipboard
~/Desktop/S1Bs1Bs1Bs1Bs1stem/scripts/display/screenshot.sh window --clipboard
```

### List Screenshots

```bash
# List recent screenshots
~/Desktop/S1Bs1Bs1Bs1stem/scripts/display/screenshot.sh list

# List all screenshots
~/Desktop/S1Bs1Bs1Bs1Bs1stem/scripts/display/screenshot.sh list --all
```

---

## Wallpaper Management

### Overview

S1Bs1stem includes wallpaper cycling with history tracking and automatic support for multiple wallpaper managers.

### Supported Wallpaper Managers

| Manager | Wayland | DWM/X11 | Status |
|:---|:---|:---:|:---:|
| **swww** | ✅ GPU-accelerated transitions | ❌ N/A | ✅ Full support |
| **hyprpaper** | ✅ Native Wayland | ❌ N/A | ✅ Full support |
| **feh** | ❌ N/A | ✅ Lightweight | ✅ Full support |
| **nitrogen** | ❌ N/A | ✅ Lightweight | ✅ Full support |

### Script Location

`~/Desktop/S1Bs1Bs1Bs1stem/scripts/display/wallpaper_cycle.sh`

---

## Wallpaper Usage

### Cycle Through Wallpapers

```bash
# Next wallpaper
~/Desktop/S1Bs1Bs1Bs1Bs1stem/scripts/display/wallpaper_cycle.sh next

# Previous wallpaper
~/Desktop/S1Bs1Bs1Bs1Bs1stem/scripts/display/wallpaper_cycle.sh prev

# Random wallpaper
~/Desktop/S1Bs1Bs1Bs1Bs1Bs1Bs1Bs1stem/scripts/display/wallpaper_cycle.sh random
```

### Set Specific Wallpaper

```bash
# Set specific wallpaper by path
~/Desktop/S1Bs1Bs1Bs1Bs1stem/scripts/display/wallpaper_cycle.sh set ~/Pictures/wallpapers/nature.jpg

# Set specific wallpaper by name
~/Desktop/S1Bs1Bs1Bs1Bs1Bs1Bs1stem/scripts/display/wallpaper_cycle.sh set "nature.jpg"
```

### Wallpaper History

```bash
# View wallpaper history
~/Desktop/S1Bs1Bs1Bs1Bs1stem/scripts/display/wallpaper_cycle.sh history

# Clear history
rm -f ~/.s1b_wallpaper_history
```

### List Available Wallpapers

```bash
# List all wallpapers in directory
~/Desktop/S1Bs1Bs1Bs1Bs1stem/scripts/display/wallpaper_cycle.sh list

# List wallpapers by extension
~/Desktop/S1Bs1Bs1Bs1Bs1Bs1Bs1stem/scripts/display/wallpaper_cycle.sh list --jpg
~/Desktop/S1Bs1Bs1Bs1Bs1Bs1Bs1Bs1stem/scripts/display/wallpaper_cycle.sh list --png
```

---

## Usage Examples

### Workflow: Screenshot + Share

```bash
# Take window screenshot
SCREENSHOT_FILE=$(~/Desktop/S1Bs1Bs1Bs1stem/scripts/display/screenshot.sh window)

# Copy to clipboard
~/Desktop/S1Bs1Bs1Bs1Bs1Bs1Bs1stem/scripts/display/screenshot.sh window --clipboard

# Upload to service (example: Dropbox)
~/Desktop/S1Bs1Bs1stem/scripts/display/screenshot.sh upload --service dropbox

# Or manually upload
echo "Screenshot saved to: $SCREENSHOT_FILE"
echo "Upload to your preferred service"
```

### Workflow: Wallpaper + Timer

```bash
# Cycle wallpaper every hour
while true; do
    ~/Desktop/S1Bs1Bs1Bs1stem/scripts/display/wallpaper_cycle.sh random
    sleep 3600  # 1 hour in seconds
done
```

### Workflow: Screenshot + Annotate

```bash
# Take selection screenshot
SCREENSHOT_FILE=$(~/Desktop/S1Bs1Bs1Bs1Bs1Bs1Bs1Bs1Bs1Bs1stem/scripts/display/screenshot.sh selection)

# Open in editor for annotation
kate "$SCREENSHOT_FILE"
# OR
geany "$SCREENSHOT_FILE"
# OR
code "$SCREENSHOT_FILE"
```

---

## Troubleshooting

### Screenshot Tool Not Working

**Problem:** Screenshot fails or shows errors

**Diagnosis:** No screenshot tool installed

**Solution:**
```bash
# Check available tools
command -v grim && echo "grim: OK" || echo "grim: NOT INSTALLED"
command -v maim && echo "maim: OK" || echo "maim: NOT INSTALLED"
command -v scrot && echo "scrot: OK" || echo "scrot: NOT INSTALLED"

# Install screenshot tool for Wayland
sudo pacman -S grim slurp

# Install screenshot tool for X11
sudo pacman -S maim slop
# OR
sudo pacman -S scrot

# Test screenshot
~/Desktop/S1Bs1Bs1Bs1stem/scripts/display/sallpaper_cycle.sh full
```

### Selection Capture Not Working

**Problem:** Selection mode fails

**Diagnosis:** slurp (Wayland) or slop (X11) not installed

**Solution:**
```bash
# Install slurp for Wayland
sudo pacman -S slurp

# Install slop for X11
sudo pacman -S slop

# Test selection
# Wayland
grim -g "$(slurp)"

# X11
maim -s
```

### Wallpaper Not Changing

**Problem:** Wallpaper script doesn't change wallpaper

**Diagnosis:** Wallpaper manager not running or wrong directory

**Solution:**
```bash
# Check wallpaper directory exists
ls -la ~/Pictures/wallpapers/

# Check current wallpaper
~/Desktop/S1Bs1Bs1Bs1Bs1stem/scripts/display/wallpaper_cycle.sh current

# Check if swww is running
pgrep swww

# Restart swww
killall swww
swww-daemon &

# Set wallpaper with feh (for DWM)
feh --bg-scale ~/Pictures/wallpapers/nature.jpg
```

### Wallpaper Transitions Not Working

**Problem:** Wallpaper transitions not smooth

**Diagnosis:** swww not running or daemon issue

**Solution:**
```bash
# Check swww daemon status
systemctl --user status swww-daemon

# Restart swww
systemctl --user restart swww-daemon

# Test transitions manually
swww img ~/Pictures/wallpapers/nature.jpg --transition-type random
```

### Brightness Control Issues

**Problem:** Brightness control not working on laptop

**Diagnosis:** xbacklight not installed or no backlight

**Note:** Brightness control is NOT included in S1Bs1stem for desktop PCs. It should only be used on laptops with backlights.

**Solution:**
```bash
# Check if xbacklight is installed (laptops only)
command -v xbacklight || sudo pacman -S xorg-xbacklight

# Check current brightness
xbacklight -get

# Increase brightness
xbacklight -inc 10

# Decrease brightness
xbacklight -dec 10

# Set brightness to 50%
xbacklight -set 50

# Toggle brightness (on/off)
xbacklight -set 0
xbacklight -set 100
```

---

## Advanced Configuration

### Screenshot File Naming

Edit screenshot.sh to customize file naming:

```bash
# Edit screenshot.sh
nano ~/Desktop/S1Bs1Bs1Bs1Bs1stem/scripts/display/screenshot.sh

# Find and modify this line:
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Alternative formats:
# TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)  # ISO 8601
# TIMESTAMP=$(date +%F_%H-%M-%S)       # Human readable
# TIMESTAMP=$(date +%s)                 # Unix timestamp
```

### Screenshot Save Location

Change default save directory:

```bash
# Edit screenshot.sh
nano ~/Desktop/S1Bs1Bs1Bs1Bs1stem/scripts/display/screenshot.sh

# Find and modify this line:
readonly SCREENSHOT_DIR="$HOME/Pictures/screenshots"

# Change to your preference:
# readonly SCREENSHOT_DIR="$HOME/Documents/Screenshots"
# readonly SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
```

### Wallpaper Directory

Change default wallpaper directory:

```bash
# Edit wallpaper_cycle.sh
nano ~/Desktop/S1Bs1Bs1Bs1Bs1stem/scripts/display/wallpaper_cycle.sh

# Find and modify this line:
readonly WALLPAPER_DIR="$HOME/Pictures/wallpapers"

# Change to your preference:
# readonly WALLPAPER_DIR="$HOME/Pictures/Backgrounds"
# readonly WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
```

### swww Configuration

swww can be configured for different transition effects:

```bash
# Test different transition types
swww img ~/Pictures/wallpapers/nature.jpg --transition-type simple
swww img ~/Pictures/wallpapers/nature.jpg --transition-fps 60
swww img ~/Pictures/wallpapers/nature.jpg --transition-step 100

# Set swww init
# Add to ~/.config/dwm/autostart.sh:
# swww img ~/Pictures/wallpapers/current.jpg
```

### feh Configuration

feh can be configured for different modes:

```bash
# Scale mode (stretch to fit)
feh --bg-scale ~/Pictures/wallpapers/nature.jpg

# Fill mode (fit and fill)
feh --bg-fill ~/Pictures/wallpapers/nature.jpg

# Max mode (center at max resolution)
feh --bg-max ~/Pictures/wallpapers/nature.jpg

# No Xinerama (for single monitor setups)
feh --bg-scale --no-xinerama ~/Pictures/wallpapers/nature.jpg

# Save current wallpaper for restoration
feh --bg-scale ~/Pictures/wallpapers/nature.jpg
echo "feh --bg-scale ~/Pictures/wallpapers/nature.jpg" > ~/.fehbg
```

---

## Integration with Window Manager

### DWM Wallpaper

```bash
# Set wallpaper with feh
feh --bg-scale ~/Pictures/wallpapers/nature.jpg

# Save fehbg for persistence
echo "feh --bg-scale ~/Pictures/wallpapers/nature.jpg" > ~/.fehbg

# Add to autostart
# See: ~/Desktop/S1Bs1Bs1stem/scripts/dwm/autostart.sh
```

### Waybar Wallpaper Module

Waybar includes wallpaper control buttons:

```bash
# Waybar scripts location
ls ~/.config/waybar/scripts/wallpaper/

# Available modules:
# - next.sh: Next wallpaper
# - prev.sh: Previous wallpaper
# - random.sh: Random wallpaper
```

---

## Quick Reference

| Task | Command |
|:---|:---:|
| **Full Screenshot** | `~/Desktop/S1Bs1Bs1stem/scripts/display/screenshot.sh full` |
| **Selection** | `~/Desktop/S1Bs1Bs1Bs1stem/scripts/display/screenshot.sh selection` |
| **Window Screenshot** | `~/Desktop/S1Bs1Bs1Bs1stem/scripts/display/screenshot.sh window` |
| **Clipboard** | `~/Desktop/S1Bs1Bs1Bs1stem/scripts/display/screenshot.sh clipboard` |
| **List Screenshots** | `~/Desktop/S1Bs1Bs1Bs1stem/scripts/display/screenshot.sh list` |
| **Next Wallpaper** | `~/Desktop/S1Bs1Bs1Bs1stem/scripts/display/wallpaper_cycle.sh next` |
| **Prev Wallpaper** | `~/Desktop/S1Bs1Bs1Bs1stem/scripts/display/wallpaper_cycle.sh prev` |
| **Random Wallpaper** | `~/Desktop/S1Bs1Bs1Bs1stem/scripts/display/wallpaper_cycle.sh random` |
| **Set Wallpaper** | `~/Desktop/S1Bs1Bs1Bs1Bs1stem/scripts/display/wallpaper_cycle.sh set <path>` |
| **Current Wallpaper** | `~/Desktop/S1Bs1Bs1Bs1stem/scripts/display/wallpaper_cycle.sh current` |
| **Wallpaper History** | `~/Desktop/S1Bs1Bs1Bs1Bs1stem/scripts/display/wallpaper_cycle.sh history` |

---

## For More Information

- [Main README](../README.md)
- [Audio Management Guide](03_AUDIO.md)
- [Battery Management Guide](04_BATTERY.md)
- [DWM Setup Guide](02_DWM_SETUP.md)
- [DWM Window Management](06_DWM_WINDOW_MANAGEMENT.md)
- [Troubleshooting Guide](11_TROUBLESHOOTING.md)
- [API Reference](12_API_REFERENCE.md)
