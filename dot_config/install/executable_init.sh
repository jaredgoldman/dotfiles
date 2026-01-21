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

    if [ ! -f "$SCRIPT_DIR/install-aws-cli.sh" ]; then
        log_error "install-aws-cli.sh not found in $SCRIPT_DIR"
        exit 1
    fi

    if [ ! -f "$SCRIPT_DIR/install-nosql-workbench.sh" ]; then
        log_error "install-nosql-workbench.sh not found in $SCRIPT_DIR"
        exit 1
    fi

    if [ ! -f "$SCRIPT_DIR/install-openaws-vpn-client.sh" ]; then
        log_error "install-openaws-vpn-client.sh not found in $SCRIPT_DIR"
        exit 1
    fi

    if [ ! -f "$SCRIPT_DIR/install-bruno.sh" ]; then
        log_error "install-bruno.sh not found in $SCRIPT_DIR"
        exit 1
    fi

    if [ ! -f "$SCRIPT_DIR/install-wget.sh" ]; then
        log_error "install-wget.sh not found in $SCRIPT_DIR"
        exit 1
    fi

    if [ ! -f "$SCRIPT_DIR/install-rsync.sh" ]; then
        log_error "install-rsync.sh not found in $SCRIPT_DIR"
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
    chmod +x "$SCRIPT_DIR/install-pnpm.sh" "$SCRIPT_DIR/install-claude-code.sh" \
             "$SCRIPT_DIR/install-aws-cli.sh" "$SCRIPT_DIR/install-nosql-workbench.sh" \
             "$SCRIPT_DIR/install-openaws-vpn-client.sh" "$SCRIPT_DIR/install-bruno.sh" \
             "$SCRIPT_DIR/install-wget.sh" "$SCRIPT_DIR/install-rsync.sh"
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

# Configure chezmoi
configure_chezmoi() {
    log_info "Configuring chezmoi..."

    # Check if chezmoi is installed
    if ! command -v chezmoi >/dev/null 2>&1; then
        log_warn "chezmoi not found, skipping configuration"
        return 0
    fi

    local github_user="jaredgoldman"
    local repo_name="dotfiles"
    local ssh_remote="git@github.com:${github_user}/${repo_name}.git"
    local user="jg"
    local chezmoi_dir="/home/${user}/.local/share/chezmoi"

    # Check if chezmoi is already initialized
    if [ -d "$chezmoi_dir/.git" ]; then
        log_info "Chezmoi already initialized, updating remote..."

        # Change to chezmoi directory and update remote
        if sudo -u "$user" git -C "$chezmoi_dir" remote get-url origin >/dev/null 2>&1; then
            sudo -u "$user" git -C "$chezmoi_dir" remote set-url origin "$ssh_remote"
            log_info "Updated chezmoi remote to $ssh_remote"
        else
            sudo -u "$user" git -C "$chezmoi_dir" remote add origin "$ssh_remote"
            log_info "Added chezmoi remote $ssh_remote"
        fi
    else
        log_info "Initializing chezmoi with SSH remote..."
        sudo -u "$user" chezmoi init "$ssh_remote"
        log_info "Initialized chezmoi with $ssh_remote"
    fi

    log_info "Chezmoi configuration completed"
}

# Main installation process
main() {
    log_info "Starting installation process..."
    echo

    validate_environment
    echo

    make_executable
    echo

    run_script "install-wget.sh"
    echo

    run_script "install-rsync.sh"
    echo

    run_script "install-pnpm.sh"
    echo

    run_script "install-claude-code.sh"
    echo

    configure_chezmoi
    echo

    run_script "install-aws-cli.sh"
    echo

    run_script "install-nosql-workbench.sh"
    echo

    run_script "install-slack.sh"
    echo

    run_script "install-openaws-vpn-client.sh"
    echo

    run_script "install-keychain.sh"
    echo

    run_script "install-bruno.sh"
    echo

    log_info "Installation completed successfully!"
}

main "$@"
