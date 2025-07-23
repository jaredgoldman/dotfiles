#!/bin/bash
# General Aliases
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias gotosleep='xset dpms force off'

# Virtual python env
alias pyenv="source env/bin/activate"

# Networking
alias whichwanip="dig +short myip.opendns.com @resolver1.opendns.com"
alias showwifi="nmcli device wifi show-password" 