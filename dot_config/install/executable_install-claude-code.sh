#!/bin/sh
USER="jg"
BIN_DIR="/home/$USER/.local/bin"

sudo -u $USER env PATH="$BIN_DIR:$PATH" pnpm install -g @anthropic-ai/claude-code
