# DWM Window Manager Setup Guide

Complete guide for setting up and configuring DWM (Dynamic Window Manager) with S1Bs1stem.

## Table of Contents
- [DWM Overview](#dwm-overview)
- [Installation](#installation)
- [Configuration](#configuration)
- [Patches Available](#patches-available)
- [Autostart System](#autostart-system)
- [Window Management](#window-management)
- [Customization](#customization)
- [Troubleshooting](#troubleshooting)

---

## DWM Overview

### What is DWM?

DWM is a dynamic, minimal, and extremely fast window manager for X11. It manages windows in tiled, floating, or monocle layouts.

### Features
- **Tiling layouts** - Efficient use of screen space
- **Patching support** - Easy to modify and extend
- **Systray support** - Native system tray integration
- **Window swallowing** - Apps open in DWM context
- **Keyboard-driven** - Full control without mouse
- **Extremely lightweight** - Minimal RAM and CPU usage

### S1Bs1stem DWM Patches

| Patch | Description | Status |
|:---|:---:|:---:|
| **Systray** | System tray for network, volume, etc. | ✅ Included |
| **Window Swallowing** | Apps like Discord show in DWM | ✅ Included |
| **Center Window** | Center windows in floating mode | ✅ Included |
| **Autostart Support** | Automatic app startup on DWM launch | ✅ Included |
| **Status Bar Hooks** | Waybar integration | ✅ Included |

---

## Installation

### Install DWM from Source

```bash
# Install build dependencies
sudo pacman -S xorg-xorg xorg-xorg-devel libx11 libx11-devel libxft libxft-devel libxinerama

# Clone DWM repository
git clone https://git.suckless.org/dwm.git ~/.local/src/dwm
cd ~/.local/src/dwm

# Apply S1Bs1stem patches
# Patches are automatically copied from dotfiles-s1b
# See: ~/.config/dwm/patches/

# Install
sudo make clean install
```

### Install DWM Package (Alternative)

```bash
# Install from AUR
yay -S dwm-s1b
# OR
paru -S dwm-s1b

# The dwm-s1b package includes S1Bs1stem's patches pre-applied
```

### S1Bs1stem DWM Setup

```bash
# DWM setup is handled by ORCHESTRA.sh
# Or run individually:
cd ~/Desktop/S1Bs1stem
./install/modules/010_dwm_setup.sh
```

This script:
1. Copies DWM config from `dotfiles-s1b/.config/dwm/`
2. Copies patches to `~/.config/dwm/patches/`
3. Compiles DWM if source is present
4. Creates autostart script

---

## Configuration

### Main Config File

**Location:** `~/.config/dwm/config.h`

This is the main configuration file where you can customize:
- Tag layouts
- Keybindings
- Colors
- Behavior
- Layouts

### Configuration Options

| Option | Default | Description |
|:---|:---|:---:|
| **Terminal** | st | Default terminal command |
| **Border Width** | 1px | Window border thickness |
| **Outer Border** | 0px | Gap between windows |
| **Inner Border** | 0px | Gap within border |
| **Gap** | 0px | Gap between windows |
| **Mod Key** | Mod4 | Super key |
| **Autostart** | True | Start apps on DWM launch |
| **Systray** | True | Enable system tray |
| **Swallowing** | True | Window swallowing enabled |

### Status Bar

DWM itself doesn't include a status bar. S1Bs1stem integrates with:
- **Waybar** - Full-featured status bar
- **Systray** - Native system tray support

See: [Display Management Guide](05_DISPLAY.md) for setup

---

## Patches Available

### S1Bs1stem DWM Patches

All patches are located in `~/.config/dwm/patches/`

#### 1. Systray Patch

Adds system tray support to DWM.

**Features:**
- NetworkManager applet
- Volume control
- Bluetooth
- Power management
- Application notifications

**Configuration:** `config.h`
```c
#define SYSTRAY(Bar) patch
```

#### 2. Window Swallowing Patch

Allows DWM to "swallow" (embed) apps like Discord into its window frame.

**Supported Apps:**
- Discord
- Slack
- Teams
- Spotify
- And more

**Configuration:** `config.h`
```c
#define SWALLOW 1
```

#### 3. Center Window Patch

Centers floating windows on the screen.

**Configuration:** `config.h`
```c
static const int centerwindows = 1;
```

#### 4. Autostart Patch

Enables autostart system integration.

**Configuration:** `config.h`
```c
#define AUTOSTART 1
```

### Applying Patches

When you modify `config.h`, you need to recompile DWM:

```bash
cd ~/.config/dwm
sudo make clean install
```

---

## Autostart System

### What is Autostart?

Autostart automatically starts applications when DWM launches.

### Autostart Configuration

**Location:** `~/.config/dwm/autostart.sh`

**Usage:**
```bash
# Start all autostart apps
~/Desktop/S1Bs1stem/scripts/dwm/autostart.sh start

# Stop specific app
~/Desktop/S1Bs1stem/scripts/dwm/autostart.sh stop picom

# Restart specific app
~/Desktop/S1Bs1stem/scripts/dwm/autostart.sh restart dunst

# View status
~/Desktop/S1Bs1stem/scripts/dwm/autostart.sh status

# List all apps
~/Desktop/S1Bs1stem/scripts/dwm/autostart.sh list
```

### Desktop vs Laptop Profiles

Autostart detects your hardware and loads appropriate profile:

| Component | Desktop Profile | Laptop Profile |
|:---|:---|:---:|
| **picom** | picom, unclutter | picom, unclutter |
| **dunst** | dunst | dunst |
| **nm-applet** | nm-applet, blueman-applet | nm-applet, blueman-applet |
| **volumeicon** | volumeicon, pasystray | volumeicon, pasystray |
| **flameshot** | flameshot | flameshot |
| **clipmenud** | clipmenud | clipmenud |
| **feh** | feh (~/.fehbg) | feh (~/.fehbg) |
| **redshift** | redshift | redshift |
| **Power** | None | xautolock, tlp/powertop |

**Hardware Detection:**
```bash
source ~/Desktop/S1Bs1stem/scripts/common/functions.sh

if has_battery; then
    echo "Laptop profile loaded"
    # Includes power management tools
else
    echo "Desktop profile loaded"
    # Skips power management tools
fi
```

---

## Window Management

### DWM Scripts

| Script | Description | Status |
|:---|:---|:---:|
| **window_control.sh** | Complete window management | ✅ Complete |
| **window_rules.sh** | Application-specific rules | ✅ Complete |
| **autostart.sh** | Autostart management | ✅ Complete |

### Window Control Commands

```bash
# Navigate windows
~/Desktop/S1Bs1stem/scripts/dwm/window_control.sh focus-next      # Focus next window
~/Desktop/S1Bs1stem/scripts/dwm/window_control.sh focus-prev      # Focus previous window
~/Desktop/S1Bs1stem/scripts/dwm/window_control.sh swap-master    # Swap with master
~/Desktop/S1Bs1stem/scripts/dwm/window_control.sh zoom            # Zoom focused window

# Window states
~/Desktop/S1Bs1stem/scripts/dwm/window_control.sh toggle-float    # Toggle floating mode
~/Desktop/S1Bs1stem/scripts/dwm/window_control.sh toggle-fullscreen  # Toggle fullscreen

# Tag management
~/Desktop/S1Bs1stem/scripts/dwm/window_control.sh switch-tag 3   # Switch to tag 3
~/Desktop/S1Bs1stem/scripts/dwm/window_control.sh move-to-tag 3  # Move to tag 3

# Kill window
~/Desktop/S1Bs1stem/scripts/dwm/window_control.sh kill            # Kill focused window

# Window info
~/Desktop/S1Bs1stem/scripts/dwm/window_control.sh info
```

### Default Keybindings

| Action | Keybinding | Description |
|:---|:---|:---:|
| **Focus Next** | Super + j | Move to next window |
| **Focus Prev** | Super + k | Move to previous window |
| **Swap Master** | Super + Enter | Swap with master window |
| **Zoom** | Super + Shift + j | Zoom focused window |
| **Kill** | Super + Shift + c | Kill focused window |
| **Toggle Float** | Super + Shift + space | Toggle floating mode |
| **Fullscreen** | Super + f | Toggle fullscreen |
| **Tag 1-9** | Super + 1-9 | Switch to tag |
| **Move to Tag** | Super + Shift + 1-9 | Move to tag |
| **Quit** | Super + Shift + q | Quit DWM |

---

## Customization

### Keybindings

Edit `config.h` to change keybindings:

```c
static const char *tags[] = { "1", "2", "3", "4", "5", "6", "7", "8", "9" };
static const Key keys[] = {
    [Mod1] = XK_1, XK_2, ..., XK_9,
    [Mod1] = XK_q,
    [Mod1] = XK_w,
    // Add more keybindings here
};
```

### Colors

Edit `config.h` to change color scheme:

```c
static const char *colors[][SchemeLen][SchemeLen] = {
    // Border colors
    [SchemeNorm] = { col_border, col_fg },
    [SchemeSel] = { col_border, col_bg },
    // Add more color schemes
};
```

### Layouts

Edit `config.h` to customize tile layouts:

```c
static const Layout layouts[] = {
    /* symbol */ arrange function */
    { "[]", tile }, /* first entry is default */
    { "[]=", tile },
    { "[]%", tile },
    { "><>", NULL },     /* no layout function means floating behavior */
    { "[M]", monocle },
};
```

### Creating Custom Patches

1. Copy `~/.config/dwm/config.h` to `~/.config/dwm/config.h.bak`
2. Edit `~/.config/dwm/config.h` with your changes
3. Recompile DWM:
   ```bash
   cd ~/.config/dwm
   sudo make clean install
   ```

---

## Troubleshooting

### DWM Won't Start

**Problem:** DWM doesn't start or crashes

**Solutions:**
```bash
# Check DWM is installed
command -v dwm || echo "DWM not installed"

# Check DWM config syntax
~/.config/dwm/config.h  # Should be valid C syntax

# Check for X11 errors
cat ~/.xsession-errors

# Test DWM manually
dwm  # Run from TTY or terminal
```

### Patches Not Applied

**Problem:** Custom patches don't work

**Solution:**
```bash
# Check if patches directory exists
ls -la ~/.config/dwm/patches/

# Reinstall DWM from source
cd ~/.local/src/dwm
sudo make clean install
```

### Autostart Not Working

**Problem:** Apps don't start automatically

**Solutions:**
```bash
# Check autostart script status
~/Desktop/S1Bs1stem/scripts/dwm/autostart.sh status

# Start autostart manually
~/Desktop/S1Bs1stem/scripts/dwm/autostart.sh start

# Check autostart configuration
cat ~/.config/dwm/autostart.sh
```

### Window Rules Not Working

**Problem:** Window rules don't apply to applications

**Solution:**
```bash
# Check window class
xdotool getactivewindow getwindowclassname

# Manually apply rules
~/Desktop/S1Bs1stem/scripts/dwm/window_rules.sh apply

# List current rules
~/Desktop/S1Bs1stem/scripts/dwm/window_rules.sh list

# Generate sample rules
~/Desktop/S1Bs1stem/scripts/dwm/window_rules.sh generate
```

### DWM Compilation Fails

**Problem:** `make install` fails

**Solution:**
```bash
# Check dependencies
sudo pacman -S xorg-xorg-devel libx11-devel libxft-devel libxinerama-devel

# Check Makefile
cat ~/.config/dwm/Makefile

# Clean and retry
cd ~/.config/dwm
sudo make clean
sudo make install
```

### Systray Issues

**Problem:** System tray not showing

**Solution:**
```bash
# Check if systray patch is applied
grep SYSTRAY ~/.config/dwm/config.h

# Restart DWM
killall dwm && dwm &

# Check Waybar status
pgrep waybar
```

---

## Quick Reference

| Task | Command |
|:---|:---:|
| **DWM Status** | `pgrep dwm` |
| **Restart DWM** | `killall dwm && dwm &` |
| **Window Control** | `~/Desktop/S1Bs1stem/scripts/dwm/window_control.sh --help` |
| **Window Rules** | `~/Desktop/S1Bs1stem/scripts/dwm/window_rules.sh --help` |
| **Autostart** | `~/Desktop/S1Bs1stem/scripts/dwm/autostart.sh --help` |
| **DWM Config** | `~/.config/dwm/config.h` |
| **DWM Logs** | `~/.xsession-errors` |

---

## For More Information

- [Main README](../README.md)
- [Audio Management Guide](03_AUDIO.md)
- [Battery Management Guide](04_BATTERY.md)
- [Display Management Guide](05_DISPLAY.md)
- [Window Management Guide](06_DWM_WINDOW_MANAGEMENT.md)
- [Networking Guide](07_NETWORKING.md)
- [System Management Guide](08_SYSTEM.md)
- [Workflow Guide](09_WORKFLOWS.md)
- [Customization Guide](10_CUSTOMIZATION.md)
- [Troubleshooting Guide](11_TROUBLESHOOTING.md)
- [API Reference](12_API_REFERENCE.md)
