#!/bin/bash
# Brightness Control Functions

## Function to get the display name dynamically
get_display_name() {
  xrandr --listmonitors | grep -Po '(?<=\s)\S*(?=\s\([0-9]+)' | head -n 1
}

## Function to set the brightness
brightness() {
  local display_name=$(get_display_name)
  if [ -n "$display_name" ]; then
    xrandr --output "$display_name" --brightness "$1"
    xrandr --output "eDP1" --brightness "$1"
  else
    echo "No display found."
  fi
}

# Usage example:
# brightness 0.8

