#!/bin/bash
# ============================================================
#  S1Bs1stem - DEPENDENCY VALIDATOR
#  ============================================================
#  Usage: source ~/.local/s1barch/scripts/common/validator.sh
#  Purpose: Validate system dependencies before installation
#  Inspired by: S1B pre-flight checks
#  License: MIT
#  Version: 1.0.0
#  ============================================================

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/functions.sh"

# --- VALIDATION RESULTS ---
declare -a VALIDATION_ERRORS=()
declare -a VALIDATION_WARNINGS=()

# --- SYSTEM VALIDATION ---
validate_system() {
    log_info "Validating system..."
    
    # Check if running on Linux
    if [ "$(uname)" != "Linux" ]; then
        VALIDATION_ERRORS+=("Not running on Linux: $(uname)")
    fi
    
    # Check if Arch Linux
    if ! is_arch; then
        VALIDATION_ERRORS+=("Not Arch Linux: /etc/arch-release not found")
    fi
    
    # Check shell
    if [ -z "$BASH_VERSION" ]; then
        VALIDATION_WARNINGS+=("Not running in bash, some scripts may not work")
    fi
    
    # Check bash version
    if [ "${BASH_VERSINFO[0]}" -lt 4 ]; then
        VALIDATION_WARNINGS+=("Bash version ${BASH_VERSION} is old, consider upgrading")
    fi
}

# --- DISK SPACE VALIDATION ---
validate_disk_space() {
    log_info "Validating disk space..."
    
    local available_gb
    available_gb=$(df -BG "$HOME" | awk 'NR==2 {print $4}' | tr -d 'G')
    
    if [ "$available_gb" -lt 5 ]; then
        VALIDATION_ERRORS+=("Insufficient disk space: ${available_gb}GB available (min 5GB required)")
    elif [ "$available_gb" -lt 10 ]; then
        VALIDATION_WARNINGS+=("Low disk space: ${available_gb}GB available (recommended 10GB+)")
    else
        log_success "Disk space OK: ${available_gb}GB available"
    fi
}

# --- NETWORK VALIDATION ---
validate_network() {
    log_info "Validating network connection..."
    
    if ! is_connected; then
        VALIDATION_ERRORS+=("No internet connection")
    else
        log_success "Network OK: Connected to internet"
    fi
}

# --- DEPENDENCY VALIDATION ---
validate_core_dependencies() {
    log_info "Validating core dependencies..."
    
    local core_deps=(
        "bash"
        "git"
        "grep"
        "sed"
        "awk"
        "curl"
        "wget"
        "tar"
        "gzip"
    )
    
    local missing=()
    for cmd in "${core_deps[@]}"; do
        if ! command -v "$cmd" &>/dev/null; then
            missing+=("$cmd")
        fi
    done
    
    if [ ${#missing[@]} -gt 0 ]; then
        VALIDATION_ERRORS+=("Missing core dependencies: ${missing[*]}")
    else
        log_success "Core dependencies OK"
    fi
}

validate_optional_dependencies() {
    log_info "Validating optional dependencies..."
    
    local optional_deps=(
        "pacman"         # Package manager
        "nvidia-smi"      # NVIDIA GPU
        "vulkaninfo"      # Vulkan support
        "xrandr"          # Display management
        "systemctl"       # Systemd
    )
    
    local missing_optional=()
    for cmd in "${optional_deps[@]}"; do
        if ! command -v "$cmd" &>/dev/null; then
            missing_optional+=("$cmd")
        fi
    done
    
    if [ ${#missing_optional[@]} -gt 0 ]; then
        VALIDATION_WARNINGS+=("Missing optional dependencies: ${missing_optional[*]}")
    else
        log_success "Optional dependencies OK"
    fi
}

# --- HARDWARE VALIDATION ---
validate_hardware() {
    log_info "Validating hardware..."
    
    # Check GPU
    local gpu_info
    gpu_info="$(get_gpu_info)"
    log_info "GPU detected: $gpu_info"
    
    # Check CPU
    local cpu_cores
    cpu_cores=$(get_cpu_cores)
    log_info "CPU cores: $cpu_cores"
    
    if [ "$cpu_cores" -lt 2 ]; then
        VALIDATION_WARNINGS+=("Low core count: $cpu_cores cores (recommended 4+)")
    fi
}

# --- DIRECTORY PERMISSIONS ---
validate_directories() {
    log_info "Validating directory permissions..."
    
    # Check if we can write to S1Bs1stem
    if [ ! -w "$S1B_ROOT" ]; then
        VALIDATION_ERRORS+=("Cannot write to S1Bs1stem directory: $S1B_ROOT")
    fi
    
    # Check if we can write to home
    if [ ! -w "$HOME" ]; then
        VALIDATION_ERRORS+=("Cannot write to home directory: $HOME")
    fi
    
    # Check if we can write to config
    if [ ! -w "$HOME/.config" ]; then
        VALIDATION_WARNINGS+=("Cannot write to .config directory")
    fi
}

# --- RUN ALL VALIDATIONS ---
run_all_validations() {
    log_info "=== S1Bs1stem Pre-flight Validation ==="
    echo ""
    
    validate_system
    validate_disk_space
    validate_network
    validate_core_dependencies
    validate_optional_dependencies
    validate_hardware
    validate_directories
    
    echo ""
    log_info "=== Validation Results ==="
    
    # Print errors
    if [ ${#VALIDATION_ERRORS[@]} -gt 0 ]; then
        echo ""
        log_error "CRITICAL ERRORS FOUND (${#VALIDATION_ERRORS[@]}):"
        for error in "${VALIDATION_ERRORS[@]}"; do
            echo "  ✗ $error"
        done
    fi
    
    # Print warnings
    if [ ${#VALIDATION_WARNINGS[@]} -gt 0 ]; then
        echo ""
        log_warn "WARNINGS FOUND (${#VALIDATION_WARNINGS[@]}):"
        for warning in "${VALIDATION_WARNINGS[@]}"; do
            echo "  ⚠ $warning"
        done
    fi
    
    # Exit with error code if critical errors found
    if [ ${#VALIDATION_ERRORS[@]} -gt 0 ]; then
        echo ""
        log_error "Pre-flight validation FAILED"
        return 1
    else
        echo ""
        log_success "Pre-flight validation PASSED"
        return 0
    fi
}

# --- MAIN EXECUTION ---
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_all_validations
fi

# Export functions for use in other scripts
export -f validate_system
export -f validate_disk_space
export -f validate_network
export -f validate_core_dependencies
export -f validate_optional_dependencies
export -f validate_hardware
export -f validate_directories
export -f run_all_validations
