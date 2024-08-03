#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

# Function to handle errors
error_exit() {
  echo "Error: $1"
  exit 1
}

# Function to install yay as non-root user
install_yay() {
  local USER_HOME=$(eval echo ~"$SUDO_USER")
  local YAY_DIR="$USER_HOME/yay"

  echo "Installing yay..."
  sudo -u "$SUDO_USER" git clone https://aur.archlinux.org/yay.git "$YAY_DIR" || error_exit "Failed to clone yay repository"
  cd "$YAY_DIR"
  sudo -u "$SUDO_USER" makepkg -si || error_exit "Failed to install yay"
  cd -
  sudo -u "$SUDO_USER" rm -rf "$YAY_DIR"
}

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then
  error_exit "This script must be run as root. Please use sudo."
fi

# Check if chezmoi is installed
if ! command -v chezmoi &> /dev/null; then
  # Download and install chezmoi
  echo "Downloading chezmoi..."
  curl -sfL https://git.io/chezmoi | sh || error_exit "Failed to download chezmoi"
else
  echo "chezmoi is already installed."
fi

# Check if chezmoi is initialized
if [ ! -d "$HOME/.local/share/chezmoi" ]; then
  echo "Initializing chezmoi..."
  chezmoi init || error_exit "Failed to initialize chezmoi"
else
  echo "chezmoi is already initialized."
fi

# Apply chezmoi configuration
echo "Applying chezmoi configuration..."
chezmoi apply || error_exit "Failed to apply chezmoi configuration"

# Install yay if not installed
if ! command -v yay &> /dev/null; then
  install_yay
else
  echo "yay is already installed."
fi

# Install packages from pkglist.txt using pacman and yay
if [ -f "pkglist.txt" ]; then
  echo "Installing packages from pkglist.txt using pacman..."
  pacman -S --needed - < "pkglist.txt" || echo "Some packages were not found in pacman, trying with yay..."

  echo "Installing remaining packages from pkglist.txt using yay..."
  yay -S --needed - < "pkglist.txt" || error_exit "Failed to install some packages using yay from $PKGLIST"
else
  error_exit "pkglist.txt not found"
fi

echo "Configuration sync completed successfully!"

