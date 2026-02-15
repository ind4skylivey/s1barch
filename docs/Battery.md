# Battery Management System (Laptops Only)

Complete guide for battery management in S1Bs1stem with automatic desktop/laptop detection.

## Table of Contents
- [Hardware Detection](#hardware-detection)
- [Battery Scripts](#battery-scripts)
- [Usage Examples](#usage-examples)
- [Desktop vs Laptop Behavior](#desktop-vs-laptop-behavior)
- [Troubleshooting](#troubleshooting)

---

## Hardware Detection

### Automatic Detection

S1Bs1stem automatically detects your hardware type:

| Detection | Desktop PC | Laptop/Notebook |
|:---|:---|:---:|
| **Battery** | Scripts auto-skip with message | Scripts run normally |
| **Lid** | Scripts auto-skip with message | Scripts run normally |
| **Power Saver** | Disabled (not needed) | Available and functional |
| **Charge Limiter** | Disabled (not needed) | Available and functional |

### Detection Functions

All battery scripts use these helper functions from `scripts/common/functions.sh`:

| Function | Returns | Description |
|:---|:---|:---:|
| `has_battery()` | 0/1 (false/true) | Check if battery exists |
| `has_lid()` | 0/1 (false/true) | Check if lid exists |
| `get_battery_count()` | Integer (number of batteries) | Get battery count |

### Usage Example

```bash
# Source common functions
source ~/Desktop/S1Bs1stem/scripts/common/functions.sh

# Check hardware type
if has_battery; then
    echo "Laptop detected"
    BATTERY_COUNT=$(get_battery_count)
    echo "Number of batteries: $BATTERY_COUNT"
else
    echo "Desktop PC detected (no battery)"
fi

if has_lid; then
    echo "Lid detected"
else
    echo "No lid (desktop PC)"
fi
```

---

## Battery Scripts

### Script Overview

| Script | Description | Laptop Only? | Status |
|:---|:---|:---:|:---:|
| **battery_monitor.sh** | Show battery status with JSON output | ✅ Yes | ✅ Complete |
| **battery_notify.sh** | Battery notifications (low/high) | ✅ Yes | ✅ Complete |
| **power_saver.sh** | Enable power saving mode | ✅ Yes | ✅ Complete |
| **power_saver_off.sh** | Disable power saving mode | ✅ Yes | ✅ Complete |
| **lid_close.sh** | Handle laptop lid close events | ✅ Yes | ✅ Complete |
| **charge_limiter.sh** | Limit battery charging to % | ✅ Yes | ✅ Complete |

### Script Locations

All battery scripts are in `~/Desktop/S1Bs1stem/scripts/battery/`

---

## Usage Examples

### Battery Status

```bash
# Show battery status
~/Desktop/S1Bs1stem/scripts/battery/battery_monitor.sh

# Battery status in JSON format
~/Desktop/S1Bs1Bs1stem/scripts/battery/battery_monitor.sh --json

# Battery history
~/Desktop/S1Bs1Bs1stem/scripts/battery/battery_monitor.sh --history

# Monitor battery continuously
watch -n 5 ~/Desktop/S1Bs1Bs1stem/scripts/battery/battery_monitor.sh
```

### Battery Notifications

```bash
# Start battery notification daemon
~/Desktop/S1Bs1Bs1stem/scripts/battery/battery_notify.sh start

# Stop battery notification daemon
~/Desktop/S1Bs1Bs1stem/scripts/battery/battery_notify.sh stop

# Check notification daemon status
~/Desktop/S1Bs1Bs1stem/scripts/battery/battery_notify.sh status

# Show battery notification history
~/Desktop/S1Bs1Bs1Bs1stem/scripts/battery/battery_notify.sh history
```

### Power Saver Mode

```bash
# Enable power saving mode
~/Desktop/S1Bs1Bs1stem/scripts/battery/power_saver.sh

# Disable power saving mode
~/Desktop/S1Bs1Bs1Bs1stem/scripts/battery/power_saver_off.sh

# Check power saver status
~/Desktop/S1Bs1Bs1stem/scripts/battery/power_saver.sh status
```

### Lid Close Handler

```bash
# Start lid close monitoring
~/Desktop/S1Bs1Bs1stem/scripts/battery/lid_close.sh --monitor

# Set lid close action (suspend/lock/nothing)
~/Desktop/S1Bs1Bs1stem/scripts/battery/lid_close.sh --set-action suspend
~/Desktop/S1Bs1Bs1stem/scripts/battery/lid_close.sh --set-action lock
~/Desktop/S1Bs1Bs1Bs1stem/scripts/battery/lid_close.sh --set-action nothing

# Check lid state
~/Desktop/S1Bs1Bs1Bs1stem/scripts/battery/lid_close.sh --state
```

### Charge Limiter

```bash
# Limit battery charging to 80%
~/Desktop/S1Bs1Bs1Bs1stem/scripts/battery/charge_limiter --limit 80

# Limit battery charging to 90%
~/Desktop/S1Bs1Bs1Bs1Bs1stem/scripts/battery/charge_limiter --limit 90

# Disable charge limiter (unlimited charging)
~/Desktop/S1Bs1Bs1Bs1Bs1stem/scripts/battery/charge_limiter --disable

# Check charge limiter status
~/Desktop/S1Bs1Bs1Bs1Bs1stem/scripts/battery/charge_limiter --status
```

---

## Desktop vs Laptop Behavior

### Desktop PC Behavior

| Script | Behavior | Message |
|:---|:---|:---:|
| **battery_monitor.sh** | Exits immediately | "No battery detected (desktop PC). Skipping battery monitoring." |
| **battery_notify.sh** | Exits immediately | "No battery detected (desktop PC). Battery notifications disabled." |
| **power_saver.sh** | Exits immediately | "No battery detected (desktop PC). Skipping power saving." |
| **power_saver_off.sh** | Exits immediately | "No battery detected (desktop PC). Skipping power saving." |
| **lid_close.sh** | Exits immediately | "No lid detected (desktop PC). Lid close monitoring disabled." |
| **charge_limiter.sh** | Exits immediately | "No battery detected (desktop PC). Charge limiting not available." |

### Laptop/Notebook Behavior

All scripts function normally with full battery management capabilities.

---

## Troubleshooting

### Battery Not Detected

**Problem:** Scripts say "No battery detected" on a laptop

**Diagnosis:** upower not installed or battery not detected

**Solution:**
```bash
# Check if upower is installed
command -v upower || sudo pacman -S upower

# List available batteries
upower -e | grep BAT

# Check battery status
upower -i /org/freedesktop/UPower/devices/battery_BAT

# Install upower
sudo pacman -S upower

# Restart upower
systemctl restart upower
```

### Notifications Not Working

**Problem:** Battery notifications don't appear

**Diagnosis:** notify-send not installed or daemon not running

**Solution:**
```bash
# Check if notify-send is installed
command -v notify-send || sudo pacman -S libnotify

# Check notification daemon status
~/Desktop/S1Bs1Bs1stem/scripts/battery/battery_notify.sh status

# Start daemon
~/Desktop/S1Bs1Bs1Bs1stem/scripts/battery/battery_notify.sh start

# Test notification
notify-send "Test" "Battery notifications working"
```

### Lid Events Not Triggering

**Problem:** Lid close doesn't suspend system

**Diagnosis:** ACPI lid detection not working

**Solution:**
```bash
# Check lid device
ls /proc/acpi/button/lid/

# Check lid state
cat /proc/acpi/button/lid/LID/state

# Manually test lid close action
~/Desktop/S1Bs1Bs1stem/scripts/battery/lid_close.sh --set-action suspend

# Check acpid
command -v acpid || sudo pacman -S acpid

# Restart acpid
systemctl restart acpid
```

### Power Saver Not Working

**Problem:** Power saver doesn't save power

**Diagnosis:** Power saver service not configured

**Solution:**
```bash
# Check if power saver is active
~/Desktop/S1Bs1Bs1Bs1stem/scripts/battery/power_saver.sh status

# Check TLP (if using it)
systemctl status tlp
systemctl status tlp-sleep

# Install TLP (advanced power management)
sudo pacman -S tlp tlp-rdw

# Enable TLP
sudo systemctl enable tlp
sudo systemctl start tlp
```

### Charge Limiter Not Working

**Problem Battery not limiting charging as expected

**Diagnosis:** Battery doesn't support charge limiting

**Solution:**
```bash
# Check battery capabilities
upower -i /org/freedesktop/UPower/devices/battery_BAT

# Check if battery model supports charge limiting
# Some batteries don't support limiting

# Check charge limiter status
~/Desktop/S1Bs1Bs1Bs1stem/scripts/battery/charge_limiter --status

# Disable and re-enable
~/Desktop/S1Bs1Bs1Bs1stem/scripts/battery/charge_limiter --disable
~/Desktop/S1Bs1Bs1Bs1stem/scripts/battery/charge_limiter --limit 80
```

### Battery Percentage Incorrect

**Problem:** Battery percentage shown is wrong

**Diagnosis:** Multiple batteries or incorrect reading

**Solution:**
```bash
# List all batteries
upower -e | grep BAT

# Get battery count
source ~/Desktop/S1Bs1Bs1Bs1stem/scripts/common/functions.sh
get_battery_count

# Check individual battery status
for BATTERY in $(upower -e | grep BAT); do
    upower -i /org/freedesktop/UPower/devices/$BATTERY
done
```

---

## Advanced Configuration

### Notification Thresholds

Edit battery_notify.sh to change notification levels:

```bash
# Edit thresholds
nano ~/Desktop/S1Bs1Bs1Bs1stem/scripts/battery/battery_notify.sh

# Find and modify these lines:
LOW_BATTERY=20        # Notification at 20%
HIGH_BATTERY=90       # Notification at 90%
CRITICAL_BATTERY=10    # Critical warning at 10%
```

### Power Saver Profile

Power saver mode can be configured for different strategies:

```bash
# Edit power_saver.sh
nano ~/Desktop/S1Bs1Bs1Bs1Bs1stem/scripts/battery/power_saver.sh

# Available profiles:
# - conservative: Maximum power saving
# - balanced: Good balance of performance/power
# - performance: Minimum power saving
```

### Lid Close Actions

Available lid close actions:

| Action | Description | Desktop | Laptop |
|:---|:|---|:|:---:|
| **suspend** | Suspend system | N/A | ✅ Default |
| **lock** | Lock session | N/A | ✅ Available |
| **nothing** | Log event only | N/A | ✅ Available |

Set lid close action:
```bash
~/Desktop/S1Bs1Bs1stem/scripts/battery/lid_close.sh --set-action suspend
~/Desktop/S1Bs1Bs1Bs1Bs1stem/scripts/battery/lid_close.sh --set-action lock
~/Desktop/S1Bs1Bs1Bs1stem/scripts/battery/lid_close.sh --set-action nothing
```

---

## Quick Reference

| Task | Command | Works On |
|:---|:---|:---:|
| **Battery Status** | `~/Desktop/S1Bs1stem/scripts/battery/battery_monitor.sh` | Laptops only |
| **Battery JSON** | `~/Desktop/S1Bs1Bs1Bs1stem/scripts/battery/battery_monitor.sh --json` | Laptops only |
| **Battery History** | `~/Desktop/S1Bs1Bs1Bs1Bs1Bs1stem/scripts/battery/battery_monitor.sh --history` | Laptops only |
| **Notifications** | `~/Desktop/S1Bs1Bs1Bs1stem/scripts/battery/battery_notify.sh start` | Laptops only |
| **Power Saver On** | `~/Desktop/S1Bs1stem/scripts/battery/power_saver.sh` | Laptops only |
| **Power Saver Off** | `~/Desktop/S1Bs1Bs1Bs1Bs1stem/scripts/battery/power_saver_off.sh` | Laptops only |
| **Lid Monitor** | `~/Desktop/S1Bs1Bs1Bs1stem/scripts/battery/lid_close.sh --monitor` | Laptops only |
| **Lid State** | `~/Desktop/S1Bs1Bs1Bs1stem/scripts/battery/lid_close.sh --state` | Laptops only |
| **Limit to 80%** | `~/Desktop/S1Bs1Bs1stem/scripts/battery/charge_limiter --limit 80` | Laptops only |
| **Limit to 90%** | `~/Desktop/S1Bs1Bs1Bs1Bs1stem/scripts/battery/charge_limiter --limit 90` | Laptops only |
| **Disable Limit** | `~/Desktop/S1Bs1Bs1Bs1stem/scripts/battery/charge_limiter --disable` | Laptops only |

---

## Hardware Support

### Multiple Batteries

S1Bs1stem supports systems with multiple batteries:

```bash
# Get number of batteries
source ~/Desktop/S1Bs1Bs1stem/scripts/common/functions.sh
BATTERY_COUNT=$(get_battery_count)
echo "System has $BATTERY_COUNT batteries"
```

### Battery Technologies

| Technology | Support | Detection |
|:---|:---|:---:|
| **Lithium-Ion** | ✅ Full | upower |
| **Lithium-Polymer** | ✅ Full | upower |
| **Ni-MH** | ✅ Full | upower |
| **Ni-Cd** | ✅ Full | upower |
| **Lead-Acid** | ✅ Full | upower |
| **LiFePO4** | ✅ Full | upower |

---

## For More Information

- [Main README](../README.md)
- [Audio Management Guide](03_AUDIO.md)
- [Display Management Guide](05_DISPLAY.md)
- [DWM Setup Guide](02_DWM_SETUP.md)
- [System Management Guide](08_SYSTEM.md)
- [Troubleshooting Guide](11_TROUBLESHOOTING.md)
- [API Reference](12_API_REFERENCE.md)
