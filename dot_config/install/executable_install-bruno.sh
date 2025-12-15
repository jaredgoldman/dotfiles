#!/bin/bash

set -e

echo "Installing Bruno HTTP Client..."

# Get the actual user (not root)
if [ -n "$SUDO_USER" ]; then
    ACTUAL_USER="$SUDO_USER"
else
    ACTUAL_USER="jg"
fi

if command -v yay &> /dev/null; then
    sudo -u "$ACTUAL_USER" yay -S --noconfirm bruno-bin
elif command -v paru &> /dev/null; then
    sudo -u "$ACTUAL_USER" paru -S --noconfirm bruno-bin
else
    echo "No AUR helper found. Installing yay first..."
    sudo pacman -S --needed --noconfirm git base-devel
    sudo -u "$ACTUAL_USER" git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
    cd /tmp/yay-bin
    sudo -u "$ACTUAL_USER" makepkg -si --noconfirm
    cd -
    sudo -u "$ACTUAL_USER" yay -S --noconfirm bruno-bin
fi

echo "Bruno installation complete!"
