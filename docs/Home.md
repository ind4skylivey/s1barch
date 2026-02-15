# 🚀 S1BArch - Wiki

Welcome to the **S1BArch** wiki. This is the official documentation for the advanced automation system for Arch Linux + DWM.

## 📑 What is S1BArch?

**S1BArch** is more than dotfile configurations; it's a **complete orchestration layer** designed for developers, security researchers, and Linux users seeking a minimalist yet highly functional environment.

> **Core Philosophy**: Minimal intrusion, maximum reproducibility. Tools should adapt to the user's intent, not the other way around.

## 🌌 Key Features

- **Orchestration System**: Complete installation automation with pre-flight checks, state management, and rollback
- **Hardware Detection**: Automatic desktop vs laptop detection with adaptive behavior
- **Eco-Workflow**: Context-aware sessions (Local, Remote, Write, RedTeam)
- **Automation Scripts**: 30+ scripts for audio, battery, display, networking, and system management
- **DWM Configuration**: Patched DWM with systray support, window swallowing, and autostart
- **Shared Modules**: Qt themes, Warp terminal, browser configs, editors, and more

## 📚 Documentation

| Page | Description |
|:---|:---|
| **[Installation](Installation.md)** | Complete installation guide for S1Bs1stem |
| **[DWM Setup](DWM-Setup.md)** | DWM window manager configuration and setup |
| **[Audio](Audio.md)** | Audio management scripts (volume, mic, output switching) |
| **[Battery](Battery.md)** | Battery monitoring and power management (laptops) |
| **[Display](Display.md)** | Display scripts (screenshots, wallpaper cycling) |
| **[Window Management](Window-Management.md)** | DWM window control, rules, and autostart |
| **[Networking](Networking.md)** | Network status, DNS switching, VPN, WiFi |
| **[System](System.md)** | System maintenance, cleanup, and monitoring |
| **[Workflows](Workflows.md)** | Eco-Workflow system (Local, Remote, Write, RedTeam) |
| **[Customization](Customization.md)** | Terminal, shell, and theme customization |
| **[Troubleshooting](Troubleshooting.md)** | Common issues and solutions |
| **[API Reference](API-Reference.md)** | Complete API documentation for scripts |

## 🚀 Quick Start

### One-Line Installation

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/ind4skylivey/S1Bs1stem/main/install.sh)
```

### Manual Installation

```bash
# 1. Clone repository
git clone https://github.com/ind4skylivey/S1Bs1stem.git ~/Desktop/S1Bs1stem

# 2. Navigate to directory
cd ~/Desktop/S1Bs1stem

# 3. Run orchestrator
./install/ORCHESTRA.sh
```

## 🖥️ Environment Selection

S1BArch supports two distinct environments:

| Environment | Components | Use Case |
|:---|:---:|:---:|
| **Wayland** | Waybar + Wofi | Modern compositing, GPU acceleration, Wayland-native |
| **DWM/X11** | DWM + Picom + Rofi + Systray | Classic, stable, minimal, X11-native |

## 🌐 Eco-Workflow Architecture

The heart of this setup is the **Orchestration Layer**. Instead of launching tools directly, you launch **Contexts**.

| Context | Command | Engine | Purpose |
|:---:|:---:|:---:|:---|
| **Development** | `ws-local` | **Zellij** | Coding, file management, and local testing |
| **Infrastructure** | `ws-remote` | **Tmux** | Persistent SSH sessions and server management |
| **Deep Work** | `ws-write` | **Emacs** | Distraction-free writing and Org-mode planning |
| **Red Team** | `ws-redteam** | **Docker** | Isolated environments for security research/CTF |

## 📊 System Requirements

| Requirement | Minimum | Recommended |
|:---|:---|:---:|
| **Operating System** | Arch Linux | Arch Linux / CachyOS |
| **RAM** | 4GB | 8GB+ |
| **Storage** | 5GB free | 20GB+ SSD |
| **Shell** | ZSH or Fish | ZSH 5.8+ |
| **Network** | Internet connection | Stable connection |

## 🔗 Useful Links

- **[GitHub Repository](https://github.com/ind4skylivey/s1barch)**
- **[Main README](https://github.com/ind4skylivey/s1barch#readme)**
- **[Issues](https://github.com/ind4skylivey/s1barch/issues)**
- **[Releases](https://github.com/ind4skylivey/s1barch/releases)**
- **[License](https://github.com/ind4skylivey/s1barch/blob/main/LICENSE)**

## 🤝 Contributing

Contributions are welcome! Please read our [contribution guidelines](https://github.com/ind4skylivey/s1barch/blob/main/README.md#contributing) for details.

---

**Last Updated**: January 2026  
**Version**: 1.6.0
