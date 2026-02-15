# Installation Guide for S1Bs1stem

This guide covers the complete installation and setup process for S1Bs1stem automation system.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Quick Installation](#quick-installation)
- [Installation Modes](#installation-modes)
- [Environment Selection](#environment-selection)
- [Post-Installation](#post-installation)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites

### System Requirements

| Requirement | Minimum | Recommended |
|:---|:---|:---:|
| **Operating System** | Arch Linux | Arch Linux / CachyOS |
| **RAM** | 4GB | 8GB+ |
| **Storage** | 5GB free | 20GB+ SSD |
| **Shell** | ZSH or Fish | ZSH 5.8+ |
| **Network** | Internet connection | Stable connection |

### Required Commands

| Command | Purpose | Install Command |
|:---|:---|:---:|
| `bash` | Shell | `sudo pacman -S bash` |
| `git` | Version control | `sudo pacman -S git` |
| `curl` | Downloads | `sudo pacman -S curl` |
| `wget` | Downloads | `sudo pacman -S wget` |
| `tar` | Archives | `sudo pacman -S tar` |
| `gzip` | Compression | `sudo pacman -S gzip` |
| `make` | Build tool | `sudo pacman -S make` |
| `gcc` | Compiler | `sudo pacman -S gcc` |

### Optional but Recommended Tools

| Tool | Purpose | Install Command |
|:---|:---|:---:|
| `sudo` | Privilege escalation | Usually pre-installed |
| `stow` | Symlink manager | `sudo pacman -S stow` |
| `xrandr` | Display management | `sudo pacman -S xorg-xrandr` |
| `systemctl` | Service management | Usually pre-installed |
| `nvim` / `emacs` | Editors | Your preference |

---

## Quick Installation

### One-Line Installation

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/ind4skylivey/S1Bs1stem/main/install.sh)
```

This command will:
1. Clone S1Bs1stem to `~/Desktop/S1Bs1stem`
2. Make scripts executable
3. Run the orchestrator
4. Guide you through environment selection

### Manual Installation

```bash
# 1. Clone repository
git clone https://github.com/ind4skylivey/S1Bs1stem.git ~/Desktop/S1Bs1stem

# 2. Navigate to directory
cd ~/Desktop/S1Bs1stem

# 3. Run orchestrator
./install/ORCHESTRA.sh
```

---

## Installation Modes

### Normal Mode

```bash
cd ~/Desktop/S1Bs1stem
./install/ORCHESTRA.sh
```

This mode:
- Shows environment selection menu
- Runs pre-flight checks automatically
- Executes installation in sequence
- Shows progress and logs

### Interactive Mode

```bash
./install/ORCHESTRA.sh --interactive
```

This mode:
- Prompts before each script
- Gives you control over what runs
- Perfect for partial or test installations

### Dry-Run Mode

```bash
./install/ORCHESTRA.sh --dry-run
```

This mode:
- Shows what will be executed
- Does NOT make any changes
- Perfect for previewing installation

### Reset Mode

```bash
./install/ORCHESTRA.sh --reset
```

This mode:
- Clears installation state
- Removes progress tracking
- Allows fresh installation start

### Verbose Mode

```bash
./install/ORCHESTRA.sh --verbose
```

This mode:
- Shows detailed output
- Enables bash debugging (`set -x`)
- Useful for troubleshooting

---

## Environment Selection

### Step 1: Choose Your Environment

The orchestrator will show this menu:

```
🌌 S1Bs1stem Environment Selector
═══════════════════════════════════════════

Which environment(s) do you want to install?

  1) 💻 FULL INSTALLATION (Wayland + DWM/X11)
     - All configs for both environments
     - Switch between them at login
     - Recommended for dual-session setups

  2) 🌊 WAYLAND ONLY
     - Waybar + Wofi
     - GPU-accelerated compositing
     - Modern, lightweight

  3) 🪟 DWM/X11 ONLY
     - DWM + Picom + Rofi + Systray
     - Classic, stable, minimal
     - Lightweight window manager

  4) ⚙️  CUSTOM INSTALLATION
     - Choose specific modules individually
     - Fine-grained control

  q) Quit

