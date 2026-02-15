# System Management System

Complete guide for system maintenance, monitoring, and package management in S1Bs1stem.

## Table of Contents
- [System Information](#system-information)
- [Package Management](#package-management)
- [Service Status](#service-status)
- [Disk Usage](#disk-usage)
- [Maintenance Tasks](#maintenance-tasks)
- [Log Management](#log-management)
- [Usage Examples](#usage-examples)
- [Troubleshooting](#troubleshooting)

---

## System Information

### Overview

Comprehensive system information display including:
- Operating system details
- Kernel version
- Hardware information
- CPU, RAM, and disk statistics
- System uptime
- Installed packages count

### Script

**Location:** `~/Desktop/S1Bs1stem/scripts/system/system_info.sh`

### Usage

```bash
# Show full system info
~/Desktop/S1Bs1Bs1Bs1stem/scripts/system/system_info.sh

# Show specific info
~/Desktop/S1Bs1Bs1Bs1stem/scripts/system/system_info.sh --cpu
~/Desktop/S1Bs1Bs1stem/scripts/system/system_info.sh --memory
~/Desktop/S1Bs1Bs1Bstem/scripts/system/system_info.sh --disk
~/Desktop/S1Bs1Bstem/scripts/system/system/system_info.sh --uptime
```

### Information Displayed

| Category | Details |
|:---:---:|:---:|
| **OS** | Arch Linux version |
| **Kernel** | Kernel version and architecture |
| **Desktop Environment** | Current session (DWM/Wayland) |
| **Shell** | Default shell (ZSH/Fish) |
| **CPU** | CPU model, cores, threads |
| **GPU** | Graphics card and driver |
| **RAM** | Total and available memory |
| **Disk** | Total, used, and free space |
| **Uptime** | System uptime and load average |
| **Packages** | Total installed and upgradable |
| **Hardware Detection** | Battery status, lid status (desktop/laptop) |

---

## Package Management

### Overview

Package management information including:
- Total installed packages
- Package updates available
- Orphaned packages
- Package search
- Dependency graph

### Script

**Location:** `~/Desktop/S1Bs1Bstem/scripts/system/package_info.sh`

### Usage

```bash
# Show package info
~/Desktop/S1Bs1stem/scripts/system/package_info.sh

# List upgradable packages
~/Desktop/S1Bs1Bstem/scripts/system/package_info.sh --upgradable

# List orphaned packages
~/Desktop/S1Bs1Bs1Bstem/scripts/system/package_info.sh --orphans

# Search for package
~/Desktop/S1Bs1Bstem/scripts/system/package_info.sh --search <keyword>

# Get package details
~/Desktop/S1Bs1Bstem/scripts/system/package_info.sh --info <package_name>
```

### Information Displayed

| Category | Details |
|:---|---:|:---:|
| **Total Packages** | Total installed packages count |
| **Upgradable** | Packages with updates available |
| **Orphans** | Installed as dependencies but no longer needed |
| **Foreign** | Packages from non-Arch repos |

---

## Service Status

### Overview

Systemd service status monitoring including:
- Active services
- Failed services
- Service logs
- Service enable/disable

### Script

**Location:** `~/Desktop/S1Bs1stem/scripts/system/service_status.sh`

### Usage

```bash
# Show all service status
~/Desktop/S1Bs1Bs1Bs1stem/scripts/system/service_status.sh

# Show specific service
~/Desktop/S1Bs1Bs1Bstem/scripts/system/service_status.sh --service NetworkManager

# Show failed services
~/Desktop/S1Bs1Bs1Bstem/scripts/system/service_status.sh --failed

# Show enabled services
~/Desktop/S1Bs1Bs1stem/scripts/system/service_status.sh --enabled

# Show disabled services
~/Desktop/S1Bs1Bs1Bstem/scripts/system/service_status.sh --disabled
```

### Service Information Displayed

| Service | State | Description |
|:---:|:---||:---:|
| **NetworkManager** | Active/Inactive/Failed | Network connection manager |
| **Bluetooth** | Active/Inactive/Failed | Bluetooth daemon |
| **CUPS** | Active/Inactive/Failed | Printing service |
| **avahi-daemon** | Active/Inactive/Failed | Zeroconf/Bonjour |
| **systemd-logind** | Active | System logging service |
| **upower** | Active/Inactive | Battery/power management |
| **tailscaled** | Active/Inactive | Tailscale VPN daemon |
| **pipewire** | Active/Inactive | PipeWire audio daemon |

### Troubleshooting Services

```bash
# Check specific service logs
journalctl -u NetworkManager -n 50
journalctl -u upower -n 50
journalctl -u tailscaled -n 50

# Restart failed service
systemctl restart <service>

# Enable auto-start on boot
systemctl enable <service>

# Disable auto-start on boot
systemctl disable <service>
```

---

## Disk Usage

### Overview

Disk usage monitoring with color-coded alerts showing:
- Total, used, and available space
- Per-directory breakdown
- Threshold alerts at 80% and 90% usage
- Clean recommendation for space

### Script

**Location:** `~/Desktop/S1Bs1Bs1stem/scripts/system/disk_usage.sh`

### Usage

```bash
# Show disk usage with alerts
~/Desktop/S1Bs1Bs1Bstem/scripts/system/disk_usage.sh

# Show disk usage by directory
~/Desktop/S1Bs1Bs1Bstem/scripts/system/disk_usage.sh --dir ~/Pictures

# Show disk usage with sorting
~/Desktop/S1Bs1Bs1Bstem/scripts/system/disk_usage.sh --sort size

# Clean old files (>30 days)
~/Desktop/S1Bs1Bstem/scripts/system/disk_usage.sh --clean 30
```

### Information Displayed

| Mount Point | Total | Used | Available | Percentage | Status |
|:---|:---:|:---:|:---:|
| **/** | Size | Used | Available | % | Green/Yellow/Red |
| **/home** | Size | Used | Available | % | Green/Yellow/Red |
| **/var/log** | Size | Used | Available | % | Green/Yellow/Red |
| **/tmp** | Size | Used | Available | % | Green/Yellow/Red |

### Color Coding

- **< 60%**: GREEN (plenty of space)
- **60-80%**: YELLOW (warning, consider cleanup)
- **80-90%**: ORANGE (urgent cleanup needed)
- **> 90%**: RED (critical, clean immediately)

---

## Maintenance Tasks

### Overview

System maintenance automation including:
- Package cache cleaning
- Orphan package removal
- Temporary file cleanup
- Journal log rotation
- System update check
- Database vacuuming

### Script

**Location:** `~/Desktop/S1Bs1Bs1Bs1stem/scripts/system/maintenance.sh`

### Usage

```bash
# Run full maintenance
~/Desktop/S1Bs1Bs1Bs1stem/scripts/system/maintenance.sh

# Package cache clean
sudo pacman -Sc

# Remove orphan packages
sudo pacman -Rns $(pacman -Qtdq)

# Update system
sudo pacman -Syu

# Database vacuum
sudo pacman -Fy

# Full maintenance (all tasks)
~/Desktop/S1Bs1Bs1Bstem/scripts/system/maintenance.sh --full
```

### Maintenance Tasks

| Task | Frequency | Description |
|:---:|:---||:---:|
| **Package Cache Clean** | Weekly | Remove cached package files |
| **Orphan Removal** | Weekly | Remove unused dependencies |
| **Orphan Dbase Vacuum** | Monthly | Optimize package database |
| **Temp File Clean** | Daily | Remove temporary files |
| **Log Rotation** | Weekly | Rotate and archive logs |
| **System Update** | Weekly | Check and install updates |
| **Database Sync** | Weekly | Sync local databases |

---

## Log Management

### Overview

Log management including:
- System log viewing
- Error log aggregation
- Log rotation
- Log cleaning based on retention
- Log statistics

### Script

**Location:** `~/Desktop/S1Bs1Bs1stem/scripts/system/log_clean.sh`

### Usage

```bash
# Show last 20 lines
source ~/Desktop/S1Bs1Bs1Bstem/scripts/common/logger.sh
log_recent 20

# Show last 10 errors
source ~/Desktop/S1Bs1Bstem/scripts/common/logger.sh
log_last_errors 10

# Show last 10 warnings
source ~/Desktop/S1Bs1Bstem/scripts/common/logger.sh
log_last_warns 10

# Show log statistics
source ~/Desktop/S1Bs1Bstem/scripts/common/logger.sh
log_stats

# Follow logs in real-time
source ~/Desktop/S1Bs1Bstem/scripts/common/logger.sh
log_tail

# Clean old logs (30 days)
~/Desktop/S1Bs1Bs1Bstem/scripts/system/log_clean.sh --days 30

# Show large log files (>10MB)
source ~/Desktop/S1Bs1Bstem/scripts/system/log_clean.sh --large
```

### Log Locations

| Log File | Location | Purpose | Rotation |
|:---:|:---||:---:|
| **System Log** | `~/.s1b_logs/s1b_system.log` | All script logs |
| **Install Log** | `~/.s1b_install_*.log` | Installation logs |
| **XSession Errors** | `~/.xsession-errors` | X11 session errors |
| **Journal Logs** | `journalctl -u user` | Systemd logs |

### Troubleshooting

**Logs not being written:**

```bash
# Check log directory permissions
ls -la ~/.s1b_logs/

# Check if logger is sourced
source ~/Desktop/S1Bs1Bstem/scripts/common/logger.sh

# Test logger
log_info "Testing logger"

# Check write permissions
touch ~/.s1b_logs/test.log
echo "test" >> ~/.s1b_logs/s1b_system.log
```

**Log rotation not working:**

```bash
# Check log size
stat -f%s ~/.s1b_logs/s1b_system.log

# Trigger rotation manually
source ~/Desktop/S1Bs1Bstem/scripts/common/logger.sh
log_rotate

# Force log rotation
rm -f ~/.s1b_logs/s1b_system.log.old
```

---

## Cleanup

### Overview

General cleanup for:
- Temporary files
- Cache directories
- Browser caches
- Thumbnail cache
- Crash reports
- Application caches

### Script

**Location:** `~/Desktop/S1Bs1Bs1stem/scripts/system/cleanup.sh`

### Usage

```bash
# Run full cleanup
~/Desktop/S1Bs1Bs1Bs1Bstem/scripts/system/cleanup.sh

# Clean specific cache
~/Desktop/S1Bs1Bs1Bs1stem/scripts/system/cleanup.sh --cache

# Clean thumbnails
~/Desktop/S1Bs1Bs1Bstem/scripts/system/cleanup.sh --thumbnails

# Clean browser cache
~/Desktop/S1Bs1Bs1BsBstem/scripts/system/cleanup.sh --browser

# Clean crash reports
~/Desktop/S1Bs1Bs1Bstem/scripts/system/cleanup.sh --crashes

# Show cleanup report
~/Desktop/S1Bs1Bs1Bstem/scripts/system/cleanup.sh --report
```

### Cleanup Locations

| Location | Size | Frequency |
|:---:|:---||:---:|
| **~/.cache** | Variable | Weekly |
| **~/.thumbnails** | Large | Monthly |
| **~/.config/mozilla** | Variable | Monthly |
| **~/.cache/chromium** | Variable | Monthly |
| **~/.cache/brave** | Variable | Monthly |
| **/var/cache/pacman/pkg/** | Variable | Monthly |
| **/var/tmp/** | Variable | Reboot |
| **/tmp/** | Variable | Reboot |

---

## Usage Examples

### Daily Maintenance Workflow

```bash
# Check system health
~/Desktop/S1Bs1Bstem/scripts/system/system_info.sh

# Check for updates
~/Desktop/S1Bs1Bstem/scripts/system/package_info.sh --upgradable

# Check disk space
~/Desktop/S1Bs1Bs1Bstem/scripts/system/disk_usage.sh

# Clean temporary files
~/Desktop/S1Bs1Bs1Bs1stem/scripts/system/cleanup.sh --cache

# View recent errors
source ~/Desktop/S1Bs1Bs1Bstem/scripts/common/logger.sh
log_last_errors 10
```

### Weekly Maintenance Workflow

```bash
# Full maintenance
~/Desktop/S1Bs1Bs1Bs1stem/scripts/system/maintenance.sh --full

# Package cache clean
sudo pacman -Sc

# Remove orphans
sudo pacman -Rns $(pacman -Qtdq)

# Update system
sudo pacman -Syu
```

### Monthly Maintenance Workflow

```bash
# Full cleanup
~/Desktop/S1Bs1Bs1Bs1stem/scripts/system/cleanup.sh --full

# Database vacuum
sudo pacman -Fy
```

### Troubleshooting Workflow

```bash
# System diagnostics
~/Desktop/S1Bs1Bs1Bstem/scripts/system/system_info.sh

# Check services
~/Desktop/S1Bs1Bs1stem/scripts/system/service_status.sh --failed

# View recent errors
source ~/Desktop/S1Bs1Bstem/scripts/common/logger.sh
log_last_errors 20

# Check disk usage
~/Desktop/S1Bs1Bs1Bstem/scripts/system/disk_usage.sh
```

---

## Troubleshooting

### System Info Not Working

**Problem:** System information not showing correctly

**Solution:**
```bash
# Check hardware detection
source ~/Desktop/S1Bs1Bs1stem/scripts/common/functions.sh

# Check if lspci is installed
command -v lspci || sudo pacman -S lspci

# Check if dmidecode is installed
command -v dmidecode || sudo pacman -S dmidecode

# Check if inxi is installed
command -v inxi || sudo pacman -S inxi

# Re-source system info script
bash ~/Desktop/S1Bs1Bstem/scripts/system/system_info.sh
```

### Package Issues

**Problem:** Package info shows incorrect data

**Solution:**
```bash
# Update package database
sudo pacman -Fy

# Refresh package database
sudo pacman -Syu

# Check for file conflicts
sudo pacman -Dk

# Fix broken packages
sudo pacman -Qkk $(pacman -Qkkq)
```

### Service Won't Start

**Problem:** Service fails to start

**Solution:**
```bash
# Check service status
systemctl status <service>

# Check service logs
journalctl -u <service> -n 50

# Check for dependencies
systemctl list-dependencies <service>

# Restart service
systemctl restart <service>

# Check for failed units
systemctl --failed
```

### Disk Space Issues

**Problem:** Disk full despite cleanup

**Solution:**
```bash
# Check large directories
du -sh ~/.cache/ | sort -rh | head -20

# Check system logs size
du -sh ~/.s1b_logs/ | sort -rh | head -10

# Check package cache size
du -sh /var/cache/pacman/pkg/ | sort -rh | head -10

# Manual cleanup
sudo rm -rf /var/cache/pacman/pkg/*
sudo pacman -Sc
```

### Logs Not Rotating

**Problem:** Logs growing too large

**Solution:**
```bash
# Check log size
stat -f%s ~/.s1b_logs/s1b_system.log

# Check rotation configuration
cat ~/Desktop/S1Bs1Bs1Bstem/scripts/common/logger.sh | grep LOG_MAX_SIZE

# Force rotation
source ~/Desktop/S1Bs1Bs1Bstem/scripts/common/logger.sh
log_rotate

# Manually rotate logs
mv ~/.s1b_logs/s1b_system.log ~/.s1b_logs/s1b_system.log.old
```

---

## Quick Reference

| Task | Command | Description |
|:---||---:|:---:|
| **System Info** | `~/Desktop/S1Bs1Bstem/scripts/system/system_info.sh` | Show complete system info |
| **Packages Upgradable** | `~/Desktop/S1Bs1Bstem/scripts/system/package_info.sh --upgradable` | List packages with updates |
| **Orphan Packages** | `~/Desktop/S1Bs1Bstem/scripts/system/package_info.sh --orphans` | List orphaned packages |
| **Service Status** | `~/Desktop/S1Bs1Bs1stem/scripts/system/service_status.sh` | Show all services |
| **Failed Services** | `~/Desktop/S1Bs1BsBstem/scripts/system/service_status.sh --failed` | Show failed services |
| **Disk Usage** | `~/Desktop/S1Bs1Bs1Bstem/scripts/system/disk_usage.sh` | Show disk usage with alerts |
| **Maintenance** | `~/Desktop/S1Bs1Bs1Bstem/scripts/system/maintenance.sh --full` | Run full maintenance |
| **Log Recent** | `source ~/Desktop/S1Bs1Bs1Bstem/scripts/common/logger.sh && log_recent 20` | Last 20 lines |
| **Log Errors** | `source ~/Desktop/S1Bs1Bs1Bstem/scripts/common/logger.sh && log_last_errors 10` | Last 10 errors |
| **Log Stats** | `source ~/Desktop/S1Bs1BsBstem/scripts/common/logger.sh && log_stats` | Show log statistics |
| **Log Tail** | `source ~/Desktop/S1Bs1Bs1stem/scripts/common/logger.sh && log_tail` | Follow logs in real-time |

---

## For More Information

- [Main README.md](../README.md)
- [Installation Guide](01_INSTALLATION.md)
- [DWM Setup](02_DWM_SETUP.md)
- [Audio Management](03_AUDIO.md)
- [Battery Management](04_BATTERY.md)
- [Display Management](05_DISPLAY.md)
- [DWM Window Management](06_DWM_WINDOW_MANAGEMENT.md)
- [Networking](07_NETWORKING.md)
- [Eco-Workflow](09_WORKFLOWS.md)
- [Customization](10_CUSTOMIZATION.md)
- [Troubleshooting](11_TROUBLESHOOTING.md)
- [API Reference](12_API_REFERENCE.md)
