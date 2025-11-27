#!/bin/sh

USER="jg"

# Check if yay is available
if command -v yay >/dev/null 2>&1; then
    sudo -u $USER yay -S --noconfirm --needed slack-desktop
# Check if paru is available
elif command -v paru >/dev/null 2>&1; then
    sudo -u $USER paru -S --noconfirm --needed slack-desktop
else
    echo "Error: No AUR helper (yay or paru) found. Please install one first."
    exit 1
fi