═══════════════════════════════════════════
Select option [1-4/q]:
```

### Available Environments

| Environment | Components | Use Case | Status |
|:---|:---|:---|:---:|
| **Wayland** | Waybar + Wofi | Modern compositing, GPU acceleration, Wayland-native | ✅ Complete |
| **DWM/X11** | DWM + Picom + Rofi + Systray | Classic, stable, minimal, X11-native | ✅ Complete |

### Environment Comparison

| Feature | Wayland | DWM/X11 |
|:---|:---|:---:|
| **Compositing** | GPU-accelerated (native) | Picom (software) |
| **Input** | Wayland protocols | X11 protocols |
| **Performance** | Lower latency (native) | Higher compatibility (X11) |
| **Stability** | Modern, evolving | Classic, mature |
| **Hardware Requirements** | Recent GPU | Any GPU |
| **Ecosystem** | Waybar, Wofi | Rofi, Systray |

### Custom Installation Options

If you select option 4, you can choose individual modules:

| Module | Description | Dependencies |
|:---|:---|:---:|
| **shell** | ZSH configuration and plugins | zsh, git |
| **terminal** | Terminal emulator setup | kitty, alacritty |
| **dwm** | DWM window manager | DWM, picom, rofi |
| **picom** | Compositor (included in dwm) | picom |
| **rofi** | Application launcher | rofi, catppuccin |
| **waybar** | Status bar | waybar, jq |
| **wofi** | Launcher (wayland only) | wofi |
| **qt** | Qt theming engine | kvantum, qt5ct |
| **warp** | Warp terminal | warp (AUR) |
| **browser** | Zen browser | zen-browser (AUR) |
| **editor** | Editor configuration | nvim, emacs |
| **filemanager** | File manager | yazi, pcmanfm-qt |
| **multiplexer** | Terminal multiplexer | tmux, zellij |
| **monitor** | System monitors | btop, cava, fastfetch |
| **workflow** | Eco-Workflow system | jq |
| **display** | Display management | feh, grim, slurp |

---

## Post-Installation

### 1. Apply Shell Changes

After installation, you need to logout and login to apply shell changes.

```bash
# Logout from your current session
# Login again (your display manager or TTY)
```

### 2. Restart Your Session

```bash
# If DWM
killall dwm  # This will restart DWM

# Or logout and login to DWM session

# If Wayland
killall waybar && waybar &  # Restart Waybar

# Or logout and login to Wayland session
```

### 3. Verify Installation

```bash
# Run system info check
~/Desktop/S1Bs1stem/scripts/system/system_info.sh

# Check if DWM is running
pgrep dwm

# Check if Waybar is running
pgrep waybar

# Check hardware detection
source ~/Desktop/S1Bs1stem/scripts/common/functions.sh
has_battery && echo "Laptop detected" || echo "Desktop detected"
get_audio_system
```

### 4. Launch Your First Workflow

```bash
# Launch workflow menu
~/Desktop/S1Bs1stem/scripts/workflow/ws-menu.sh

# Or use aliases (after sourcing)
ws-local      # Local Development
ws-remote     # Remote Server
ws-write       # Deep Write
ws-redteam     # Red Team
```

---

## Troubleshooting

### Installation Fails

**Problem:** ORCHESTRA.sh fails at script execution

**Solution:**
```bash
# Check logs
cat ~/.s1b_install_*.log | tail -50

# Check system requirements
bash ~/Desktop/S1Bs1stem/install/preflight/000_system_check.sh

# Check dependencies
bash ~/Desktop/S1Bs1stem/install/preflight/001_dependencies_check.sh

# Check disk space
bash ~/Desktop/S1Bs1stem/install/preflight/002_disk_space_check.sh
```

### Pre-flight Check Fails

**Problem:** Dependency or system validation fails

**Solution:**
```bash
# Install missing dependencies manually
sudo pacman -S bash git curl wget tar gzip make gcc

