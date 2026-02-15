#!/bin/bash
# ============================================================
#  SERVICE STATUS - Show system service status
#  Dependencies: systemctl, jq
#  ============================================================

set -euo pipefail

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_STATE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/functions.sh"
source "$SCRIPT_DIR/../common/logger.sh"
source "$SCRIPT_DIR/../common/colors.sh"

# Get service status
get_service_status() {
    local service="$1"
    systemctl is-active "$service" 2>/dev/null && echo "running" || echo "inactive"
}

# Get all services
list_all_services() {
    echo ""
    echo -e "${COLOR_BOLD}${COLOR_Mauve}ALL SERVICES${COLOR_RESET}"
    echo "═════════════════════════════════════"
    echo ""
    
    systemctl list-unit-files --type=service --state=running | while read -r line; do
        service=$(echo "$line" | awk '{print $1}')
        echo "  - $service"
    done
    
    echo ""
}

# List failed services
list_failed_services() {
    log_info "Checking for failed services..."
    echo ""
    echo -e "${COLOR_BOLD}${COLOR_RED}FAILED SERVICES${COLOR_RESET}"
    echo "═══════════════════════════════════"
    echo ""
    
    local found_failed=false
    
    systemctl list-unit-files --state=failed | while read -r line; do
        service=$(echo "$line" | awk '{print $1}')
        found_failed=true
        echo "  - $service"
    done
    
    if [ "$found_failed" = false ]; then
        echo "  No failed services found"
    fi
    
    echo ""
}

# Show service details
show_service_details() {
    local service="$1"
    
    systemctl status "$service"
    echo ""
    echo -e "${COLOR_BOLD}${COLOR_Mauve}SERVICE: $service${COLOR_RESET}"
    echo "═══════════════════════════════════"
    echo ""
    
    systemctl status "$service" --no-pager
    echo ""
}

# Show active services
show_active_services() {
    echo ""
    echo -e "${COLOR_BOLD}${COLOR_GREEN}ACTIVE SERVICES${COLOR_RESET}"
    echo "═══════════════════════════════════"
    echo ""
    
    systemctl list-units --type=service --state=running | while read -r line; do
        service=$(echo "$line" | awk '{print $1}')
        echo "  - $service"
    done
    
    echo ""
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --list|-l)
            list_all_services
            shift
            ;;
        --failed|-f)
            list_failed_services
            shift
            ;;
        --active|-a)
            show_active_services
            shift
            ;;
        --show|-s)
            if [ -n "$2" ]; then
                show_service_details "$2"
                shift 2
            else
                log_error "Please specify a service name"
                exit 1
            fi
            ;;
        --restart|-r)
            if [ -n "$2" ]; then
                log_info "Restarting service: $2..."
                sudo systemctl restart "$2"
                shift 2
            else
                log_error "Please specify a service name"
                exit 1
            fi
            ;;
        --start)
            if [ -n "$2" ]; then
                log_info "Starting service: $2..."
                sudo systemctl start "$2"
                shift 2
            else
                log_error "Please specify a service name"
                exit 1
            fi
            ;;
        --stop)
            if [ -n "$2" ]; then
                log_info "Stopping service: $2..."
                sudo systemctl stop "$2"
                shift 2
            else
                log_error "Please specify a service name"
                exit 1
            fi
            ;;
        --enable|-e)
            if [ -n "$2" ]; then
                log_info "Enabling service: $2..."
                sudo systemctl enable "$2"
                shift 2
            else
                log_error "Please specify a service name"
                exit 1
            fi
            ;;
        --disable|-d)
            if [ -n "$2" ]; then
                log_info "Disabling service: $2..."
                sudo systemctl disable "$2"
                shift 2
            else
                log_error "Please specify a service name"
                exit 1
            fi
            ;;
        --help|-h)
            echo "Usage: $0 [--list|--failed|--active|--show|--start|--stop|--restart|--enable|--disable|--help]"
            echo ""
            echo "Options:"
            echo "  --list, -l            List all services"
            echo "  --failed, -f           List failed services"
            echo "  --active, -a           Show active services"
            echo "  --show, -s <service>   Show detailed status of specific service"
            echo "  --start <service>       Start a service"
            echo "  --stop <service>        Stop a service"
            echo "  --restart <service>    Restart a service"
            echo "  --enable <service>     Enable a service"
            echo "  --disable <service>    Disable a service"
            echo "  --help, -h             Show this help"
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Default: show active services
show_active_services

log_success "Service status retrieved"
