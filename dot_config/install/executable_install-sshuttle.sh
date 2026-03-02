#!/bin/sh

# Install sshuttle
pacman -S --noconfirm --needed sshuttle

# Verify installation
if command -v sshuttle >/dev/null 2>&1; then
    echo ""
    echo "sshuttle installation complete!"
    echo "Version: $(sshuttle --version)"
    echo ""
else
    echo "ERROR: sshuttle installation failed"
    exit 1
fi
