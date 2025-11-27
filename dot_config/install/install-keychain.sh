#!/bin/sh

USER="jg"
HOME_DIR="/home/$USER"
BIN_DIR="$HOME_DIR/.local/bin"

sudo -u USER env PATH="$BIN_DIR:$PATH" pacman -S keychain
