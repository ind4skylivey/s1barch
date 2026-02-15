#!/bin/bash
# ============================================================
#  CUSTOM MODULE SELECTOR
#  Let user choose specific modules to install
#  ============================================================

echo ""
echo "⚙️  Custom Module Selection"
echo "═══════════════════════════════════════════════════════"
echo ""
echo "Select modules to install:"
echo "  - [SPACE] Toggle selection"
echo "  - [ENTER] Confirm selections"
echo "  - [q] Quit"
echo ""

# Define modules with descriptions
declare -A MODULES=(
    ["shell"]="Shell (ZSH, Fish, Starship)"
    ["terminal"]="Terminal (Kitty, Alacritty)"
    ["dwm"]="DWM Window Manager"
    ["picom"]="Picom Compositor (X11)"
    ["rofi"]="Rofi Launcher (X11)"
    ["waybar"]="Waybar Status Bar (Wayland)"
    ["wofi"]="Wofi Launcher (Wayland)"
    ["qt"]="Qt Theme Engine (Kvantum, qt5ct)"
    ["warp"]="Warp Terminal + Themes"
    ["browser"]="Browser (Zen Browser)"
    ["editor"]="Editors (Neovim, Doom Emacs, Micro, Helix)"
    ["filemanager"]="File Managers (Yazi, PCManFM-Qt)"
    ["multiplexer"]="Multiplexers (Tmux, Zellij)"
    ["monitor"]="Monitors (BTop, Cava, Fastfetch, Materiatrack)"
    ["workflow"]="Eco-Workflow System"
)

# Initialize all modules as unselected (0)
for key in "${!MODULES[@]}"; do
    declare "SELECTED_$key=0"
done

# Function to display menu
show_menu() {
    clear
    echo ""
    echo "⚙️  Custom Module Selection"
    echo "═══════════════════════════════════════════════════════"
    echo ""
    echo "Select modules to install:"
    echo "  - [SPACE] Toggle selection"
    echo "  - [ENTER] Confirm selections"
    echo "  - [q] Quit"
    echo ""
    
    local counter=1
    for key in "${!MODULES[@]}"; do
        local selected_var="SELECTED_$key"
        local selected="${!selected_var}"
        local check="[ ]"
        
        if [ "$selected" = "1" ]; then
            check="[✓]"
        fi
        
        printf "  %s %2d) %s\n" "$check" "$counter" "${MODULES[$key]}"
        ((counter++))
    done
    
    echo ""
    echo "═══════════════════════════════════════════════════════"
    echo ""
}

# Main selection loop
# shellcheck disable=SC2034
current_selection=1
total_modules=${#MODULES[@]}

while true; do
    show_menu
    
    echo -n "Select module [1-$total_modules/q]: "
    IFS= read -rsn1 input
    
    case "$input" in
        q|Q)
            echo ""
            echo "❌ Installation cancelled by user"
            exit 0
            ;;
        "")
            # ENTER pressed - confirm selections
            break
            ;;
        *)
            if [[ "$input" =~ ^[0-9]+$ ]] && [ "$input" -ge 1 ] && [ "$input" -le "$total_modules" ]; then
                # Toggle selection
                counter=1
                key_to_toggle=""
                for key in "${!MODULES[@]}"; do
                    if [ "$counter" -eq "$input" ]; then
                        key_to_toggle="$key"
                        break
                    fi
                    ((counter++))
                done
                
                if [ -n "$key_to_toggle" ]; then
                    selected_var="SELECTED_$key_to_toggle"
                    if [ "${!selected_var}" = "1" ]; then
                        declare "$selected_var=0"
                    else
                        declare "$selected_var=1"
                    fi
                fi
            fi
            ;;
    esac
done

# Export selections to file
INSTALL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.."
: > "$INSTALL_DIR/.custom_selection"
for key in "${!MODULES[@]}"; do
    selected_var="SELECTED_$key"
    selected="${!selected_var}"
    if [ "$selected" = "1" ]; then
        echo "$key" >> "$INSTALL_DIR/.custom_selection"
    fi
done

echo ""
echo "✓ Modules selected for custom installation"
echo ""
