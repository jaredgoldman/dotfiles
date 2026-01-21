#!/bin/sh

# Install rsync
pacman -S --noconfirm --needed rsync

# Verify installation
if command -v rsync >/dev/null 2>&1; then
    echo ""
    echo "rsync installation complete!"
    echo "Version: $(rsync --version | head -n 1)"
    echo ""
else
    echo "ERROR: rsync installation failed"
    exit 1
fi
