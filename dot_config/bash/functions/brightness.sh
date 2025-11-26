#!/bin/bash
# Brightness Control Functions

# Function to check if we have a display and required tools
has_display_and_tools() {
  # Check if DISPLAY variable is set (X11 session)
  [ -n "$DISPLAY" ] || return 1
  
  # Check if xrandr is available
  command -v xrandr >/dev/null 2>&1 || return 1
  
  # Check if xrandr can actually connect to display
  xrandr >/dev/null 2>&1 || return 1
  
  return 0
}

## Function to get the display name dynamically
get_display_name() {
  if has_display_and_tools; then
    xrandr --listmonitors | grep -Po '(?<=\s)\S*(?=\s\([0-9]+)' | head -n 1
  else
    return 1
  fi
}

## Function to set the brightness
brightness() {
  if ! has_display_and_tools; then
    echo "Error: No display or display tools available (headless environment?)"
    return 1
  fi

  local display_name=$(get_display_name)
  if [ -n "$display_name" ]; then
    xrandr --output "$display_name" --brightness "$1"
    xrandr --output "eDP1" --brightness "$1"
  else
    echo "No display found."
    return 1
  fi
}

# Usage example:
# brightness 0.8

