#!/bin/sh

USER="jg"

# Remove AWS CLI v1 if installed
if pacman -Q aws-cli >/dev/null 2>&1; then
    echo "Removing AWS CLI v1..."
    pacman -R --noconfirm aws-cli
fi

# Install AWS CLI v2 from official repositories
pacman -S --noconfirm --needed aws-cli-v2

# Verify installation
if command -v aws >/dev/null 2>&1; then
    echo "AWS CLI v2 installed successfully"
    sudo -u $USER aws --version
else
    echo "Error: AWS CLI v2 installation failed"
    exit 1
fi
