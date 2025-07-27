#!/bin/bash

# Comprehensive Package Installation Script for Arch Linux
# Installs packages from exported lists including pacman, AUR, snap, and flatpak

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

# Function to install snap if not present
install_snap() {
    print_status "Installing snapd..."
    
    if sudo pacman -S --needed --noconfirm snapd; then
        print_status "Enabling snapd services..."
        sudo systemctl enable --now snapd.socket
        sudo systemctl enable --now snapd.apparmor.service
        
        # Create symlink for classic snaps
        if [[ ! -L /snap ]]; then
            sudo ln -s /var/lib/snapd/snap /snap
        fi
        
        print_success "snapd installed and configured"
        print_warning "You may need to logout/login or restart for snap to work properly"
        return 0
    else
        print_error "Failed to install snapd"
        return 1
    fi
}

# Function to install flatpak if not present
install_flatpak() {
    print_status "Installing flatpak..."
    
    if sudo pacman -S --needed --noconfirm flatpak; then
        print_status "Adding Flathub repository..."
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        print_success "flatpak installed and configured"
        return 0
    else
        print_error "Failed to install flatpak"
        return 1
    fi
}

# Main installation function
main() {
    print_status "Comprehensive Package Installation Script"
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
    SNAP_FILE="$PACKAGE_DIR/snap-packages-latest.txt"
    FLATPAK_FILE="$PACKAGE_DIR/flatpak-packages-latest.txt"
    OPT_FILE="$PACKAGE_DIR/opt-installations-latest.txt"
    USER_SERVICES_FILE="$PACKAGE_DIR/user-systemd-services-latest.txt"

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
                fi
            else
                print_warning "Skipping AUR packages"
                print_warning "To install them later, run: yay -S --needed - < $AUR_FILE"
            fi
        fi

        # Install AUR packages if yay is available
        if command_exists yay; then
            print_status "Installing AUR packages..."
            if yay -S --needed --noconfirm - < "$AUR_FILE"; then
                print_success "AUR packages installed successfully"
            else
                print_error "Some AUR packages failed to install"
                print_warning "You may need to manually review and install failed packages"
            fi
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

    # Install Snap packages if file exists
    if file_exists_and_not_empty "$SNAP_FILE"; then
        SNAP_COUNT=$(wc -l < "$SNAP_FILE")
        print_status "Found $SNAP_COUNT snap packages to install"

        # Check if snap is available
        if ! command_exists snap; then
            print_warning "snapd not found"
            echo "Would you like to install snapd to continue with snap packages? (y/n)"
            read -r response
            if [[ "$response" =~ ^[Yy]$ ]]; then
                if install_snap; then
                    print_success "Ready to install snap packages"
                else
                    print_error "Failed to install snapd, skipping snap packages"
                    print_warning "You can install snap packages manually later"
                fi
            else
                print_warning "Skipping snap packages"
                print_warning "To install them later, install snapd and run: while read pkg; do sudo snap install \$pkg; done < $SNAP_FILE"
            fi
        fi

        # Install snap packages if snap is available
        if command_exists snap; then
            print_status "Installing snap packages..."
            failed_snaps=()
            while IFS= read -r package; do
                [[ -z "$package" ]] && continue
                print_status "Installing snap: $package"
                if sudo snap install "$package"; then
                    print_success "Installed: $package"
                else
                    print_error "Failed to install: $package"
                    failed_snaps+=("$package")
                fi
            done < "$SNAP_FILE"

            if [[ ${#failed_snaps[@]} -eq 0 ]]; then
                print_success "All snap packages installed successfully"
            else
                print_warning "Failed to install ${#failed_snaps[@]} snap packages:"
                printf ' - %s\n' "${failed_snaps[@]}"
            fi
        fi
    else
        print_warning "No snap packages found"
    fi
    echo

    # Install Flatpak packages if file exists
    if file_exists_and_not_empty "$FLATPAK_FILE"; then
        FLATPAK_COUNT=$(wc -l < "$FLATPAK_FILE")
        print_status "Found $FLATPAK_COUNT flatpak packages to install"

        # Check if flatpak is available
        if ! command_exists flatpak; then
            print_warning "flatpak not found"
            echo "Would you like to install flatpak to continue with flatpak packages? (y/n)"
            read -r response
            if [[ "$response" =~ ^[Yy]$ ]]; then
                if install_flatpak; then
                    print_success "Ready to install flatpak packages"
                else
                    print_error "Failed to install flatpak, skipping flatpak packages"
                    print_warning "You can install flatpak packages manually later"
                fi
            else
                print_warning "Skipping flatpak packages"
                print_warning "To install them later, install flatpak and run: while read pkg; do flatpak install -y \$pkg; done < $FLATPAK_FILE"
            fi
        fi

        # Install flatpak packages if flatpak is available
        if command_exists flatpak; then
            print_status "Installing flatpak packages..."
            failed_flatpaks=()
            while IFS= read -r package; do
                [[ -z "$package" ]] && continue
                print_status "Installing flatpak: $package"
                if flatpak install -y "$package"; then
                    print_success "Installed: $package"
                else
                    print_error "Failed to install: $package"
                    failed_flatpaks+=("$package")
                fi
            done < "$FLATPAK_FILE"

            if [[ ${#failed_flatpaks[@]} -eq 0 ]]; then
                print_success "All flatpak packages installed successfully"
            else
                print_warning "Failed to install ${#failed_flatpaks[@]} flatpak packages:"
                printf ' - %s\n' "${failed_flatpaks[@]}"
            fi
        fi
    else
        print_warning "No flatpak packages found"
    fi
    echo

    # Show manual installations
    if file_exists_and_not_empty "$OPT_FILE"; then
        OPT_COUNT=$(wc -l < "$OPT_FILE")
        print_warning "Found $OPT_COUNT manual installations in /opt that require attention:"
        echo
        while IFS= read -r installation; do
            echo "  - $installation"
        done < "$OPT_FILE"
        echo
        print_warning "These need to be manually installed or copied from your backup"
        print_warning "Check the detailed file: ${OPT_FILE/latest/detailed}"
    fi
    echo

    # Show user systemd services
    if file_exists_and_not_empty "$USER_SERVICES_FILE"; then
        print_warning "Found user systemd services that may need to be enabled:"
        echo
        while IFS= read -r service; do
            service_name=$(echo "$service" | awk '{print $1}')
            echo "  - $service_name"
        done < "$USER_SERVICES_FILE"
        echo
        print_warning "After installing packages, you may need to enable these services:"
        print_warning "Example: systemctl --user enable <service-name>"
    fi

    # Installation summary
    echo
    print_status "Installation Summary"
    echo "Pacman packages: $PACMAN_COUNT"
    if file_exists_and_not_empty "$AUR_FILE"; then
        echo "AUR packages: $(wc -l < "$AUR_FILE")"
    else
        echo "AUR packages: 0"
    fi
    if file_exists_and_not_empty "$SNAP_FILE"; then
        echo "Snap packages: $(wc -l < "$SNAP_FILE")"
    else
        echo "Snap packages: 0"
    fi
    if file_exists_and_not_empty "$FLATPAK_FILE"; then
        echo "Flatpak packages: $(wc -l < "$FLATPAK_FILE")"
    else
        echo "Flatpak packages: 0"
    fi
    if file_exists_and_not_empty "$OPT_FILE"; then
        echo "Manual installations: $(wc -l < "$OPT_FILE") (require manual setup)"
    else
        echo "Manual installations: 0"
    fi
    echo
    print_success "Package installation completed!"

    # Show some useful post-installation commands
    echo
    print_status "Useful post-installation commands:"
    echo "  Check for orphaned packages: pacman -Qtdq"
    echo "  Clean package cache: pacman -Sc"
    if command_exists yay; then
        echo "  Update all packages: yay -Syu"
    fi
    if command_exists snap; then
        echo "  Update snap packages: sudo snap refresh"
    fi
    if command_exists flatpak; then
        echo "  Update flatpak packages: flatpak update"
    fi
    echo
    print_status "Next steps:"
    echo "  1. Review and manually install /opt applications if needed"
    echo "  2. Enable user systemd services if required"
    echo "  3. Check application-specific configurations"
    echo "  4. Reboot to ensure all services start properly"
}

# Handle script arguments
case "${1:-}" in
    --help|-h)
        echo "Comprehensive Package Installation Script"
        echo
        echo "Usage: $0 [options]"
        echo
        echo "Options:"
        echo "  --help, -h     Show this help message"
        echo "  --dry-run      Show what would be installed without installing"
        echo
        echo "This script looks for package lists in: $PACKAGE_DIR"
        echo "Supported package managers: pacman, yay (AUR), snap, flatpak"
        echo "Make sure to run the export script first to generate the package lists."
        exit 0
        ;;
    --dry-run)
        print_status "Dry run mode - showing what would be installed"
        echo

        PACMAN_FILE="$PACKAGE_DIR/pacman-explicit-latest.txt"
        AUR_FILE="$PACKAGE_DIR/aur-packages-latest.txt"
        SNAP_FILE="$PACKAGE_DIR/snap-packages-latest.txt"
        FLATPAK_FILE="$PACKAGE_DIR/flatpak-packages-latest.txt"
        OPT_FILE="$PACKAGE_DIR/opt-installations-latest.txt"

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
            echo
        fi

        if file_exists_and_not_empty "$SNAP_FILE"; then
            SNAP_COUNT=$(wc -l < "$SNAP_FILE")
            print_status "Would install $SNAP_COUNT snap packages:"
            head -10 "$SNAP_FILE"
            if [[ $SNAP_COUNT -gt 10 ]]; then
                echo "... and $((SNAP_COUNT - 10)) more"
            fi
            echo
        fi

        if file_exists_and_not_empty "$FLATPAK_FILE"; then
            FLATPAK_COUNT=$(wc -l < "$FLATPAK_FILE")
            print_status "Would install $FLATPAK_COUNT flatpak packages:"
            head -10 "$FLATPAK_FILE"
            if [[ $FLATPAK_COUNT -gt 10 ]]; then
                echo "... and $((FLATPAK_COUNT - 10)) more"
            fi
            echo
        fi

        if file_exists_and_not_empty "$OPT_FILE"; then
            OPT_COUNT=$(wc -l < "$OPT_FILE")
            print_warning "Would require manual installation of $OPT_COUNT items in /opt:"
            head -5 "$OPT_FILE"
            if [[ $OPT_COUNT -gt 5 ]]; then
                echo "... and $((OPT_COUNT - 5)) more"
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
