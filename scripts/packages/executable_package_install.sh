#!/bin/bash

# Package Installation Script for Arch Linux
# Installs packages from exported lists

# Set directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_DIR="$SCRIPT_DIR/package-lists"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}===${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if file exists and is not empty
file_exists_and_not_empty() {
    [[ -f "$1" && -s "$1" ]]
}

# Function to install yay if not present
install_yay() {
    print_status "Installing yay AUR helper..."

    if ! command_exists git; then
        print_error "git is required to install yay. Installing git first..."
        sudo pacman -S --needed git
    fi

    # Create temporary directory
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"

    # Clone and install yay
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm

    # Cleanup
    cd "$SCRIPT_DIR"
    rm -rf "$TEMP_DIR"

    if command_exists yay; then
        print_success "yay installed successfully"
        return 0
    else
        print_error "Failed to install yay"
        return 1
    fi
}

# Main installation function
main() {
    print_status "Package Installation Script"
    echo "Package directory: $PACKAGE_DIR"
    echo

    # Check if package directory exists
    if [[ ! -d "$PACKAGE_DIR" ]]; then
        print_error "Package directory not found: $PACKAGE_DIR"
        print_error "Make sure you've run the export script first!"
        exit 1
    fi

    # Define package files
    PACMAN_FILE="$PACKAGE_DIR/pacman-explicit-latest.txt"
    AUR_FILE="$PACKAGE_DIR/aur-packages-latest.txt"

    # Check if pacman package file exists
    if ! file_exists_and_not_empty "$PACMAN_FILE"; then
        print_error "Pacman package list not found or empty: $PACMAN_FILE"
        exit 1
    fi

    # Update system first
    print_status "Updating system packages..."
    if sudo pacman -Syu; then
        print_success "System updated successfully"
    else
        print_warning "System update failed, continuing anyway..."
    fi
    echo

    # Install pacman packages
    PACMAN_COUNT=$(wc -l < "$PACMAN_FILE")
    print_status "Installing $PACMAN_COUNT pacman packages..."

    if sudo pacman -S --needed --noconfirm - < "$PACMAN_FILE"; then
        print_success "Pacman packages installed successfully"
    else
        print_error "Some pacman packages failed to install"
        print_warning "You may need to manually review and install failed packages"
    fi
    echo

    # Install AUR packages if file exists
    if file_exists_and_not_empty "$AUR_FILE"; then
        AUR_COUNT=$(wc -l < "$AUR_FILE")
        print_status "Found $AUR_COUNT AUR packages to install"

        # Check if yay is available
        if ! command_exists yay; then
            print_warning "yay AUR helper not found"
            echo "Would you like to install yay to continue with AUR packages? (y/n)"
            read -r response
            if [[ "$response" =~ ^[Yy]$ ]]; then
                if install_yay; then
                    print_success "Ready to install AUR packages"
                else
                    print_error "Failed to install yay, skipping AUR packages"
                    print_warning "You can install AUR packages manually later"
                    exit 1
                fi
            else
                print_warning "Skipping AUR packages"
                print_warning "To install them later, run: yay -S --needed - < $AUR_FILE"
                exit 0
            fi
        fi

        # Install AUR packages
        print_status "Installing AUR packages..."
        if yay -S --needed --noconfirm - < "$AUR_FILE"; then
            print_success "AUR packages installed successfully"
        else
            print_error "Some AUR packages failed to install"
            print_warning "You may need to manually review and install failed packages"
        fi
    else
        print_warning "No AUR packages found or file is empty"
        if [[ -f "$AUR_FILE" ]]; then
            print_warning "File exists but is empty: $AUR_FILE"
        else
            print_warning "File not found: $AUR_FILE"
        fi
    fi

    echo
    print_status "Installation Summary"
    echo "Pacman packages: $PACMAN_COUNT"
    if file_exists_and_not_empty "$AUR_FILE"; then
        echo "AUR packages: $AUR_COUNT"
    else
        echo "AUR packages: 0"
    fi
    echo
    print_success "Package installation completed!"

    # Show some useful post-installation commands
    echo
    print_status "Useful post-installation commands:"
    echo "  Check for orphaned packages: pacman -Qtdq"
    echo "  Clean package cache: pacman -Sc"
    echo "  Update all packages: yay -Syu"
}

# Handle script arguments
case "${1:-}" in
    --help|-h)
        echo "Package Installation Script"
        echo
        echo "Usage: $0 [options]"
        echo
        echo "Options:"
        echo "  --help, -h     Show this help message"
        echo "  --dry-run      Show what would be installed without installing"
        echo
        echo "This script looks for package lists in: $PACKAGE_DIR"
        echo "Make sure to run the export script first to generate the package lists."
        exit 0
        ;;
    --dry-run)
        print_status "Dry run mode - showing what would be installed"
        echo

        if file_exists_and_not_empty "$PACMAN_FILE"; then
            PACMAN_COUNT=$(wc -l < "$PACMAN_FILE")
            print_status "Would install $PACMAN_COUNT pacman packages:"
            head -10 "$PACMAN_FILE"
            if [[ $PACMAN_COUNT -gt 10 ]]; then
                echo "... and $((PACMAN_COUNT - 10)) more"
            fi
            echo
        fi

        if file_exists_and_not_empty "$AUR_FILE"; then
            AUR_COUNT=$(wc -l < "$AUR_FILE")
            print_status "Would install $AUR_COUNT AUR packages:"
            head -10 "$AUR_FILE"
            if [[ $AUR_COUNT -gt 10 ]]; then
                echo "... and $((AUR_COUNT - 10)) more"
            fi
        fi
        exit 0
        ;;
    "")
        # No arguments, run main function
        main
        ;;
    *)
        print_error "Unknown option: $1"
        echo "Use --help for usage information"
        exit 1
        ;;
esac
