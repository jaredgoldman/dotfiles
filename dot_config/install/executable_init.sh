#!/bin/sh
set -e  # Exit on error
set -u  # Exit on undefined variable

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Logging functions
log_info() {
    printf "${GREEN}[INFO]${NC} %s\n" "$1"
}

log_warn() {
    printf "${YELLOW}[WARN]${NC} %s\n" "$1" >&2
}

log_error() {
    printf "${RED}[ERROR]${NC} %s\n" "$1" >&2
}

# Cleanup function
cleanup() {
    exit_code=$?
    if [ $exit_code -ne 0 ]; then
        log_error "Installation failed with exit code $exit_code"
    fi
    exit $exit_code
}

trap cleanup EXIT INT TERM

# Validation
validate_environment() {
    log_info "Validating environment..."

    # Check if running as root
    if [ "$(id -u)" -ne 0 ]; then
        log_error "This script must be run as root (use sudo)"
        exit 1
    fi

    # Check if required scripts exist
    if [ ! -f "$SCRIPT_DIR/install-pnpm.sh" ]; then
        log_error "install-pnpm.sh not found in $SCRIPT_DIR"
        exit 1
    fi

    if [ ! -f "$SCRIPT_DIR/install-claude-code.sh" ]; then
        log_error "install-claude-code.sh not found in $SCRIPT_DIR"
        exit 1
    fi

    # Check if pacman is available (Arch Linux)
    if ! command -v pacman >/dev/null 2>&1; then
        log_error "pacman not found. This script requires Arch Linux"
        exit 1
    fi

    log_info "Environment validation passed"
}

# Make scripts executable
make_executable() {
    log_info "Making installation scripts executable..."
    chmod +x "$SCRIPT_DIR/install-pnpm.sh" "$SCRIPT_DIR/install-claude-code.sh"
}

# Run installation script
run_script() {
    script_name="$1"
    script_path="$SCRIPT_DIR/$script_name"

    log_info "Running $script_name..."

    if ! "$script_path"; then
        log_error "$script_name failed"
        return 1
    fi

    log_info "$script_name completed successfully"
    return 0
}

# Main installation process
main() {
    log_info "Starting installation process..."
    echo

    validate_environment
    echo

    make_executable
    echo

    run_script "install-pnpm.sh"
    echo

    run_script "install-claude-code.sh"
    echo

    log_info "Installation completed successfully!"
}

main "$@"