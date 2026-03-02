#!/bin/sh

USER="jg"
HOME_DIR="/home/$USER"

# Install yarn via pacman
pacman -S --noconfirm --needed yarn

# Verify installation
sudo -u $USER yarn --version

echo ""
echo "Yarn installation complete!"
