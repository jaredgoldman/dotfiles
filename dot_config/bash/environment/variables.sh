#!/bin/bash
# Environment Variables and PATH Configuration

export NVM_DIR="$HOME/.nvm"
export PNPM_HOME="$HOME/.local/share/pnpm"
export HISTSIZE=-1
export HISTFILESIZE=-1
export EDITOR="nvim"
export PATH="/usr/sbin:$PATH"

# Load NVM and add to PATH
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

# PNPM configuration
case ":$PATH:" in
*":$PNPM_HOME:"*) ;;
*) export PATH="$PNPM_HOME:$PATH" ;;
esac

