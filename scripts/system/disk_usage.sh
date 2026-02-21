#!/bin/bash
# ============================================================
#  DISK USAGE - Show disk usage statistics
#  ============================================================

set -euo pipefail

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/functions.sh"
source "$SCRIPT_DIR/../common/logger.sh"
source "$SCRIPT_DIR/../common/colors.sh"

# Configuration
WARNING_THRESHOLD=80
# shellcheck disable=SC2034
HIGHLIGHT_DISK="/"

log_info "Checking disk usage statistics..."

# Get all mounted filesystems
get_mountpoints() {
    df -h | grep -vE "^/dev/" | awk '{print $6}'
}

# Get disk usage for specific mountpoint
get_disk_usage() {
    local mountpoint="$1"
    
    echo -e "${COLOR_BOLD}${COLOR_Mauve}DISK USAGE: $mountpoint${COLOR_RESET}"
    echo "═══════════════════════════════════════════════════════════════════════"
    echo ""
    
    # Show disk usage
    df -h "$mountpoint" | awk '
        BEGIN {
            size=$2
            used=$3
            avail=$4
            percent=$5
            gsub(/%$/, "", percent)
            if (percent >= '"$WARNING_THRESHOLD"') {
                printf " - %s\n", percent "%"
            } else {
                printf "  %s\n", percent "%"
            }
        }
        print $6
        }' | column -t -o 2
    
    echo ""
    
    # Check for full disks
    df -h "$mountpoint" | while read -r dev total avail used pcent path; do
        if [ "$pcent" -ge "$WARNING_THRESHOLD" ]; then
            echo -e "${COLOR_RED}WARN: $dev is nearly full ($pcent% used)${COLOR_RESET}"
            echo "  Path: $path"
            echo ""
        fi
    done
    
    # Show overall disk summary
    echo ""
    echo -e "${COLOR_BOLD}${COLOR_Mauve}DISK SUMMARY${COLOR_RESET}"
    echo "═════════════════════════════════════════════════════════════"
    echo ""
    
    df -h --output=pcent,size | grep -vE "^/dev/" | awk '
        BEGIN {
            total=$2
            avail=$3
            used=$4
            pcent=$5
            print used, avail, pcent, $6
        } END {
            printf "  %s /  %s /  %s\n", $6, $total, used, avail, pcent, $6
        }' | sort -k -n | awk '{print $2}' | while read -r dev total avail used pcent path; do
            printf "  - %s\n" "$dev", "$total", "$used", "$avail", "$pcent", "$path"
        done
    
    echo ""
    echo -e "${COLOR_BOLD}${COLOR_Mauve}DISK BY USAGE${COLOR_RESET}"
    echo "═════════════════════════════════════════════════════"
    echo ""
    
    local total_gb
    total_gb=$(df -h --output=pcent,size | grep -vE "^/dev/" | awk '{sum += $2}')
    
    printf "Total disk space: %s GB\n" "$total_gb"
    
    echo ""
    echo -e "${COLOR_BOLD}${COLOR_Mauve}TOP 10 LARGEST FILES${COLOR_RESET}"
    echo "═════════════════════════════════════════════════════"
    echo ""
    
    du -ah / 2>/dev/null | sort -rh | head -10 | while read -r _size path; do
        echo "  $path"
    done
}

# Show disk usage of all mountpoints
show_all_disks() {
    echo ""
    echo -e "${COLOR_BOLD}${COLOR_Mauve}ALL DISKS${COLOR_RESET}"
    echo "═══════════════════════════════════════════════════════"
    echo ""
    
    # Show usage for each mountpoint
    get_mountpoints | while read -r mount; do
        get_disk_usage "$mount"
        echo ""
    done
    
    log_success "Disk usage statistics displayed"
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --show|-s)
            show_all_disks
            shift
            ;;
        --mountpoint)
            if [ -n "$2" ]; then
                get_disk_usage "$2"
            else
                log_error "Please specify mountpoint (e.g. /home)"
                exit 1
            fi
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [--show|--mountpoint <path>|--help]"
            echo ""
            echo "Options:"
            echo "  --show              Show disk usage for all mountpoints"
            echo "  --mountpoint <path>  Show disk usage for specific mountpoint"
            echo "  --help, -h           Show this help"
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            echo "Usage: $0 [--show|--mountpoint <path>|--help]"
            exit 1
            ;;
    esac
    shift
done

# Default: show all disks
show_all_disks

log_success "Disk usage script completed"
