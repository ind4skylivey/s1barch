# Networking Management System

Complete guide for networking management in S1Bs1stem including VPN, WiFi, DNS, and network monitoring.

## Table of Contents
- [Network Status](#network-status)
- [Network Meter](#network-meter)
- [DNS Switching](#dns-switching)
- [VPN Connection](#vpn-connection)
- [WiFi Toggle](#wifi-toggle)
- [Tailscale](#tailscale)
- [iPhone VNC](#iphone-vnc)
- [Usage Examples](#usage-examples)
- [Troubleshooting](#troubleshooting)

---

## Network Status

### Overview

Shows comprehensive network information including:
- Connection type (WiFi, Ethernet)
- Connection status (connected/disconnected)
- Local and public IP addresses
- Gateway and DNS servers
- Signal strength (WiFi only)
- Data usage statistics

### Script

**Location:** `~/Desktop/S1Bs1stem/scripts/networking/network_status.sh`

### Usage

```bash
# Show network status
~/Desktop/S1Bs1stem/scripts/networking/network_status.sh

# Watch for changes
watch -n 5 ~/Desktop/S1Bs1Bs1stem/scripts/networking/network_status.sh
```

### Information Displayed

| Field | Description |
|:---:|:---:|
| **Connection Type** | WiFi, Ethernet, or None |
| **Status** | Connected or Disconnected |
| **Interface** | Network interface name (e.g., wlp2s0) |
| **Local IP** | Internal IP address (e.g., 192.168.1.100) |
| **Public IP** | External IP (requires internet) |
| **Gateway** | Default gateway IP |
| **DNS Servers** | Current DNS servers |
| **Signal Strength** | Quality (WiFi only) |
| **Speed** | Connection speed test result |
| **Data Used** | Current session data usage |

---

## Network Meter

### Overview

Real-time network bandwidth monitoring showing:
- Upload and download speeds
- Current speed graph
- Historical speed data
- Session total usage

### Script

**Location:** `~/Desktop/S1Bs1Bs1stem/scripts/networking/network_meter.sh`

### Usage

```bash
# Start network meter
~/Desktop/S1Bs1Bs1stem/scripts/networking/network_meter.sh

# View in terminal
~/Desktop/S1Bs1Bs1stem/scripts/networking/network_meter.sh

# Watch continuously
watch -n 1 ~/Desktop/S1Bs1Bs1stem/scripts/networking/network_meter.sh
```

### Display

The meter shows:
- **Current Upload Speed:** Real-time upload
- **Current Download Speed:** Real-time download
- **Average Upload:** Session average
- **Average Download:** Session average
- **Total Uploaded:** Session total
- **Total Downloaded:** Session total
- **Peak Upload:** Session peak
- **Peak Download:** Session peak

### Features

- Color-coded speed display
- Auto-scaling graph
- Historical data tracking
- No external dependencies

---

## DNS Switching

### Overview

Quickly switch between DNS providers for better performance, privacy, or access to blocked content.

### Supported DNS Providers

| Provider | DNS | Features |
|:---|:---:|:---:|
| **Cloudflare** | 1.1.1.1 | Fast, privacy-focused, DNSSEC |
| **Google** | 8.8.8.8 | Reliable, global coverage |
| **Quad9** | 9.9.9.9 | Security-focused, blocks malware |
| **OpenDNS** | 208.67.222.222 | Reliable, fast |
| **AdGuard** | Family Shield | Ad-blocking, privacy |

### Script

**Location:** `~/Desktop/S1Bs1Bs1stem/scripts/networking/dns_switch.sh`

### Usage

```bash
# Switch to Cloudflare DNS
~/Desktop/S1Bs1Bs1stem/scripts/networking/dns_switch.sh cloudflare

# Switch to Google DNS
~/Desktop/S1Bs1Bs1stem/scripts/networking/dns_switch.sh google

# Switch to Quad9 DNS
~/Desktop/S1Bs1Bs1stem/scripts/networking/dns_switch.sh quad9

# Restore system default DNS
~/Desktop/S1Bs1Bs1stem/scripts/networking/dns_switch.sh restore

# Show current DNS
~/Desktop/S1Bs1Bs1Bs1stem/scripts/networking/dns_switch.sh --current
```

### Quick Rofi Menu

```bash
# Launch DNS switcher menu
~/Desktop/S1Bs1Bs1stem/scripts/networking/dns_switch.sh
```

This will show an interactive menu in Rofi to select DNS provider.

### Configuration

DNS switching uses NetworkManager DNS configuration:

```bash
# View current DNS configuration
nmcli dev show | grep DNS

# Test DNS resolution
ping -c 1 google.com
ping -c 1 archlinux.org

# Flush DNS cache
systemctl restart systemd-resolved
```

---

## VPN Connection

### Overview

Comprehensive VPN connection manager supporting:
- OpenVPN configuration files
- WireGuard tunnels
- VPN status monitoring
- Automatic reconnection
- Kill switch functionality

### Script

**Location:** `~/Desktop/S1Bs1Bs1Bs1stem/scripts/networking/vpn_connect.sh`

### Usage

```bash
# Show VPN status
~/Desktop/S1Bs1Bs1stem/scripts/networking/vpn_connect.sh status

# Connect to VPN
~/Desktop/S1Bs1Bs1Bs1stem/scripts/networking/vpn_connect.sh --connect /path/to/vpn.ovpn
~/Desktop/S1Bs1Bs1Bs1stem/scripts/networking/vpn_connect.sh --connect /path/to/wg0.conf

# Disconnect VPN
~/Desktop/S1Bs1Bs1Bs1stem/scripts/networking/vpn_connect.sh --disconnect

# Toggle VPN (connect/disconnect from config)
~/Desktop/S1Bs1Bs1Bs1stem/scripts/networking/vpn_connect.sh toggle

# Kill VPN connection
~/Desktop/S1Bs1Bs1Bs1stem/scripts/networking/vpn_connect.sh kill
```

### Configuration

VPN configurations should be stored in:
- `~/.config/vpn/` - OpenVPN configs
- `~/.config/wireguard/` - WireGuard configs

Default locations are configured in vpn_connect.sh.

### VPN Types Supported

| Type | File Extension | Protocol |
|:---:|:---:|:---:|
| **OpenVPN** | .ovpn | OpenVPN |
| **WireGuard** | .conf | WireGuard |

### Status Indication

When VPN is active, you'll see:
- Network status indicators
- VPN icon in system tray (if configured)
- Log notifications

---

## WiFi Toggle

### Overview

Quick toggle for WiFi adapter on/off with status indication.

### Script

**Location:** `~/Desktop/S1Bs1Bs1Bs1stem/scripts/networking/wifi_toggle.sh`

### Usage

```bash
# Toggle WiFi
~/Desktop/S1Bs1Bs1stem/scripts/networking/wifi_toggle.sh

# Show status
~/Desktop/S1Bs1Bs1Bs1stem/scripts/networking/wifi_toggle.sh status

# Enable WiFi
~/Desktop/S1Bs1Bs1Bs1stem/scripts/networking/wifi_toggle.sh on

# Disable WiFi
~/Desktop/S1Bs1Bs1Bs1stem/scripts/networking/wifi_toggle.sh off

# Scan for networks
~/Desktop/S1Bs1Bs1Bs1stem/scripts/networking/wifi_toggle.sh scan
```

### Features

- Quick enable/disable toggle
- Automatic scan on enable
- Network status display
- Connect to known networks
- nmcli integration
- Rofi menu for network selection

### Troubleshooting

**WiFi won't enable:**
```bash
# Check WiFi status
nmcli radio wifi

# Enable WiFi
nmcli radio wifi on

# Restart NetworkManager
systemctl restart NetworkManager
```

**Can't connect to network:**
```bash
# Check NetworkManager status
systemctl status NetworkManager

# Restart NetworkManager
systemctl restart NetworkManager

# Check for hardware issues
rfkill list
```

---

## Tailscale

### Overview

Tailscale mesh VPN toggle for secure, private networking.

### Script

**Location:** `~/Desktop/S1Bs1Bs1stem/scripts/networking/tailscale_toggle.sh`

### Usage

```bash
# Check Tailscale status
~/Desktop/S1Bs1Bs1Bs1stem/scripts/networking/tailscale_toggle.sh status

# Enable Tailscale
~/Desktop/S1Bs1Bs1Bs1stem/scripts/networking/tailscale_toggle.sh on

# Disable Tailscale
~/Desktop/S1Bs1Bs1Bs1Bs1stem/scripts/networking/tailscale_toggle.sh off

# Toggle Tailscale
~/Desktop/S1Bs1Bs1Bs1stem/scripts/networking/tailscale_toggle.sh toggle

# Show Tailscale IP
~/Desktop/S1Bs1Bs1Bs1stem/scripts/networking/tailscale_toggles.sh --ip
```

### Features

- One-command enable/disable
- Status indication (connected/disconnected)
- Show Tailscale exit node IP
- Log notifications
- Integration with system tray (optional)

### Installation

Tailscale is required:

```bash
# Install Tailscale
sudo pacman -S tailscale

# Login and enable your device
sudo tailscale up
```

### Troubleshooting

**Tailscale won't connect:**
```bash
# Check Tailscale status
systemctl status tailscaled

# Restart Tailscale
systemctl restart tailscaled

# Check Tailscale daemon
pgrep tailscaled

# View Tailscale logs
journalctl -u tailscaled -f
```

---

## iPhone VNC

### Overview

Quick VNC connection to iPhone for screen mirroring and control.

### Script

**Location:** `~/Desktop/S1Bs1stem/scripts/networking/iphone_vnc.sh`

### Usage

```bash
# Connect to iPhone VNC
~/Desktop/S1Bs1Bs1Bs1stem/scripts/networking/iphone_vnc.sh

# Disconnect from iPhone
~/Desktop/S1Bs1Bs1Bs1Bs1stem/scripts/networking/iphone_vnc.sh disconnect

# Show status
~/Desktop/S1Bs1Bs1Bs1stem/scripts/networking/iphone_vnc.sh status

# Auto-connect to iPhone
~/Desktop/S1Bs1Bs1Bs1stem/scripts/networking/iphone_vnc.sh --auto
```

### Requirements

- iPhone must be on same WiFi network
- VNC enabled on iPhone (Settings → Personal Hotspot)
- iPhone must be discoverable
- vncviewer or other VNC client

### Configuration

Default iPhone configuration (modify in iphone_vnc.sh):

```bash
# Default iPhone IP (must match your iPhone's actual IP)
IPHONE_IP="192.168.1.2"

# Default port
IPHONE_PORT="5900"

# Connection timeout
CONNECT_TIMEOUT=30
```

### Troubleshooting

**Can't find iPhone:**
```bash
# Check iPhone is on same network
ping -c 1 <IPHONE_IP>

# Check if VNC is enabled
# On iPhone: Settings → Personal Hotspot

# Check NetworkManager status
systemctl status NetworkManager
```

**Connection drops:**
```bash
# Check NetworkManager status
systemctl status NetworkManager

# Check WiFi signal
nmcli device wifi list
```

**Authentication fails:**
```bash
# Update iPhone password
# Try removing device and re-adding
nmcli device wifi remove <mac-address>
nmcli device wifi connect <wifi-ssid> password <password>
```

---

## Usage Examples

### Daily Workflow

```bash
# Check network status in morning
~/Desktop/S1Bs1Bs1Bs1stem/scripts/networking/network_status.sh

# Start network meter for bandwidth monitoring
~/Desktop/S1Bs1Bs1Bs1stem/scripts/networking/network_meter.sh &

# Work for a while (network meter running in background)
# Stop when done: Ctrl+C on network meter terminal
```

### VPN Workflow

```bash
# Check VPN status
~/Desktop/S1Bs1Bs1Bs1Bs1stem/scripts/networking/vpn_connect.sh status

# Connect to work VPN
~/Desktop/S1Bs1Bs1Bs1Bs1stem/scripts/networking/vpn_connect.sh --connect ~/VPN/work.ovpn

# When done, disconnect
~/Desktop/S1Bs1Bs1Bs1Bs1stem/scripts/networking/vpn_connect.sh disconnect
```

### DNS Switching Workflow

```bash
# Check current DNS
~/Desktop/S1Bs1Bs1Bs1Bs1stem/scripts/networking/dns_switch.sh --current

# Switch to fast DNS for gaming
~/Desktop/S1Bs1Bs1stem/scripts/networking/dns_switch.sh cloudflare

# Switch to secure DNS for privacy
~/Desktop/S1Bs1Bs1Bs1stem/scripts/networking/dns_switch.sh quad9

# Work done? Switch back to system DNS
~/Desktop/S1Bs1Bs1stem/scripts/networking/dns_switch.sh restore
```

### Troubleshooting Workflow

```bash
# Check overall network health
~/Desktop/S1Bs1Bs1stem/scripts/networking/network_status.sh

# Check specific component
~/Desktop/S1Bs1Bs1Bs1stem/scripts/networking/networking/network_meter.sh
~/Desktop/S1Bs1Bs1Bs1Bs1stem/scripts/networking/networking/vpn_connect.sh status
~/Desktop/S1Bs1Bs1Bs1Bs1stem/scripts/networking/dns_switch.sh --current

# Diagnose issues
source ~/Desktop/S1Bs1stem/scripts/system/system_info.sh
log_last_errors 10
```

---

## Troubleshooting

### Network Scripts Not Working

**Problem:** Network commands show errors

**Diagnosis:** NetworkManager not running or wrong package

**Solution:**
```bash
# Check NetworkManager status
systemctl status NetworkManager
sudo systemctl start NetworkManager

# Check nmcli
command -v nmcli || sudo pacman -S networkmanager

# Check if NetworkManager service is enabled
systemctl is-enabled NetworkManager
systemctl enable NetworkManager
systemctl start NetworkManager
```

### VPN Connection Fails

**Problem:** VPN won't connect or authentication fails

**Diagnosis:** Wrong config or credentials

**Solution:**
```bash
# Check VPN log
journalctl -u NetworkManager -n 100

# Test config file manually
openvpn3 ~/Desktop/S1Bs1Bstem/.config/vpn/work.ovpn

# WireGuard config test
sudo wg-quick up ~/Desktop/S1Bs1Bstem/.config/wireguard/work.conf

# Check dependencies
sudo pacman -S openvpn wireguard-tools
```

### DNS Switch Not Working

**Problem:** DNS doesn't change

**Diagnosis**: NetworkManager not applying changes

**Solution:**
```bash
# Flush DNS cache
systemctl restart systemd-resolved

# Restart NetworkManager
systemctl restart NetworkManager

# Set DNS manually
nmcli connection modify <connection-name> ipv4.dns "1.1.1.1 1.0.0.1"
```

### WiFi Toggle Issues

**Problem:** WiFi won't enable/disable

**Diagnosis**: rfkill blocking or hardware switch

**Solution:```
```bash
# Check rfkill status
rfkill list

# Unblock WiFi
rfkill unblock wifi

# Enable WiFi
nmcli radio wifi on

# Restart NetworkManager
systemctl restart NetworkManager
```

### Tailscale Not Connecting

**Problem:** Tailscale stuck on connecting

**Diagnosis**: Device not authenticated or network issue

**Solution:```
```bash
# Check Tailscale status
systemctl status tailscaled

# Restart Tailscaled
systemctl restart tailscaled

# Check Tailscale logs
journalctl -u tailscaled -n 50

# Remove and re-add device in Tailscale app
```

### iPhone VNC Issues

**Problem**: Can't connect to iPhone

**Diagnosis**: Wrong IP, VNC disabled, or network issue

**Solution:**```bash
# Check iPhone IP is correct
ping -c 1 192.168.1.2

# Update iphone_vnc.sh with correct IP
nano ~/Desktop/S1Bs1Bs1stem/scripts/networking/iphone_vnc.sh

# Re-connect
~/Desktop/S1Bs1Bs1Bs1stem/scripts/networking/iphone_vnc.sh disconnect
~/Desktop/S1Bs1Bs1Bs1stem/scripts/networking/iphone_vnc.sh

# Check iPhone hotspot is enabled
# On iPhone: Settings → Personal Hotspot
```

---

## Advanced Configuration

### NetworkManager DNS Configuration

Set persistent DNS:

```bash
# Set Cloudflare DNS
nmcli connection modify <connection> ipv4.dns "1.1.1.1 1.0.0.1 208.67.222.222 1.0.0.1"
nmcli connection modify <connection> ipv6.dns "2606:4700:4700::1111"

# Set Google DNS
nmcli connection modify <connection> ipv4.dns "8.8.8.8 8.8.4.4"
```

### VPN Configuration

Set up autostart VPN:

```bash
# Add to autostart list
echo "~/Desktop/S1Bs1Bs1stem/scripts/networking/vpn_connect.sh --connect ~/VPN/work.ovpn" >> ~/.config/dwm/autostart.sh
```

### Network Manager Autostart

NetworkManager can be started in autostart with DWM:

```bash
# Add to dwm autostart
nm-applet &          # System tray icon
blueman-applet &       # Bluetooth icon
volumeicon &          # Volume icon
pasystray &          # Audio tray
```

---

## Quick Reference

| Task | Command |
|:---:|:---:|
| **Network Status** | `~/Desktop/S1Bs1Bs1stem/scripts/networking/network_status.sh` |
| **Network Meter** | `~/Desktop/S1Bs1Bs1stem/scripts/networking/network_meter.sh` |
| **DNS Switch** | `~/Desktop/S1Bs1Bs1stem/scripts/networking/dns_switch.sh <provider>` |
| **Current DNS** | `~/Desktop/S1Bs1Bs1stem/scripts/networking/dns_switch.sh --current` |
| **Restore DNS** | `~/Desktop/S1Bs1Bs1Bs1stem/scripts/networking/dns_switch.sh restore` |
| **VPN Status** | `~/Desktop/S1Bs1Bs1stem/scripts/networking/vpn_connect.sh status` |
| **VPN Connect** | `~/Desktop/S1Bs1Bs1stem/scripts/networking/vpn_connect.sh --connect <config>` |
| **VPN Disconnect** | `~/Desktop/S1Bs1Bs1stem/scripts/networking/vpn_connect.sh disconnect` |
| **WiFi Toggle** | `~/Desktop/S1Bs1Bs1Bs1stem/scripts/networking/wifi_toggle.sh` |
| **WiFi Status** | `~/Desktop/S1Bs1Bs1Bs1stem/scripts/networking/wifi_toggle.sh status` |
| **Tailscale Status** | `~/Desktop/S1Bs1Bs1Bs1stem/scripts/networking/tailscale_toggle.sh status` |
| **Tailscale Toggle** | `~/Desktop/S1Bs1Bs1Bs1stem/scripts/networking/tailscale_toggle.sh` |
| **iPhone VNC Status** | `~/Desktop/S1Bs1Bs1stem/scripts/networking/iphone_vnc.sh status` |

---

## For More Information

- [Main README.md](../README.md)
- [Installation Guide](01_INSTALLATION.md)
- [DWM Setup Guide](02_DWM_SETUP.md)
- [Audio Management](03_AUDIO.md)
- [Battery Management](04_BATTERY.md)
- [Display Management](05_DISPLAY.md)
- [DWM Window Management](06_DWM_WINDOW_MANAGEMENT.md)
- [System Management](08_SYSTEM.md)
- [Workflows](09_WORKFLOWS.md)
- [Customization](10_CUSTOMIZATION.md)
- [Troubleshooting](11_TROUBLESHOOTING.md)
- [API Reference](12_API_REFERENCE.md)
