# S1Bs1stem

**🚀 Sistema de Automatización Avanzado para Arch Linux + DWM**

Inspirado por el proyecto [S1B](https://github.com/dusklinux/s1b), adaptado para ecosistemas DWM/Zellij/Eco-Workflow.

## 📋 Table of Contents

- [About](#-about)
- [Features](#-features)
- [Quick Start](#-quick-start)
- [Project Structure](#-project-structure)
- [Installation](#-installation)
- [Usage](#-usage)
- [Workflows](#-workflows)
- [Contributing](#-contributing)
- [License](#-license)

---

## ⚡ About

**S1Bs1stem** es más que configuraciones de dotfiles; es una **capa de orquestación completa** diseñada para desarrolladores, investigadores de seguridad y usuarios de Linux que buscan un entorno minimalista pero altamente funcional.

### Core Philosophy

- **Minimal Intrusion:** Las herramientas deben adaptarse a la intención del usuario, no al revés
- **Maximum Reproducibility:** Scripts modulares y validación robusta
- **Safety First:** Pre-flight checks, rollback system, y logging avanzado
- **Eco-Workflow:** Context-aware sessions (Local, Remote, Write, RedTeam)

### Inspired by

Este proyecto está inspirado en [S1B dotfiles](https://github.com/dusklinux/s1b) y adapta su arquitectura de orquestación a ecosistemas DWM/Zellij en lugar de Hyprland/Waybar.

---

## ✨ Features

### Orchestration System

- ✅ **Pre-flight Validation:** Verificación completa antes de instalación
- ✅ **State Management:** Resume capability - continúa donde lo dejaste
- ✅ **Retry Loops:** Scripts fallan con reintentos automáticos
- ✅ **Interactive Mode:** Modo interactivo para mayor control
- ✅ **Dry-run Mode:** Vista previa de acciones sin ejecutar nada
- ✅ **Rollback System:** Snapshots y restauración de configuraciones

### Common Libraries

- ✅ **Functions Library:** Funciones comunes reutilizables
- ✅ **Logger System:** Logging con colores, timestamps, y rotación de logs
- ✅ **Validator System:** Validación de dependencias y sistema
- ✅ **Color System:** Tema Catppuccin Mauve consistente
- ✅ **Rollback System:** Gestión completa de snapshots

### Modular Scripts

- ✅ **Audio:** audio_switch.sh, mic_switch.sh, volume_slider.sh
- ✅ **Battery:** battery_notify.sh, power_saver.sh
- ✅ **Display:** wallpaper_cycle.sh, brightness_slider.sh, screenshot_manager.sh
- ✅ **Networking:** vpn_connect.sh, wifi_switch.sh, network_status.sh
- ✅ **DWM:** toggle_floating.sh, window_rules.sh, dwm_autostart.sh
- ✅ **Waybar:** git_status.sh, uptime.sh, vpn_status.sh, cpu/memory/disk monitoring
- ✅ **Workflow:** ws-local.sh, ws-remote.sh, ws-write.sh, ws-redteam.sh
- ✅ **Security:** scan_commit.sh, malware_analysis.sh, quick_scan.sh
- ✅ **Rofi:** powermenu.sh, launcher.sh, emoji.sh

### Eco-Workflow System

- 🖥️ **Local Development:** Neovim + Zellij + Kitty para desarrollo local
- 🌐 **Remote Server:** Tmux + SSH sessions para servidores remotos
- 📝 **Deep Write:** Doom Emacs + Yazi para escritura sin distracciones
- 🛡️ **Red Team:** Zellij + Podman para investigación de seguridad

---

## 🚀 Quick Start

### Prerequisites

- Arch Linux (o Arch-based como CachyOS)
- DWM instalado
- ZSH o Fish shell
- Conexión a internet
- Mínimo 5GB de espacio libre

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

### Post-Installation

```bash
# 1. Logout and login (aplicar shell)
# 2. Restart DWM
# 3. Run verification
s1b-doctor
```

---

## 🏗️ Project Structure

```
S1Bs1stem/
├── install/                      # Sistema de instalación
│   ├── ORCHESTRA.sh            # Script maestro
│   ├── preflight/               # Pre-flight checks
│   ├── modules/                  # Módulos de instalación
│   ├── post_install/             # Post-instalación
│   └── rollback/                # Sistema de rollback
├── scripts/                     # Todos los scripts organizados
│   ├── common/                  # Librerías comunes
│   │   ├── functions.sh          # Funciones base
│   │   ├── logger.sh            # Sistema de logging
│   │   ├── validator.sh          # Validación
│   │   ├── colors.sh            # Colores Catppuccin
│   │   └── rollback.sh          # Sistema de snapshots
│   ├── audio/                   # Scripts de audio
│   ├── battery/                 # Scripts de batería
│   ├── display/                 # Scripts de monitor
│   ├── networking/              # Scripts de red
│   ├── dwm/                    # Scripts DWM
│   ├── waybar/                 # Scripts Waybar
│   ├── workflow/                # Scripts Eco-Workflow
│   ├── security/                # Scripts seguridad
│   ├── rofi/                   # Scripts Rofi
│   └── git/                    # Scripts Git
├── configs/                     # Configuraciones organizadas
│   ├── dwm/
│   ├── waybar/
│   ├── zellij/
│   ├── rofi/
│   └── kitty/
├── workflow/                    # Sistema Eco-Workflow
│   ├── profiles/                 # Perfiles de workflows
│   └── zellij/layouts/          # Layouts Zellij
├── ui/                          # Control Center GUI
│   ├── s1b_control_center.py  # Python/Tkinter
│   └── ui_config.yaml           # Configuración GUI
├── tests/                       # Suite de tests
├── docs/                        # Documentación
├── backup/                      # Backups automáticos
├── logs/                        # Logs del sistema
├── README.md                    # Este archivo
├── LICENSE                      # Licencia MIT
└── CHANGELOG.md                 # Historia de cambios
```

---

## 🔧 Installation

### Normal Installation

```bash
cd ~/Desktop/S1Bs1stem
./install/ORCHESTRA.sh
```

### Interactive Mode

```bash
./install/ORCHESTRA.sh --interactive
```

### Dry-run Mode (Preview)

```bash
./install/ORCHESTRA.sh --dry-run
```

### Reset Installation

```bash
./install/ORCHESTRA.sh --reset
```

### Individual Module Installation

```bash
# Install only DWM setup
./install/modules/010_dwm_setup.sh

# Install only shell setup
./install/modules/020_shell_setup.sh
```

---

## 📚 Usage

### Orchestrator Commands

```bash
# Normal installation
./install/ORCHESTRA.sh

# Interactive mode (prompt before each script)
./install/ORCHESTRA.sh --interactive

# Dry-run (preview without executing)
./install/ORCHESTRA.sh --dry-run

# Reset state
./install/ORCHESTRA.sh --reset

# Verbose output
./install/ORCHESTRA.sh --verbose

# Show help
./install/ORCHESTRA.sh --help
```

### Common Functions Usage

```bash
# Source functions in your scripts
source ~/Desktop/S1Bs1stem/scripts/common/functions.sh

# Use helper functions
backup_file ~/.config/dwm
check_dependencies git zsh tmux
switch_workflow local
dwm_restart
waybar_reload
```

### Logger Usage

```bash
# Source logger
source ~/Desktop/S1Bs1stem/scripts/common/logger.sh

# Log messages
log_info "Starting process..."
log_success "Process completed!"
log_warn "Warning message"
log_error "Error occurred"

# View logs
log_recent 20        # Last 20 lines
log_last_errors 10   # Last 10 errors
log_tail              # Follow logs in real-time
```

### Rollback System

```bash
# Create snapshot
source ~/Desktop/S1Bs1stem/scripts/common/rollback.sh
create_snapshot "before_upgrade"

# Restore snapshot
restore_snapshot "before_upgrade"

# List snapshots
list_snapshots

# Delete snapshot
delete_snapshot "old_snapshot"

# Auto snapshot (with timestamp)
create_auto_snapshot
```

---

## 🧠 Workflows

### Switching Workflows

```bash
# Using switch script
~/Desktop/S1Bs1stem/scripts/workflow/switch_workflow.sh local

# Using aliases (after sourcing)
ws-local      # Local Development
ws-remote     # Remote Server
ws-write       # Deep Write
ws-redteam     # Red Team
```

### Workflow Menu (Rofi)

```bash
# Launch workflow menu
~/Desktop/S1Bs1stem/scripts/workflow/ws-menu.sh
```

### Workflow Profiles

Los perfiles están en `workflow/profiles/`:

- **local.md:** Desarrollo local con Neovim + Zellij
- **remote.md:** Servidores remotos con Tmux + SSH
- **write.md:** Escritura con Doom Emacs + Yazi
- **redteam.md:** Investigación de seguridad con Zellij + Podman

---

## 🐛 Troubleshooting

### Common Issues

#### Installation Fails

**Problem:** ORCHESTRA.sh fails at script execution

**Solution:**
```bash
# Check logs
cat ~/.s1b_logs/s1b_system.log

# Run individual script manually
./install/modules/010_dwm_setup.sh
```

#### Dependencies Missing

**Problem:** Some packages are not installed

**Solution:**
```bash
# Install all dependencies manually
sudo pacman -S --needed <dependencies>

# Re-run orchestrator
./install/ORCHESTRA.sh
```

#### DWM Not Starting

**Problem:** DWM fails to start

**Solution:**
```bash
# Check DWM config
~/.config/dwm/config.h

# Test compile
cd ~/.config/dwm
sudo make clean install

# Check logs
~/.xsession-errors
```

#### Waybar Issues

**Problem:** Waybar not displaying or crashes

**Solution:**
```bash
# Check Waybar config
~/.config/waybar/config

# Test config
waybar -c ~/.config/waybar/config

# Check logs
journalctl -u waybar -f
```

### Getting Help

```bash
# Show help for any script
./scripts/common/rollback.sh help

# View logs
log_last_errors

# Run diagnostics
s1b-diagnose
```

---

## 🤝 Contributing

Contributions are welcome!

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Coding Standards

- Use Bash 4.0+ features (bashisms are OK)
- Source common functions when possible
- Use logging system (log_info, log_success, etc.)
- Include pre-flight checks in all scripts
- Document functions with comments
- Use descriptive variable names

### Script Template

```bash
#!/bin/bash
# ============================================================
#  SCRIPT NAME - Description
#  ============================================================
#  Author: Your Name
#  License: MIT
#  Version: 1.0.0
#  ============================================================

set -euo pipefail

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/functions.sh"
source "$SCRIPT_DIR/../common/logger.sh"
source "$SCRIPT_DIR/../common/colors.sh"

# --- MAIN LOGIC ---
main() {
    log_info "Starting script..."
    
    # Your code here
    
    log_success "Script completed!"
}

# Run main
main "$@"
```

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🌟 Acknowledgments

- Inspired by [S1B dotfiles](https://github.com/dusklinux/s1b)
- Built on [Arch Linux](https://archlinux.org/)
- Window Manager: [DWM](https://dwm.suckless.org/)
- Terminal Multiplexer: [Zellij](https://zellij.dev/) / [Tmux](https://github.com/tmux/tmux)
- Shell: [ZSH](https://www.zsh.org/)
- Theme: [Catppuccin](https://github.com/catppuccin/catppuccin)

---

## 📞 Support

- **GitHub Issues:** [Report a bug](https://github.com/ind4skylivey/S1Bs1stem/issues)
- **Discord:** [Join our community](https://discord.gg/your-server)
- **Documentation:** [Full docs](https://github.com/ind4skylivey/S1Bs1stem/wiki)

---

**Made with ❤️ by [S1B](https://github.com/ind4skylivey)**
