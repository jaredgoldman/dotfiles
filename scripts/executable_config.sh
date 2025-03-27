#!/bin/bash

# Function to handle errors
error_exit() {
  echo "Error: $1"
  exit 1
}

# Function to install yay
install_yay() {
  local YAY_DIR="$HOME/yay"

  echo "Installing yay..."
  git clone https://aur.archlinux.org/yay.git "$YAY_DIR" || error_exit "Failed to clone yay repository"
  cd "$YAY_DIR"
  makepkg -si || error_exit "Failed to install yay"
  cd -
  rm -rf "$YAY_DIR"
}

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

# Pull and apply the latest chezmoi changes
echo "Pulling and applying the latest chezmoi changes..."
chezmoi update || error_exit "Failed to update chezmoi configuration"

# Install yay if not installed
if ! command -v yay &> /dev/null; then
  install_yay
else
  echo "yay is already installed."
fi

# Path to pkglist.txt
SCRIPT_DIR=$(dirname "$0")
PKGLIST="$SCRIPT_DIR/pkglist.txt"

# Split the package list into pacman and yay packages
PKGLIST_PACMAN="$HOME/pkglist_pacman.txt"
PKGLIST_YAY="$HOME/pkglist_yay.txt"

# Clear old lists
> "$PKGLIST_PACMAN"
> "$PKGLIST_YAY"

# Separate packages
while IFS= read -r pkg; do
  if pacman -Si "$pkg" &> /dev/null; then
    echo "$pkg" >> "$PKGLIST_PACMAN"
  else
    echo "$pkg" >> "$PKGLIST_YAY"
  fi
done < "$PKGLIST"

# Run the pacman installation as root
if [ -s "$PKGLIST_PACMAN" ]; then
  echo "Installing packages from $PKGLIST_PACMAN using pacman..."
  sudo pacman -S --needed --noconfirm - < "$PKGLIST_PACMAN" || echo "Some packages were not found in pacman, they might need to be installed with yay."
fi

# Install packages from pkglist_yay.txt using yay as non-root
if [ -s "$PKGLIST_YAY" ]; then
  echo "Installing packages from $PKGLIST_YAY using yay..."
  xargs -a "$PKGLIST_YAY" yay -S --needed --noconfirm || error_exit "Failed to install some packages using yay from $PKGLIST_YAY"
fi

# Update the package list after installations
source "$HOME/.bashrc"
update_pkglist
