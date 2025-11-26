#!/bin/bash
# Bash Configuration Initialization
# This is the main entrypoint that loads all modular bash configuration

# Base directory for bash configuration
BASH_CONFIG_DIR="$HOME/.config/bash"

# Source display and font configuration
# source "$BASH_CONFIG_DIR/display/font-config.sh"

# Source aliases
source "$BASH_CONFIG_DIR/aliases/general.sh"

# Source all function files
# source "$BASH_CONFIG_DIR/functions/brightness.sh"
source "$BASH_CONFIG_DIR/functions/translations.sh"
source "$BASH_CONFIG_DIR/functions/git.sh"
source "$BASH_CONFIG_DIR/functions/ssh.sh"
source "$BASH_CONFIG_DIR/functions/images.sh"
source "$BASH_CONFIG_DIR/functions/fs.sh"
source "$BASH_CONFIG_DIR/functions/wireguard.sh"
source "$BASH_CONFIG_DIR/functions/pw.sh"
source "$BASH_CONFIG_DIR/functions/ports.sh"

# Source security configuration
source "$BASH_CONFIG_DIR/security/keychain.sh"

# Source environment variables
# source "$BASH_CONFIG_DIR/environment/variables.sh"
