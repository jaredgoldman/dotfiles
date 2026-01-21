#!/bin/sh

# Install wget
pacman -S --noconfirm --needed wget

# Verify installation
if command -v wget >/dev/null 2>&1; then
    echo ""
    echo "wget installation complete!"
    echo "Version: $(wget --version | head -n 1)"
    echo ""
else
    echo "ERROR: wget installation failed"
    exit 1
fi
