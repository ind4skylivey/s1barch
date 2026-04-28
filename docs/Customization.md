# Customization Guide

Complete guide for customizing S1Bs1stem to match your personal preferences and workflow.

## Table of Contents
- [Theme Customization](#theme-customization)
- [Shell Customization](#shell-customization)
- [Terminal Customization](#terminal-customization)
- [Keyboard Shortcuts](#keyboard-shortcuts)
- [Panel Customization](#panel-customization)
- [Application Preferences](#application-preferences)
- [Workflow Automation](#workflow-automation)
- [Advanced Customization](#advanced-customization)

---

## Theme Customization

### Overview

S1Bs1stem includes a flexible theming system for colors, fonts, and UI elements.

### Color Schemes

Default color schemes are defined in `~/.local/s1barch/scripts/common/colors.sh`:

```bash
# Default colors
readonly COLOR_RED='\033[0;31m'
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_YELLOW='\033[0;33m'
readonly COLOR_BLUE='\033[0;34m'
readonly COLOR_PURPLE='\033[0;35m'
readonly COLOR_CYAN='\033[0;36m'
readonly COLOR_WHITE='\033[0;37m'

# Create custom theme
readonly COLOR_PRIMARY='\033[0;38;5;208m'   # Orange
readonly COLOR_SECONDARY='\033[0;38;5;39m' # Blue
readonly COLOR_ACCENT='\033[0;38;5;46m'     # Green
```

### Custom Theme Creation

Create your own color scheme:

```bash
# Create custom colors file
mkdir -p ~/.config/s1b/themes
cat > ~/.config/s1b/themes/mytheme.sh << 'EOF'
#!/bin/bash

# My Custom Theme
readonly COLOR_PRIMARY='\033[0;38;5;208m'   # Orange
readonly COLOR_SECONDARY='\033[0;38;5;39m' # Blue
readonly COLOR_SUCCESS='\033[0;38;5;46m'    # Green
readonly COLOR_WARNING='\033[0;38;5;226m'   # Yellow
readonly COLOR_ERROR='\033[0;38;5;196m'    # Red
readonly COLOR_INFO='\033[0;38;5;33m'      # Cyan

# Bold variants
readonly COLOR_BOLD_PRIMARY='\033[1;38;5;208m'
readonly COLOR_BOLD_SUCCESS='\033[1;38;5;46m'
readonly COLOR_BOLD_WARNING='\033[1;38;5;226m'
readonly COLOR_BOLD_ERROR='\033[1;38;5;196m'
EOF

# Source custom theme in scripts
source ~/.config/s1b/themes/mytheme.sh
```

### DWM Theme Customization

Customize DWM colors in `~/.local/src/dwm/config.h`:

```c
// Custom color scheme
static const char *colors[][3] = {
    /* fg        bg        border */
    [SchemeNorm] = { "#bbbbbb", "#1a1b26", "#414868" },  /* Tokyo Night style */
    [SchemeSel]  = { "#c0caf5", "#7aa2f7", "#7aa2f7" },  /* Active window */
};

// Custom fonts
static const char *fonts[] = {
    "JetBrains Mono:size=10:antialias=true:autohint=true",
    "Noto Color Emoji:size=10:antialias=true:autohint=true",
    "Symbols Nerd Font:size=10"
};
```

### Rofi Theme Customization

Create custom Rofi theme:

```bash
# Create Rofi theme directory
mkdir -p ~/.config/rofi

# Create custom theme
cat > ~/.config/rofi/custom.rasi << 'EOF'
configuration {
    display-drun: "Apps";
    display-run: "Run";
    display-window: "Windows";
}

* {
    background-color: #1a1b26;
    text-color: #c0caf5;
    font: "JetBrains Mono 10";
}

window {
    background-color: #1a1b26;
    border: 2px;
    border-color: #7aa2f7;
}

element selected {
    background-color: #7aa2f7;
    text-color: #1a1b26;
}

element-text selected {
    background-color: #7aa2f7;
    text-color: #1a1b26;
}
EOF

# Use custom theme
rofi -show drun -theme ~/.config/rofi/custom.rasi
```

---

## Shell Customization

### Overview

Shell customization for enhanced productivity and visual appeal.

### Zsh Customization

Customize Zsh in `~/.zshrc`:

```bash
# Load S1Bs1stem shell setup
if [ -f ~/.local/s1barch/scripts/shell/zsh_setup.sh ]; then
    source ~/.local/s1barch/scripts/shell/zsh_setup.sh
fi

# Custom aliases
alias ll='ls -lah --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Custom functions
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Custom prompt
setopt PROMPT_SUBST
PROMPT='%F{208}%n%f@%F{39}%m%f %F{208}%~%f %(?.%F{46}.%F{196})%?%f $ '
RPROMPT='%F{33}%D{%H:%M:%S}%f'

# History settings
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY

# Auto-completion
autoload -Uz compinit
compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
```

### Fish Customization

Customize Fish in `~/.config/fish/config.fish`:

```fish
# Load S1Bs1stem shell setup
if test -f ~/.local/s1barch/scripts/shell/fish_setup.fish
    source ~/.local/s1barch/scripts/shell/fish_setup.fish
end

# Custom aliases
alias ll 'ls -lah'
alias la 'ls -A'
alias l 'ls -CF'
alias grep 'grep --color=auto'

# Custom functions
function mkcd
    mkdir -p $argv; and cd $argv
end

# Custom prompt
function fish_prompt
    set_color orange
    echo -n (whoami)'@'(hostname)
    set_color blue
    echo -n ' ' (prompt_pwd)
    echo -n ' '
    if test $status -eq 0
        set_color green
    else
        set_color red
    end
    echo -n $status
    set_color normal
    echo -n ' $ '
end

# History
set -x HISTSIZE 10000
set -x SAVEHIST 10000
set -x HISTFILE ~/.fish_history
```

### Starship Prompt

Install and configure Starship prompt:

```bash
# Install Starship
cargo install starship

# Configure in .zshrc
eval "$(starship init zsh)"

# Configure in .config/fish/config.fish
starship init fish | source

# Create Starship config
mkdir -p ~/.config/starship
cat > ~/.config/starship.toml << 'EOF'
[character]
success_symbol = "[λ](bold green)"
error_symbol = "[λ](bold red)"

[directory]
style = "bold blue"
truncate_to_repo = false

[git_branch]
style = "bold purple"

[git_status]
style = "bold yellow"
EOF
```

---

## Terminal Customization

### Overview

Terminal customization for better readability and functionality.

### Alacritty Configuration

Customize Alacritty terminal emulator:

```yaml
# ~/.config/alacritty/alacritty.yml
env:
  TERM: xterm-256color

window:
  dimensions:
    columns: 80
    lines: 24
  padding:
    x: 5
    y: 5
  decorations: full
  startup_mode: Windowed

scrolling:
  history: 10000
  multiplier: 3

font:
  normal:
    family: JetBrains Mono
    style: Regular
  bold:
    family: JetBrains Mono
    style: Bold
  italic:
    family: JetBrains Mono
    style: Italic
  bold_italic:
    family: JetBrains Mono
    style: Bold Italic
  size: 10.0

# Tokyo Night color scheme
colors:
  primary:
    background: '0x1a1b26'
    foreground: '0xc0caf5'
  normal:
    black:   '0x1a1b26'
    red:     '0xf7768e'
    green:   '0x9ece6a'
    yellow:  '0xe0af68'
    blue:    '0x7aa2f7'
    magenta: '0xbb9af7'
    cyan:    '0x7dcfff'
    white:   '0xc0caf5'
  bright:
    black:   '0x414868'
    red:     '0xf7768e'
    green:   '0x9ece6a'
    yellow:  '0xe0af68'
    blue:    '0x7aa2f7'
    magenta: '0xbb9af7'
    cyan:    '0x7dcfff'
    white:   '0xc0caf5'

key_bindings:
  - { key: V, mods: Control|Shift, action: Paste }
  - { key: C, mods: Control|Shift, action: Copy }
  - { key: Plus, mods: Control, action: IncreaseFontSize }
  - { key: Minus, mods: Control, action: DecreaseFontSize }
  - { key: Key0, mods: Control, action: ResetFontSize }
```

### Kitty Configuration

Customize Kitty terminal emulator:

```conf
# ~/.config/kitty/kitty.conf
font_family JetBrains Mono
bold_font JetBrains Mono Bold
italic_font JetBrains Mono Italic
bold_italic_font JetBrains Mono Bold Italic
font_size 10.0

# Tokyo Night color scheme
background #1a1b26
foreground #c0caf5
cursor #c0caf5
selection_background #7aa2f7
selection_foreground #1a1b26

color0 #1a1b26
color1 #f7768e
color2 #9ece6a
color3 #e0af68
color4 #7aa2f7
color5 #bb9af7
color6 #7dcfff
color7 #c0caf5
color8 #414868
color9 #f7768e
color10 #9ece6a
color11 #e0af68
color12 #7aa2f7
color13 #bb9af7
color14 #7dcfff
color15 #c0caf5

# Keyboard shortcuts
map ctrl+shift+v paste_from_clipboard
map ctrl+shift+c copy_to_clipboard
map ctrl+plus change_font_size all +2.0
map ctrl+minus change_font_size all -2.0
```

---

## Keyboard Shortcuts

### Overview

Keyboard shortcut customization for improved productivity.

### DWM Keybindings

Modify DWM keybindings in `~/.local/src/dwm/config.h`:

```c
static Key keys[] = {
    /* modifier         key         function        argument */
    { MODKEY,           XK_p,       spawn,          {.v = dmenucmd } },
    { MODKEY|ShiftMask, XK_Return, spawn,          {.v = termcmd } },
    { MODKEY,           XK_b,       togglebar,      {0} },
    { MODKEY,           XK_j,       focusstack,     {.i = +1 } },
    { MODKEY,           XK_k,       focusstack,     {.i = -1 } },
    { MODKEY,           XK_i,       incnmaster,     {.i = +1 } },
    { MODKEY,           XK_d,       incnmaster,     {.i = -1 } },
    { MODKEY,           XK_h,       setmfact,       {.f = -0.05} },
    { MODKEY,           XK_l,       setmfact,       {.f = +0.05} },
    { MODKEY,           XK_Return,  zoom,           {0} },
    { MODKEY|ShiftMask, XK_c,       killclient,     {0} },
    { MODKEY,           XK_t,       setlayout,      {.v = &layouts[0]} },
    { MODKEY,           XK_f,       setlayout,      {.v = &layouts[1]} },
    { MODKEY,           XK_m,       setlayout,      {.v = &layouts[2]} },
    { MODKEY,           XK_space,   setlayout,      {0} },
    { MODKEY|ShiftMask, XK_space,   togglefloating, {0} },
    { MODKEY,           XK_0,       view,           {.ui = ~0 } },
    { MODKEY,           XK_1,       view,           {.ui = 1 << 0} },
    { MODKEY,           XK_2,       view,           {.ui = 1 << 1} },
    { MODKEY,           XK_3,       view,           {.ui = 1 << 2} },
    { MODKEY|ShiftMask, XK_1,       tag,            {.ui = 1 << 0} },
    { MODKEY|ShiftMask, XK_2,       tag,            {.ui = 1 << 1} },
    { MODKEY|ShiftMask, XK_3,       tag,            {.ui = 1 << 2} },
    { MODKEY|ControlMask, XK_1,     toggleview,     {.ui = 1 << 0} },
    { MODKEY|ControlMask, XK_2,     toggleview,     {.ui = 1 << 1} },
    { MODKEY|ShiftMask|Mod4Mask, XK_1, toggletag,   {.ui = 1 << 0} },
    { MODKEY|ShiftMask|Mod4Mask, XK_2, toggletag,   {.ui = 1 << 1} },
};
```

### Custom Shortcuts

Add custom shortcuts to DWM:

```c
// Add to keys[] array in config.h

// Screenshot
{ MODKEY,           XK_s,       spawn,          SHCMD("scrot -s ~/Pictures/screenshot_%Y%m%d_%H%M%S.png") },

// Browser
{ MODKEY,           XK_w,       spawn,          SHCMD("firefox") },

// Editor
{ MODKEY,           XK_e,       spawn,          SHCMD("vscodium") },

// Terminal
{ MODKEY,           XK_Return,  spawn,          SHCMD("alacritty") },

// File manager
{ MODKEY,           XK_f,       spawn,          SHCMD("pcmanfm") },

// Music control
{ 0,                XF86XK_AudioPlay, spawn,   SHCMD("playerctl play-pause") },
{ 0,                XF86XK_AudioNext, spawn,   SHCMD("playerctl next") },
{ 0,                XF86XK_AudioPrev, spawn,   SHCMD("playerctl previous") },
{ 0,                XF86XK_AudioMute, spawn,   SHCMD("playerctl mute") },
```

---

## Panel Customization

### Overview

Panel/status bar customization for better system monitoring.

### DWM Bar Customization

Customize DWM status bar in `~/.config/dwm/dwm_bar.sh`:

```bash
#!/bin/bash

# Custom status bar configuration
update_bar() {
    # System info
    UPTIME=$(uptime -p | sed 's/up //')
    KERNEL=$(uname -r)
    
    # Network info
    NETWORK=$(~/.local/s1barch/scripts/networking/network_status.sh --short)
    
    # Audio info
    AUDIO=$(~/.local/s1barch/scripts/audio/audio_status.sh --short)
    
    # Date and time
    DATE=$(date '+%Y-%m-%d')
    TIME=$(date '+%H:%M:%S')
    
    # Build status string
    STATUS=" $KERNEL | $UPTIME | $NETWORK | $AUDIO | $DATE $TIME"
    
    # Set status
    xsetroot -name "$STATUS"
}

# Update every second
while true; do
    update_bar
    sleep 1
done
```

### Waybar Customization

Customize Waybar (if using Wayland):

```yaml
# ~/.config/waybar/config
{
    "layer": "top",
    "position": "top",
    "height": 30,
    "modules-left": ["sway/workspaces", "sway/mode", "sway/window"],
    "modules-center": ["clock"],
    "modules-right": ["tray", "pulseaudio", "network", "cpu", "memory", "battery"],
    
    "sway/workspaces": {
        "disable-scroll": true,
        "all-outputs": true
    },
    
    "clock": {
        "format": "{:%Y-%m-%d %H:%M:%S}"
    },
    
    "pulseaudio": {
        "scroll-step": 5,
        "format": "{volume}% {icon}",
        "format-muted": "󰝟"
    },
    
    "network": {
        "format-wifi": " {signalStrength}%",
        "format-ethernet": "󰈀 {ipaddr}",
        "format-disconnected": "󰖪"
    },
    
    "cpu": {
        "format": "󰻠 {usage}%",
        "interval": 2
    },
    
    "memory": {
        "format": "󰍛 {}%"
    },
    
    "battery": {
        "states": {
            "warning": 30,
            "critical": 15
        },
        "format": "{icon} {capacity}%",
        "format-charging": "󰂄 {capacity}%",
        "format-icons": ["󰂎", "󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"]
    }
}
```

---

## Application Preferences

### Overview

Customize application settings and preferences.

### Browser Preferences

Firefox configuration:

```bash
# Create Firefox user.js
mkdir -p ~/.mozilla/firefox/*.default-release
cat > ~/.mozilla/firefox/*.default-release/user.js << 'EOF'
// Privacy settings
user_pref("privacy.trackingprotection.enabled", true);
user_pref("privacy.trackingprotection.pbmode.enabled", true);
user_pref("privacy.resistFingerprinting", true);

// Performance
user_pref("gfx.webrender.all", true);
user_pref("media.ffmpeg.vaapi.enabled", true);
user_pref("media.rdd-ffmpeg.enabled", true);

// UI customization
user_pref("browser.compactmode.show", true);
user_pref("browser.uiCustomization.state", "customization-compact");
EOF
```

### Editor Preferences

VSCode/VSCodium configuration:

```json
// ~/.config/VSCodium/User/settings.json
{
    "editor.fontFamily": "JetBrains Mono",
    "editor.fontSize": 10,
    "editor.tabSize": 2,
    "editor.insertSpaces": true,
    "editor.formatOnSave": true,
    "editor.wordWrap": "on",
    "editor.minimap.enabled": false,
    "workbench.colorTheme": "Tokyo Night",
    "workbench.iconTheme": "material-icon-theme",
    "terminal.integrated.fontFamily": "JetBrains Mono",
    "terminal.integrated.fontSize": 10
}
```

---

## Workflow Automation

### Overview

Automate repetitive tasks and workflows.

### Custom Scripts

Create custom automation scripts:

```bash
# Create scripts directory
mkdir -p ~/.local/bin

# Example: Quick backup script
cat > ~/.local/bin/backup-quick.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="$HOME/Backups/quick"
DATE=$(date +%Y%m%d_%H%M%S)
mkdir -p "$BACKUP_DIR"
tar -czf "$BACKUP_DIR/backup_$DATE.tar.gz" "$HOME/Documents" "$HOME/.config"
echo "Backup created: $BACKUP_DIR/backup_$DATE.tar.gz"
EOF
chmod +x ~/.local/bin/backup-quick.sh

# Example: Quick screenshot
cat > ~/.local/bin/screenshot-area.sh << 'EOF'
#!/bin/bash
mkdir -p ~/Pictures/screenshots
scrot -s ~/Pictures/screenshots/screenshot_$(date +%Y%m%d_%H%M%S).png
EOF
chmod +x ~/.local/bin/screenshot-area.sh
```

### Systemd Timers

Create automated tasks with systemd:

```bash
# Create backup timer
cat > ~/.config/systemd/user/backup.timer << 'EOF'
[Unit]
Description=Daily backup

[Timer]
OnCalendar=*-*-* 02:00
Persistent=true

[Install]
WantedBy=timers.target
EOF

cat > ~/.config/systemd/user/backup.service << 'EOF'
[Unit]
Description=Daily backup service

[Service]
Type=oneshot
ExecStart=%h/.local/bin/backup-quick.sh
EOF

# Enable timer
systemctl --user enable backup.timer
systemctl --user start backup.timer
```

---

## Advanced Customization

### Overview

Advanced customization techniques.

### Compiling Custom Packages

Compile packages with custom flags:

```bash
# Create custom PKGBUILD
mkdir -p ~/builds/custom-dwm
cd ~/builds/custom-dwm
git clone https://git.suckless.org/dwm .
git apply ~/.local/s1barch/patches/dwm/custom.patch
makepkg -si
```

### Custom Patches

Apply custom patches to packages:

```bash
# Apply DWM patches
cd ~/.local/src/dwm

# Add gaps patch
patch -p1 < ~/.local/s1barch/patches/dwm/dwm-gaps-6.2.diff

# Add center patch
patch -p1 < ~/.local/s1barch/patches/dwm/dwm-center-6.2.diff

# Recompile
sudo make install
```

### Custom Desktop Entries

Create custom desktop entries:

```bash
# Create custom launcher
cat > ~/.local/share/applications/custom-launcher.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=My Custom Launcher
Exec=/path/to/script.sh
Icon=application-x-executable
Terminal=false
Categories=Utility;
EOF

# Update desktop database
update-desktop-database ~/.local/share/applications
```

---

## Quick Reference

| Customization | File | Command |
|:---|:---:|:---:|
| **Colors** | `~/.local/s1barch/scripts/common/colors.sh` | Edit color variables |
| **DWM Config** | `~/.local/src/dwm/config.h` | Edit config.h and recompile |
| **Rofi Theme** | `~/.config/rofi/custom.rasi` | Create custom theme |
| **Zsh Config** | `~/.zshrc` | Edit .zshrc |
| **Fish Config** | `~/.config/fish/config.fish` | Edit config.fish |
| **Alacritty** | `~/.config/alacritty/alacritty.yml` | Edit alacritty.yml |
| **Kitty** | `~/.config/kitty/kitty.conf` | Edit kitty.conf |
| **DWM Bar** | `~/.config/dwm/dwm_bar.sh` | Edit bar script |
| **Waybar** | `~/.config/waybar/config` | Edit waybar config |
| **Firefox** | `~/.mozilla/firefox/*/user.js` | Edit user.js |
| **VSCode** | `~/.config/VSCodium/User/settings.json` | Edit settings.json |

---

## For More Information

- [Main README](../README.md)
- [Installation Guide](01_INSTALLATION.md)
- [DWM Setup Guide](02_DWM_SETUP.md)
- [DWM Window Management](06_DWM_WINDOW_MANAGEMENT.md)
- [Troubleshooting](11_TROUBLESHOOTING.md)
- [API Reference](12_API_REFERENCE.md)
