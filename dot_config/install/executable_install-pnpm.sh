#!/bin/sh

USER="jg"
HOME_DIR="/home/$USER"
BIN_DIR="$HOME_DIR/.local/bin"

# Install pnpm
pacman -S --noconfirm --needed pnpm

# Ensure directory exists
mkdir -p "$BIN_DIR"
chown -R $USER:$USER "$HOME_DIR/.local"

# Configure pnpm global bin
sudo -u $USER pnpm config set global-bin-dir "$BIN_DIR"

# Now test using explicit PATH (sudo resets PATH otherwise)
sudo -u $USER env PATH="$BIN_DIR:$PATH" pnpm bin -g