# Check if running on Arch Linux
cat /etc/arch-release

# Check Bash version
bash --version  # Should be 4.0+
```

### Permission Denied Errors

**Problem:** Scripts fail with permission denied

**Solution:**
```bash
# Make all scripts executable
chmod +x ~/Desktop/S1Bs1stem/scripts/**/*.sh
chmod +x ~/Desktop/S1Bs1stem/install/**/*.sh

# Or run individual scripts
bash ~/Desktop/S1Bs1stem/install/ORCHESTRA.sh
```

### Missing Dotfiles-s1b

**Problem:** ORCHESTRA.sh says dotfiles-s1b not found

**Solution:**
```bash
# Clone dotfiles-s1b to expected location
git clone https://github.com/ind4skylivey/dotfiles-s1b.git ~/Desktop/dotfiles-s1b

# Re-run ORCHESTRA.sh
cd ~/Desktop/S1Bs1stem
./install/ORCHESTRA.sh --reset
```

### Installation Stuck

**Problem:** Installation hangs or stops

**Solution:**
```bash
# Check what's running
ps aux | grep -i orchestra

# Kill any stuck processes
pkill -9 orchestra

# Reset and retry
cd ~/Desktop/S1Bs1stem
./install/ORCHESTRA.sh --reset
```

---

## Getting Help

### Check Logs

```bash
# View installation logs
cat ~/.s1b_install_*.log

# View system logs
cat ~/.s1b_logs/s1b_system.log

# View last errors
source ~/Desktop/S1Bs1stem/scripts/common/logger.sh
log_last_errors 20
```

### Run Diagnostics

```bash
# System information
~/Desktop/S1Bs1stem/scripts/system/system_info.sh

# Hardware detection
source ~/Desktop/S1Bs1stem/scripts/common/functions.sh
has_battery && echo "Battery: YES" || echo "Battery: NO (Desktop PC)"
has_lid && echo "Lid: YES" || echo "Lid: NO (Desktop PC)"
get_audio_system
get_audio_command
```

### Report Issues

If you encounter issues not covered here:

1. Check the main [README.md](../README.md)
2. Check the [TROUBLESHOOTING.md](11_TROUBLESHOOTING.md) guide
3. [Open an issue on GitHub](https://github.com/ind4skylivey/s1barch/issues)

When reporting, include:
- System information output
- Error messages
- Steps to reproduce
- Your environment (Desktop/Laptop, Wayland/DWM)

---

## Next Steps

After successful installation:

1. ✅ **Logout and login** to apply shell changes
2. ✅ **Restart your session** (DWM or Wayland)
3. ✅ **Launch first workflow** with `ws-menu`
4. ✅ **Explore automation scripts** in `~/Desktop/S1Bs1stem/scripts/`
5. ✅ **Customize** your environment to your liking

---

## Quick Reference

| Task | Command |
|:---|:---:|
| **Install S1Bs1stem** | `git clone https://github.com/ind4skylivey/S1Bs1stem.git ~/Desktop/S1Bs1stem && cd ~/Desktop/S1Bs1stem && ./install/ORCHESTRA.sh` |
| **System Info** | `~/Desktop/S1Bs1stem/scripts/system/system_info.sh` |
| **Hardware Check** | `source ~/Desktop/S1Bs1stem/scripts/common/functions.sh && has_battery && has_lid` |
| **Workflow Menu** | `~/Desktop/S1Bs1stem/scripts/workflow/ws-menu.sh` |
| **View Logs** | `source ~/Desktop/S1Bs1stem/scripts/common/logger.sh && log_tail` |
| **Reset Install** | `./install/ORCHESTRA.sh --reset` |

---

**For more information**, see:
- [Main README.md](../README.md)
- [DWM Setup Guide](02_DWM_SETUP.md)
- [Troubleshooting Guide](11_TROUBLESHOOTING.md)
- [API Reference](12_API_REFERENCE.md)
