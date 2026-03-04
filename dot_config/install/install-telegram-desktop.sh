#!/bin/sh

# Install telegram-desktop
pacman -S --noconfirm --needed telegram-desktop

# Verify installation
if command -v telegram-desktop >/dev/null 2>&1; then
    echo ""
    echo "telegram-desktop installation complete!"
    echo ""
else
    echo "ERROR: telegram-desktop installation failed"
    exit 1
fi
