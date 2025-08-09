#!/bin/bash

# Simple password generator function
generate_password() {
  local length=${1:-12} # Default length is 12 if not specified

  # Character sets
  local chars="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*"

  # Generate password
  local password=""
  for ((i = 0; i < length; i++)); do
    password+="${chars:RANDOM%${#chars}:1}"
  done

  echo "$password"
}

# Alternative version using /dev/urandom (more secure)
generate_password_secure() {
  local length=${1:-12}
  tr -dc 'A-Za-z0-9!@#$%^&*' </dev/urandom | head -c "$length"
  echo
}
