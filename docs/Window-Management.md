# DWM Window Management System

Complete guide for managing windows in DWM window manager with S1Bs1stem automation scripts.

## Table of Contents
- [Window Control](#window-control)
- [Window Rules](#window-rules)
- [Autostart Management](#autostart-management)
- [DWM Configuration](#dwm-configuration)
- [Usage Examples](#usage-examples)
- [Troubleshooting](#troubleshooting)

---

## Window Control

### Overview

DWM window management automation including:
- Window switching
- Window movement and resizing
- Window state toggling
- Window layout management
- Tag switching
- Tag window assignment

### Script

**Location:** `~/.local/s1barch/scripts/dwm/window_control.sh`

### Usage

```bash
# Show window control help
~/.local/s1barch/scripts/dwm/window_control.sh help

# Focus next window
~/.local/s1barch/scripts/dwm/window_control.sh next

# Focus previous window
~/.local/s1barch/scripts/dwm/window_control.sh prev

# Focus window by number (1-9)
~/.local/s1barch/scripts/dwm/window_control.sh focus 1
~/.local/s1barch/scripts/dwm/window_control.sh focus 2

# Kill focused window
~/.local/s1barch/scripts/dwm/window_control.sh kill

# Kill window by number
~/.local/s1barch/scripts/dwm/window_control.sh kill 1

# Toggle floating state
~/.local/s1barch/scripts/dwm/window_control.sh toggle-float

# Toggle fullscreen
~/.local/s1barch/scripts/dwm/window_control.sh toggle-fullscreen

# Move window to next monitor
~/.local/s1barch/scripts/dwm/window_control.sh move-next-monitor

# Move window to previous monitor
~/.local/s1barch/scripts/dwm/window_control.sh move-prev-monitor
```

### Tag Management

```bash
# Switch to tag 1-9
~/.local/s1barch/scripts/dwm/window_control.sh tag 1
~/.local/s1barch/scripts/dwm/window_control.sh tag 2

# View multiple tags
~/.local/s1barch/scripts/dwm/window_control.sh view 1 2

# Move window to tag
~/.local/s1barch/scripts/dwm/window_control.sh movetotag 1

# Copy window to tag
~/.local/s1barch/scripts/dwm/window_control.sh copytotag 1

# Toggle tag visibility
~/.local/s1barch/scripts/dwm/window_control.sh toggleview 1
```

### Layout Management

```bash
# Toggle between tiled and floating layout
~/.local/s1barch/scripts/dwm/window_control.sh toggle-layout

# Switch to specific layout
~/.local/s1barch/scripts/dwm/window_control.sh layout tiled
~/.local/s1barch/scripts/dwm/window_control.sh layout floating
~/.local/s1barch/scripts/dwm/window_control.sh layout monocle

# Increase master area size
~/.local/s1barch/scripts/dwm/window_control.sh incmaster

# Decrease master area size
~/.local/s1barch/scripts/dwm/window_control.sh decmaster

# Increase number of master windows
~/.local/s1barch/scripts/dwm/window_control.sh incnmaster

# Decrease number of master windows
~/.local/s1barch/scripts/dwm/window_control.sh decnmaster
```

---

## Window Rules

### Overview

DWM window rules allow automatic window placement and behavior based on window properties.

### Script

**Location:** `~/.local/s1barch/scripts/dwm/window_rules.sh`

### Usage

```bash
# Show current window rules
~/.local/s1barch/scripts/dwm/window_rules.sh list

# Add new window rule
~/.local/s1barch/scripts/dwm/window_rules.sh add --class "Alacritty" --tag "1" --floating false

# Add floating rule
~/.local/s1barch/scripts/dwm/window_rules.sh add --class "Pavucontrol" --floating true

# Add fullscreen rule
~/.local/s1barch/scripts/dwm/window_control.sh add --class "mpv" --fullscreen true

# Remove window rule
~/.local/s1barch/scripts/dwm/window_rules.sh remove "Alacritty"

# Clear all rules
~/.local/s1barch/scripts/dwm/window_rules.sh clear
```

### Rule Syntax

```bash
# Basic rule syntax
~/.local/s1barch/scripts/dwm/window_rules.sh add \
    --class "WindowClass" \
    --instance "WindowInstance" \
    --title "WindowTitle" \
    --tag "1" \
    --floating true|false \
    --fullscreen true|false

# Examples:
# Terminal on tag 1, tiled
~/.local/s1barch/scripts/dwm/window_rules.sh add \
    --class "Alacritty" --tag "1" --floating false

# Pavucontrol floating on tag 9
~/.local/s1barch/scripts/dwm/window_rules.sh add \
    --class "Pavucontrol" --tag "9" --floating true

# MPV fullscreen on tag 2
~/.local/s1barch/scripts/dwm/window_rules.sh add \
    --class "mpv" --tag "2" --fullscreen true
```

### Default Rules

S1Bs1stem includes pre-configured window rules:

| Application | Tag | Floating | Fullscreen |
|:---|:---:|:---:|:---:|
| **Alacritty** | 1 | No | No |
| **Firefox** | 2 | No | No |
| **VSCodium** | 3 | No | No |
| **Pavucontrol** | 9 | Yes | No |
| **Blueman-manager** | 9 | Yes | No |
| **NM-applet** | 9 | Yes | No |
| **Pavucontrol** | 9 | Yes | No |
| **Rofi** | - | Yes | No |
| **dmenu** | - | Yes | No |

---

## Autostart Management

### Overview

DWM autostart configuration for automatic application launch on login.

### Script

**Location:** `~/.local/s1barch/scripts/dwm/autostart.sh`

### Usage

```bash
# Show current autostart entries
~/.local/s1barch/scripts/dwm/autostart.sh list

# Add new autostart entry
~/.local/s1barch/scripts/dwm/autostart.sh add "firefox"

# Add autostart with options
~/.local/s1barch/scripts/dwm/window_rules.sh add "alacritty" --background

# Remove autostart entry
~/.local/s1barch/scripts/dwm/autostart.sh remove "firefox"

# Clear all autostart entries
~/.local/s1barch/scripts/dwm/autostart.sh clear

# Test autostart (run without restarting DWM)
~/.local/s1barch/scripts/dwm/autostart.sh test
```

### Autostart Configuration File

Autostart configuration is stored in `~/.config/dwm/autostart.sh`:

```bash
#!/bin/bash

# Load environment variables
source ~/.config/dwm/config

# System tray icons
nm-applet &
blueman-applet &
volumeicon &
pasystray &

# Background services
redshift &
nextcloud &
telegram-desktop &

# Window manager utilities
picom &
unclutter &

# Wallpaper
feh --bg-scale ~/Pictures/wallpapers/current.jpg

# Keyboard layouts
setxkbmap us,ru
setxkbmap -option grp:alt_shift_toggle
```

### Adding Applications to Autostart

```bash
# Add Firefox
~/.local/s1barch/scripts/dwm/autostart.sh add "firefox"

# Add Slack
~/.local/s1barch/scripts/dwm/autostart.sh add "slack"

# Add custom script
~/.local/s1barch/scripts/dwm/autostart.sh add "/path/to/script.sh"

# Add application with arguments
~/.local/s1barch/scripts/dwm/autostart.sh add "alacritty -e tmux"
```

---

## DWM Configuration

### Overview

DWM configuration file location and customization.

### Configuration Files

| File | Location | Purpose |
|:---|:---:|:---|
| **dwm.c** | `~/.local/src/dwm/` | DWM source code |
| **config.h** | `~/.local/src/dwm/` | DWM configuration |
| **autostart.sh** | `~/.config/dwm/` | Autostart scripts |
| **dwm_bar.sh** | `~/.config/dwm/` | Status bar script |
| **dwm_keys.h** | `~/.config/dwm/` | Custom keybindings |

### Recompiling DWM

After modifying `dwm.c` or `config.h`, recompile:

```bash
# Navigate to DWM source directory
cd ~/.local/src/dwm

# Clean build
make clean

# Recompile
sudo make install

# Restart DWM (Mod+Shift+Q)
# Or kill and restart:
pkill dwm
dwm &
```

### Status Bar Configuration

DWM status bar is configured in `~/.config/dwm/dwm_bar.sh`:

```bash
#!/bin/bash

# Status bar information
STATUS=""
STATUS="$STATUS $(date '+%Y-%m-%d %H:%M:%S')"
STATUS="$STATUS | $(~/.local/s1barch/scripts/networking/network_status.sh)"
STATUS="$STATUS | $(~/.local/s1barch/scripts/audio/audio_status.sh)"

# Set status
xsetroot -name "$STATUS"
```

---

## Usage Examples

### Productive Window Workflow

```bash
# Terminal on tag 1
~/.local/s1barch/scripts/dwm/window_control.sh tag 1
alacritty -e tmux

# Browser on tag 2
~/.local/s1barch/scripts/dwm/window_control.sh tag 2
firefox

# Code editor on tag 3
~/.local/s1barch/scripts/dwm/window_control.sh tag 3
vscodium

# Quick switch between tags
~/.local/s1barch/scripts/dwm/window_control.sh tag 1
~/.local/s1barch/scripts/dwm/window_control.sh tag 2
~/.local/s1barch/scripts/dwm/window_control.sh tag 3
```

### Monitor Workflow

```bash
# Move window to second monitor
~/.local/s1barch/scripts/dwm/window_control.sh move-next-monitor

# Focus previous monitor
~/.local/s1barch/scripts/dwm/window_control.sh focus-prev-monitor

# Toggle tag view on both monitors
~/.local/s1barch/scripts/dwm/window_control.sh toggleview 1
```

### Window Management Workflow

```bash
# Start with tiled layout
~/.local/s1barch/scripts/dwm/window_control.sh layout tiled

# Open multiple terminals
alacritty &
alacritty &
alacritty &

# Switch between windows
~/.local/s1barch/scripts/dwm/window_control.sh next
~/.local/s1barch/scripts/dwm/window_control.sh prev

# Make terminal floating
~/.local/s1barch/scripts/dwm/window_control.sh toggle-float

# Toggle fullscreen
~/.local/s1barch/scripts/dwm/window_control.sh toggle-fullscreen
```

---

## Troubleshooting

### Window Control Not Working

**Problem:** Window commands not responding

**Diagnosis:** DWM not running or wrong permissions

**Solution:**
```bash
# Check if DWM is running
pgrep dwm

# Check DWM logs
tail -f ~/.xsession-errors

# Restart DWM (Mod+Shift+Q)
# Or via terminal:
pkill dwm
dwm &
```

### Window Rules Not Applying

**Problem:** Windows not following rules

**Diagnosis:** Window class/instance mismatch

**Solution:**
```bash
# Get window class and instance
xprop | grep WM_CLASS

# Check current rules
~/.local/s1barch/scripts/dwm/window_rules.sh list

# Add correct rule with exact class
~/.local/s1barch/scripts/dwm/window_rules.sh add \
    --class "CorrectClass" --tag "1" --floating false
```

### Autostart Not Running

**Problem:** Autostart applications not launching

**Diagnosis:** autostart.sh not executable or wrong path

**Solution:**
```bash
# Check autostart permissions
ls -l ~/.config/dwm/autostart.sh

# Make executable
chmod +x ~/.config/dwm/autostart.sh

# Test autostart
~/.local/s1barch/scripts/dwm/autostart.sh test

# Check autostart file content
cat ~/.config/dwm/autostart.sh
```

### Status Bar Not Updating

**Problem:** Status bar stuck or not showing information

**Diagnosis:** dwm_bar.sh not running or error

**Solution:**
```bash
# Check if bar is running
pgrep dwm_bar.sh

# Run bar manually
bash ~/.config/dwm/dwm_bar.sh &

# Check bar script for errors
bash -n ~/.config/dwm/dwm_bar.sh

# Check system logs
tail -f ~/.xsession-errors
```

### Multiple Monitors Not Working

**Problem:** Windows not moving to second monitor

**Diagnosis:** xrandr not configured

**Solution:**
```bash
# Check connected monitors
xrandr

# Configure second monitor
xrandr --output HDMI-1 --auto --right-of eDP-1

# Test monitor switching
~/.local/s1barch/scripts/dwm/window_control.sh move-next-monitor
```

---

## Advanced Configuration

### Custom Keybindings

Add custom keybindings to DWM:

```bash
# Edit DWM config.h
nano ~/.local/src/dwm/config.h

# Add keybinding example:
static Key keys[] = {
    /* modifier         key         function        argument */
    { MODKEY,           XK_w,       spawn,          {.v = cmdbrowser } },
    { MODKEY,           XK_e,       spawn,          {.v = cmdeditor } },
    { MODKEY,           XK_Return,  spawn,          {.v = cmdterm } },
};

// Recompile DWM
cd ~/.local/src/dwm
sudo make install
pkill dwm
dwm &
```

### Custom Layouts

Create custom DWM layouts:

```bash
# Edit DWM config.h
nano ~/.local/src/dwm/config.h

// Add custom layout:
static const Layout layouts[] = {
    /* symbol     arrange function */
    { "[]=",      tile },    /* default */
    { "><>",      NULL },    /* no layout */
    { "[M]",      monocle }, /* monocle */
    { "HHH",      bstack },  /* custom */
};

// Recompile DWM
cd ~/.local/src/dwm
sudo make install
pkill dwm
dwm &
```

### Status Bar Colors

Customize status bar colors:

```bash
# Edit DWM config.h
nano ~/.local/src/dwm/config.h

// Color schemes
static const char *colors[][3] = {
    /* fg        bg        border */
    [SchemeNorm] = { "#bbbbbb", "#222222", "#444444" },
    [SchemeSel]  = { "#eeeeee", "#005577", "#005577" },
};

// Recompile DWM
cd ~/.local/src/dwm
sudo make install
pkill dwm
dwm &
```

---

## Quick Reference

| Task | Command |
|:---|:---:|
| **Next Window** | `~/.local/s1barch/scripts/dwm/window_control.sh next` |
| **Prev Window** | `~/.local/s1barch/scripts/dwm/window_control.sh prev` |
| **Kill Window** | `~/.local/s1barch/scripts/dwm/window_control.sh kill` |
| **Toggle Float** | `~/.local/s1barch/scripts/dwm/window_control.sh toggle-float` |
| **Toggle Fullscreen** | `~/.local/s1barch/scripts/dwm/window_control.sh toggle-fullscreen` |
| **Switch Tag 1** | `~/.local/s1barch/scripts/dwm/window_control.sh tag 1` |
| **Move to Tag 1** | `~/.local/s1barch/scripts/dwm/window_control.sh movetotag 1` |
| **Add Rule** | `~/.local/s1barch/scripts/dwm/window_rules.sh add ...` |
| **List Rules** | `~/.local/s1barch/scripts/dwm/window_rules.sh list` |
| **Add Autostart** | `~/.local/s1barch/scripts/dwm/autostart.sh add ...` |
| **List Autostart** | `~/.local/s1barch/scripts/dwm/autostart.sh list` |

---

## For More Information

- [Main README](../README.md)
- [Installation Guide](01_INSTALLATION.md)
- [DWM Setup Guide](02_DWM_SETUP.md)
- [Audio Management](03_AUDIO.md)
- [Battery Management](04_BATTERY.md)
- [Display Management](05_DISPLAY.md)
- [Networking](07_NETWORKING.md)
- [System Management](08_SYSTEM.md)
- [Workflows](09_WORKFLOWS.md)
- [Customization](10_CUSTOMIZATION.md)
- [Troubleshooting](11_TROUBLESHOOTING.md)
- [API Reference](12_API_REFERENCE.md)
