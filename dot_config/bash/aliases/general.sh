#!/bin/bash
# General Aliases
alias ls='ls --color=auto'
alias grep='grep --color=auto'

# Display sleep function (replaces direct xset alias for headless compatibility)
gotosleep() {
  # Check if we have display and xset available
  if [ -n "$DISPLAY" ] && command -v xset >/dev/null 2>&1 && xset q >/dev/null 2>&1; then
    xset dpms force off
  else
    echo "Error: No display or xset available (headless environment?)"
    return 1
  fi
}

# Virtual python env
alias pyenv="source env/bin/activate"

# Networking
alias whichwanip="dig +short myip.opendns.com @resolver1.opendns.com"
alias showwifi="nmcli device wifi show-password"

# Git
alias gs="git status"
alias gd="git diff"
alias gc="git commit"
alias gb="git branch"
alias gp="git push"
alias ga="git add"
alias gr="git remote"
alias gl="git log"
alias gll="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias gcp="git cherry-pick"
