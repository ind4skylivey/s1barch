# Troubleshooting Guide

Complete troubleshooting guide for common issues in S1Bs1stem.

## Table of Contents
- [Installation Issues](#installation-issues)
- [DWM Issues](#dwm-issues)
- [Hardware Issues](#hardware-issues)
- [Network Issues](#network-issues)
- [Audio Issues](#audio-issues)
- [System Issues](#system-issues)
- [Performance Issues](#performance-issues)
- [Getting Help](#getting-help)

---

## Installation Issues

### ORCHESTRA.sh Fails to Run

**Symptoms:**
- `install/ORCHESTRA.sh` script won't execute
- Permission denied errors
- Syntax errors

**Solutions:**

```bash
# 1. Check script permissions
ls -l ~/Desktop/S1Bs1stem/install/ORCHESTRA.sh
chmod +x ~/Desktop/S1Bs1stem/install/ORCHESTRA.sh

# 2. Check for syntax errors
bash -n ~/Desktop/S1Bs1stem/install/ORCHESTRA.sh

# 3. Check dependencies
bash ~/Desktop/S1Bs1stem/install/preflight/001_dependencies_check.sh

# 4. Run with verbose output
bash -x ~/Desktop/S1Bs1stem/install/ORCHESTRA.sh --interactive
```

### Preflight Checks Failing

**Symptoms:**
- Dependencies check fails
- Disk space check fails
- Network check fails

**Solutions:**

```bash
# Dependencies check failure
sudo pacman -Syu
sudo pacman -S --needed base-devel git

# Disk space check failure
sudo pacman -Sc
sudo pacman -Rns $(pacman -Qtdq)

# Network check failure
ping -c 4 archlinux.org
systemctl restart NetworkManager
nmcli connection up
```

### DWM Compilation Fails

**Symptoms:**
- `make install` fails
- Missing dependencies
- Compilation errors

**Solutions:**

```bash
# 1. Install build dependencies
sudo pacman -S --needed base-devel libx11 libxinerama libxft xorg-xproto

# 2. Navigate to DWM source
cd ~/.local/src/dwm

# 3. Clean and recompile
make clean
make
sudo make install

# 4. Check for missing headers
sudo pacman -S --needed libx11-devel libxft-devel
```

### Shell Setup Fails

**Symptoms:**
- Shell script not sourced
- Alias not working
- Path not updated

**Solutions:**

```bash
# For Zsh
# Check if .zshrc exists
ls -la ~/.zshrc

# Check if script is sourced
grep -n "zsh_setup.sh" ~/.zshrc

# Source manually
source ~/Desktop/S1Bs1stem/scripts/shell/zsh_setup.sh

# For Fish
# Check if config.fish exists
ls -la ~/.config/fish/config.fish

# Check if script is sourced
grep -n "fish_setup.fish" ~/.config/fish/config.fish

# Source manually
source ~/Desktop/S1Bs1stem/scripts/shell/fish_setup.fish
```

---

## DWM Issues

### DWM Won't Start

**Symptoms:**
- `dwm` command fails
- X session won't start
- Blank screen after login

**Solutions:**

```bash
# 1. Check if DWM is installed
command -v dwm

# 2. Reinstall DWM
cd ~/.local/src/dwm
sudo make install

# 3. Check Xsession logs
tail -f ~/.xsession-errors

# 4. Start DWM manually
startx
# Or:
exec dwm

# 5. Check for syntax errors in config.h
cd ~/.local/src/dwm
make clean
sudo make install
```

### Keybindings Not Working

**Symptoms:**
- Mod+Shift+Enter not opening terminal
- Mod+Shift+Q not killing DWM
- Custom keybindings not responding

**Solutions:**

```bash
# 1. Check Mod key setting (usually Mod4 = Super/Windows key)
# In config.h:
#define MODKEY Mod4

# 2. Check keybindings in config.h
grep -A 50 "static Key keys" ~/.local/src/dwm/config.h

# 3. Recompile DWM
cd ~/.local/src/dwm
sudo make install

# 4. Check if xev is working (to test key events)
xev

# 5. Kill and restart DWM
pkill dwm
dwm &
```

### Window Layout Issues

**Symptoms:**
- Windows not tiling correctly
- Layout not changing
- Master window not resizing

**Solutions:**

```bash
# 1. Switch layouts manually
# Mod+Space to cycle layouts
# Mod+T for tiled
# Mod+F for floating
# Mod+M for monocle

# 2. Reset layout
xmodmap -e "clear Mod4" -e "add Mod4 = Super_L Super_R"

# 3. Check config.h layout definitions
grep -A 10 "static const Layout" ~/.local/src/dwm/config.h

# 4. Recompile DWM
cd ~/.local/src/dwm
sudo make install

# 5. Kill and restart DWM
pkill dwm
dwm &
```

### Status Bar Not Showing

**Symptoms:**
- Status bar is empty
- Status bar not updating
- Status bar wrong color/font

**Solutions:**

```bash
# 1. Check if bar script is running
pgrep dwm_bar.sh

# 2. Run bar script manually
bash ~/.config/dwm/dwm_bar.sh &

# 3. Check bar script for errors
bash -n ~/.config/dwm/dwm_bar.sh
bash ~/.config/dwm/dwm_bar.sh

# 4. Check xsetroot command
xsetroot -name "Test status bar"

# 5. Check bar script output
bash ~/.config/dwm/dwm_bar.sh 2>&1 | head -20
```

---

## Hardware Issues

### Battery Detection Issues (Laptops)

**Symptoms:**
- Battery status not showing
- Battery scripts not working
- Battery percentage incorrect

**Solutions:**

```bash
# 1. Check if upower is installed
command -v upower || sudo pacman -S upower

# 2. List batteries
upower -e

# 3. Check battery details
upower -i $(upower -e | grep BAT)

# 4. Check hardware detection functions
source ~/Desktop/S1Bs1stem/scripts/common/functions.sh
has_battery && echo "Battery found" || echo "No battery"
get_battery_count

# 5. Check if script is skipping battery detection
bash -x ~/Desktop/S1Bs1stem/scripts/battery/battery_status.sh 2>&1 | head -50
```

### Lid Detection Issues (Laptops)

**Symptoms:**
- Lid status not detected
- Screen not sleeping on lid close
- Lid switch not working

**Solutions:**

```bash
# 1. Check lid switch
source ~/Desktop/S1Bs1stem/scripts/common/functions.sh
has_lid && echo "Lid detected" || echo "No lid"

# 2. Check acpi button
ls /proc/acpi/button/lid/

# 3. Check systemd logind settings
cat /etc/systemd/logind.conf | grep HandleLidSwitch

# 4. Enable lid switch in logind.conf
# Edit /etc/systemd/logind.conf:
# HandleLidSwitch=suspend

# 5. Restart systemd-logind
sudo systemctl restart systemd-logind
```

### Audio Detection Issues

**Symptoms:**
- Audio status not showing
- Audio controls not working
- Wrong audio system detected

**Solutions:**

```bash
# 1. Check audio system detection
source ~/Desktop/S1Bs1stem/scripts/common/functions.sh
get_audio_system
has_pulseaudio && echo "PulseAudio found" || echo "No PulseAudio"
has_pipewire && echo "PipeWire found" || echo "No PipeWire"

# 2. Check if pactl is installed (for both PulseAudio and PipeWire)
command -v pactl || sudo pacman -S pipewire-pulse

# 3. Check audio command
get_audio_command

# 4. Test audio status manually
pactl list sinks short

# 5. Test audio control
bash -x ~/Desktop/S1Bs1stem/scripts/audio/audio_status.sh 2>&1 | head -50
```

### Display/Brightness Issues (Laptops)

**Symptoms:**
- Brightness control not working
- xbacklight not installed
- No backlight device

**Solutions:**

```bash
# 1. Check if xbacklight is installed
command -v xbacklight || sudo pacman -S xorg-xbacklight

# 2. Check current brightness
xbacklight -get

# 3. Test brightness control
xbacklight -inc 10
xbacklight -dec 10
xbacklight -set 50

# 4. Check backlight device
ls /sys/class/backlight/

# 5. Use alternative method if xbacklight fails
echo 100 | sudo tee /sys/class/backlight/*/brightness
```

---

## Network Issues

### Network Not Connecting

**Symptoms:**
- WiFi not connecting
- Ethernet not working
- IP address not assigned

**Solutions:**

```bash
# 1. Check NetworkManager status
systemctl status NetworkManager

# 2. Restart NetworkManager
sudo systemctl restart NetworkManager

# 3. Check WiFi radio
nmcli radio wifi
nmcli radio wifi on

# 4. Scan for networks
nmcli device wifi list

# 5. Connect to network
nmcli device wifi connect <SSID> password <PASSWORD>

# 6. Check connection status
nmcli connection show
nmcli device status

# 7. Check IP address
ip addr show
ping -c 4 archlinux.org
```

### DNS Not Resolving

**Symptoms:**
- Can't access websites by name
- DNS lookup failures
- DNS switch not working

**Solutions:**

```bash
# 1. Check current DNS
nmcli dev show | grep DNS

# 2. Switch DNS
~/Desktop/S1Bs1stem/scripts/networking/dns_switch.sh cloudflare
~/Desktop/S1Bs1stem/scripts/networking/dns_switch.sh google

# 3. Flush DNS cache
sudo systemctl restart systemd-resolved

# 4. Test DNS resolution
ping -c 4 archlinux.org
nslookup archlinux.org

# 5. Manually set DNS
nmcli connection modify <connection> ipv4.dns "1.1.1.1 8.8.8.8"
```

### VPN Connection Issues

**Symptoms:**
- VPN won't connect
- VPN authentication fails
- VPN connection drops

**Solutions:**

```bash
# 1. Check VPN status
~/Desktop/S1Bs1stem/scripts/networking/vpn_connect.sh status

# 2. Check VPN logs
journalctl -u NetworkManager -n 100 | grep -i vpn

# 3. Test VPN config file
openvpn3 ~/Desktop/S1Bs1stem/.config/vpn/work.ovpn

# 4. Check dependencies
sudo pacman -S openvpn wireguard-tools

# 5. Restart NetworkManager
sudo systemctl restart NetworkManager

# 6. Kill and restart VPN
~/Desktop/S1Bs1stem/scripts/networking/vpn_connect.sh kill
~/Desktop/S1Bs1stem/scripts/networking/vpn_connect.sh --connect <config>
```

### Tailscale Issues

**Symptoms:**
- Tailscale not connecting
- Tailscale daemon not running
- Tailscale status not showing

**Solutions:**

```bash
# 1. Check Tailscale status
~/Desktop/S1Bs1stem/scripts/networking/tailscale_toggle.sh status

# 2. Check Tailscale daemon
systemctl status tailscaled

# 3. Restart Tailscale
sudo systemctl restart tailscaled

# 4. Check Tailscale logs
journalctl -u tailscaled -n 100

# 5. Re-authenticate device
sudo tailscale up
```

---

## Audio Issues

### Audio Not Playing

**Symptoms:**
- No sound output
- Speakers not detected
- Audio device not listed

**Solutions:**

```bash
# 1. Check audio system
get_audio_system

# 2. List audio devices
pactl list sinks short

# 3. Set default device
pactl set-default-sink <device_name>

# 4. Check volume level
pactl get-sink-volume @DEFAULT_SINK@

# 5. Unmute audio
pactl set-sink-mute @DEFAULT_SINK@ 0

# 6. Test audio
speaker-test -c 2 -t wav
```

### Audio Control Not Working

**Symptoms:**
- Volume up/down not working
- Mute toggle not working
- Keyboard shortcuts not responding

**Solutions:**

```bash
# 1. Test audio commands manually
audio_volume_up
audio_volume_down
audio_toggle_mute

# 2. Check pactl installation
command -v pactl

# 3. Check audio status script
bash -x ~/Desktop/S1Bs1stem/scripts/audio/audio_status.sh 2>&1 | head -50

# 4. Check audio control script
bash -x ~/Desktop/S1Bs1stem/scripts/audio/audio_control.sh 2>&1 | head -50

# 5. Test volume control directly
pactl set-sink-volume @DEFAULT_SINK@ +5%
pactl set-sink-volume @DEFAULT_SINK@ -5%
pactl set-sink-mute @DEFAULT_SINK@ toggle
```

### Audio System Detection Issues

**Symptoms:**
- Wrong audio system detected
- PulseAudio/PipeWire confusion
- Audio commands not working

**Solutions:**

```bash
# 1. Check audio system detection
source ~/Desktop/S1Bs1stem/scripts/common/functions.sh
get_audio_system
has_pulseaudio
has_pipewire

# 2. Check audio processes
ps aux | grep pulse
ps aux | grep pipewire

# 3. Check audio command
get_audio_command

# 4. Check which system is running
# PipeWire:
pactl info | grep "Server Name"

# PulseAudio:
pactl info | grep "Server Name"

# 5. Restart audio system
# For PipeWire:
systemctl --user restart pipewire pipewire-pulse wireplumber

# For PulseAudio:
systemctl --user restart pulseaudio pulseaudio.socket
```

---

## System Issues

### System Info Not Showing

**Symptoms:**
- System information incomplete
- Hardware detection failing
- Incorrect system details

**Solutions:**

```bash
# 1. Check hardware detection tools
command -v lspci || sudo pacman -S pciutils
command -v dmidecode || sudo pacman -S dmidecode
command -v inxi || sudo pacman -S inxi

# 2. Test system info script
bash -x ~/Desktop/S1Bs1stem/scripts/system/system_info.sh 2>&1 | head -50

# 3. Check hardware detection functions
source ~/Desktop/S1Bs1stem/scripts/common/functions.sh
has_battery
has_lid
get_audio_system

# 4. Test inxi manually
inxi -Fazy

# 5. Check system logs
journalctl -n 50
```

### Package Issues

**Symptoms:**
- Packages not updating
- Package conflicts
- Dependency errors

**Solutions:**

```bash
# 1. Update package database
sudo pacman -Syu

# 2. Refresh package database
sudo pacman -Fy

# 3. Check for conflicts
sudo pacman -Dk

# 4. Fix broken packages
sudo pacman -Qkk $(pacman -Qkkq)

# 5. Remove orphaned packages
sudo pacman -Rns $(pacman -Qtdq)

# 6. Clean package cache
sudo pacman -Sc
```

### Service Issues

**Symptoms:**
- Service won't start
- Service fails repeatedly
- Service logs showing errors

**Solutions:**

```bash
# 1. Check service status
systemctl status <service>

# 2. Check service logs
journalctl -u <service> -n 100

# 3. Restart service
sudo systemctl restart <service>

# 4. Enable service
sudo systemctl enable <service>

# 5. Check dependencies
systemctl list-dependencies <service>

# 6. Check failed services
systemctl --failed
```

### Disk Space Issues

**Symptoms:**
- Disk full despite cleanup
- Large directories not shrinking
- Space being consumed

**Solutions:**

```bash
# 1. Check disk usage
df -h

# 2. Find large directories
du -sh ~/.cache/ | sort -rh | head -20

# 3. Find large log files
du -sh ~/.s1b_logs/ | sort -rh | head -10

# 4. Clean package cache
sudo pacman -Sc

# 5. Remove orphaned packages
sudo pacman -Rns $(pacman -Qtdq)

# 6. Run cleanup script
~/Desktop/S1Bs1stem/scripts/system/cleanup.sh --full

# 7. Manual cleanup
sudo rm -rf /var/cache/pacman/pkg/*
```

---

## Performance Issues

### System Slow

**Symptoms:**
- System lagging
- High CPU usage
- Slow application startup

**Solutions:**

```bash
# 1. Check system resources
htop

# 2. Check CPU usage
top

# 3. Check memory usage
free -h

# 4. Check running processes
ps aux | head -20

# 5. Check for background processes
systemctl --user list-units --state=running

# 6. Check system load
uptime

# 7. Check I/O usage
iotop

# 8. Kill unnecessary processes
killall <process>
```

### High Memory Usage

**Symptoms:**
- Memory running low
- Swap usage high
- Applications crashing

**Solutions:**

```bash
# 1. Check memory usage
free -h

# 2. Check swap usage
swapon --show

# 3. Find memory-hungry processes
ps aux --sort=-%mem | head -10

# 4. Clear cache
sudo sync; echo 3 | sudo tee /proc/sys/vm/drop_caches

# 5. Check for memory leaks
valgrind <application>

# 6. Restart memory-hungry applications
killall <application>
```

### High CPU Usage

**Symptoms:**
- CPU usage at 100%
- System overheating
- Fan running constantly

**Solutions:**

```bash
# 1. Check CPU usage
top

# 2. Check CPU temperature
sensors

# 3. Find CPU-hungry processes
ps aux --sort=-%cpu | head -10

# 4. Check for runaway processes
ps aux | grep -v grep | awk '{if($3>80) print}'

# 5. Kill high-CPU processes
killall <process>

# 6. Check for CPU governor
cpupower frequency-info

# 7. Set CPU governor to powersave
sudo cpupower frequency-set -g powersave
```

---

## Getting Help

### Check Logs

When troubleshooting, always check logs:

```bash
# System logs
journalctl -n 100
journalctl -p err -n 50

# X session logs
tail -f ~/.xsession-errors

# S1Bs1stem logs
tail -f ~/.s1b_logs/s1b_system.log

# Service logs
journalctl -u NetworkManager -n 50
journalctl -u upower -n 50
```

### Test Scripts

Test scripts with verbose output:

```bash
# Test with debug output
bash -x ~/Desktop/S1Bs1stem/scripts/<category>/<script>.sh 2>&1 | head -50

# Check syntax
bash -n ~/Desktop/S1Bs1stem/scripts/<category>/<script>.sh

# Check dependencies
bash ~/Desktop/S1Bs1stem/install/preflight/001_dependencies_check.sh
```

### Reset Installation

If all else fails, reset the installation:

```bash
# 1. Backup your data
cp -r ~/.config ~/.config.backup
cp -r ~/.local ~/.local.backup

# 2. Remove S1Bs1stem
rm -rf ~/Desktop/S1Bs1stem

# 3. Clone again
cd ~/Desktop
git clone git@github.com:ind4skylivey/s1barch.git S1Bs1stem
cd S1Bs1stem

# 4. Run installation
bash install/ORCHESTRA.sh --interactive

# 5. Restore config (if needed)
cp -r ~/.config.backup/* ~/.config/
```

### Ask for Help

If you can't resolve the issue:

1. **Check the Wiki**: Review all documentation files
2. **Check GitHub Issues**: Search existing issues
3. **Create a New Issue**: Include:
   - OS version: `uname -a`
   - DWM version: `dwm -v`
   - Error messages: Copy exact error text
   - Steps to reproduce: What did you do?
   - Expected behavior: What should happen?
   - Actual behavior: What happened?
   - Logs: Relevant log output

---

## Quick Reference

| Issue | Diagnostic Command | Fix Command |
|:---|:---:|:---:|
| **Installation fails** | `bash -n install/ORCHESTRA.sh` | `chmod +x install/ORCHESTRA.sh` |
| **DWM won't start** | `tail -f ~/.xsession-errors` | `cd ~/.local/src/dwm && sudo make install` |
| **Keybindings not working** | `xev` | Recompile DWM |
| **No audio** | `pactl list sinks short` | `pactl set-sink-mute @DEFAULT_SINK@ 0` |
| **No network** | `systemctl status NetworkManager` | `systemctl restart NetworkManager` |
| **DNS not resolving** | `nmcli dev show \| grep DNS` | `systemctl restart systemd-resolved` |
| **Battery not detected** | `upower -e` | `sudo pacman -S upower` |
| **High CPU** | `top` | `killall <process>` |
| **High memory** | `free -h` | `echo 3 \| sudo tee /proc/sys/vm/drop_caches` |
| **Disk full** | `df -h` | `~/Desktop/S1Bs1stem/scripts/system/cleanup.sh --full` |

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
- [API Reference](12_API_REFERENCE.md)
