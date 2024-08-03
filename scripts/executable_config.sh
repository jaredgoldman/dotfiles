#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

# Function to handle errors
error_exit() {
  echo "Error: $1"
  exit 1
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
  echo "Installing yay..."
  git clone https://aur.archlinux.org/yay.git /tmp/yay || error_exit "Failed to clone yay repository"
  cd /tmp/yay
  makepkg -si || error_exit "Failed to install yay"
  cd -
else
  echo "yay is already installed."
fi

# Download and install packages from ~/pkglist.txt using pacman and yay
if [ -f ~/pkglist.txt ]; then
  echo "Installing packages from ~/pkglist.txt using pacman..."
  pacman -S --needed - < ~/pkglist.txt || error_exit "Failed to install packages using pacman from pkglist.txt"

  echo "Installing packages from ~/pkglist.txt using yay..."
  yay -S --needed - < ~/pkglist.txt || error_exit "Failed to install packages using yay from pkglist.txt"
else
  error_exit "~/pkglist.txt not found"
fi

echo "Configuration sync completed successfully!"

