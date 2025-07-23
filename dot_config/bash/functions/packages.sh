#!/bin/bash
# Package Management Functions

# Function to update pkglist.txt
update_pkglist() {
  local PKGLIST="$HOME/scripts/pkglist.txt"
  local PKGLIST_PACMAN="$HOME/scripts/pkglist_pacman.txt"
  local PKGLIST_YAY="$HOME/scripts/pkglist_yay.txt"

  echo "Updating package list..."

  # List explicitly installed packages (excluding dependencies)
  if ! pacman -Qqe >"$PKGLIST_PACMAN"; then
    echo "Failed to list pacman packages"
    return 1
  fi

  # List explicitly installed AUR packages (excluding dependencies)
  if ! yay -Qqe >"$PKGLIST_YAY"; then
    echo "Failed to list AUR packages"
    return 1
  fi

  # Combine both lists, remove duplicates, and save to pkglist.txt
  if ! cat "$PKGLIST_PACMAN" "$PKGLIST_YAY" | sort -u >"$PKGLIST"; then
    echo "Failed to combine package lists"
    return 1
  fi

  # Clean up temporary files
  if ! rm "$PKGLIST_PACMAN" "$PKGLIST_YAY"; then
    echo "Failed to remove temporary files"
    return 1
  fi

  echo "Package list updated successfully!"
}

# Optionally call the function when sourcing .bashrc
# update_pkglist 