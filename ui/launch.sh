#!/bin/bash
# ============================================================
#  S1B CONTROL CENTER LAUNCHER
#  Quick launcher for the S1Bs1stem GUI
#  ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if Python and Tkinter are available
if ! command -v python3 &>/dev/null; then
    echo "Error: Python 3 is required but not installed."
    echo "Install with: sudo pacman -S python"
    exit 1
fi

if ! python3 -c "import tkinter" 2>/dev/null; then
    echo "Error: Tkinter is required but not installed."
    echo "Install with: sudo pacman -S python-tk"
    exit 1
fi

# Check for PyYAML
if ! python3 -c "import yaml" 2>/dev/null; then
    echo "Warning: PyYAML not found. Installing..."
    pip3 install --user pyyaml 2>/dev/null || {
        echo "Please install PyYAML manually: pip3 install pyyaml"
        exit 1
    }
fi

# Launch Control Center
exec python3 "$SCRIPT_DIR/s1b_control_center.py" "$@"
