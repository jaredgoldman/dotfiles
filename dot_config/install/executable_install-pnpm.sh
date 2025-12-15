#!/bin/sh

USER="jg"
HOME_DIR="/home/$USER"
BIN_DIR="$HOME_DIR/.local/bin"
SHELL_CONFIG="$HOME_DIR/.bashrc"  # Ensure you're editing the right file

# Install pnpm
pacman -S --noconfirm --needed pnpm

# Ensure the directory exists
mkdir -p "$BIN_DIR"
chown -R $USER:$USER "$HOME_DIR/.local"

# Configure pnpm global bin
sudo -u $USER pnpm config set global-bin-dir "$BIN_DIR"

# Add /home/jg/.local/bin to the PATH in the user's shell config
if [ -f "$SHELL_CONFIG" ]; then
  # Check if the line already exists, if not, add it
  grep -qxF 'export PATH="$HOME/.local/bin:$PATH"' "$SHELL_CONFIG" || echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$SHELL_CONFIG"
fi

# Install globally with explicit PATH (sudo resets PATH otherwise)
sudo -u $USER env PATH="$BIN_DIR:$PATH" pnpm install -g @anthropic-ai/claude-code

# Verify installation
sudo -u $USER env PATH="$BIN_DIR:$PATH" pnpm bin -g

echo ""
echo "Installation complete!"
echo ""
echo "To use pnpm/claude in this terminal, run:"
echo "  source ~/.bashrc"
echo ""
echo "Or open a new terminal window."

