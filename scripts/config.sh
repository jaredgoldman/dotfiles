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

# Download and install chezmoi
echo "Downloading chezmoi..."
curl -sfL https://git.io/chezmoi | sh || error_exit "Failed to download chezmoi"

# Initialize chezmoi
echo "Initializing chezmoi..."
./bin/chezmoi init || error_exit "Failed to initialize chezmoi"

# Apply chezmoi configuration
echo "Applying chezmoi configuration..."
./bin/chezmoi apply || error_exit "Failed to apply chezmoi configuration"

# Install packages from pkglist.txt
if [ -f pkglist.txt ]; then
  echo "Installing packages from pkglist.txt..."
  pacman -S --needed - < pkglist.txt || error_exit "Failed to install packages from pkglist.txt"
else
  error_exit "pkglist.txt not found"
fi

echo "Configuration sync completed successfully!"

