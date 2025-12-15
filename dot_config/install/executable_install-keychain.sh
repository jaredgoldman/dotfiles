#!/bin/sh

USER="jg"
HOME_DIR="/home/$USER"
BIN_DIR="$HOME_DIR/.local/bin"

pacman -S --noconfirm --needed keychain
