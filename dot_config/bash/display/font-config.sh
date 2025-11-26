#!/bin/bash
# Display and Font Configuration

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

# Only proceed with display detection if we have displays and tools
if has_display_and_tools; then
  # Get the screen resolution of the primary display
  SCREEN_RES=$(xrandr | grep -w 'connected primary' | awk '{print $4}' | sed 's/+.*//')

  # If no primary display found, fallback to the first active resolution found
  if [ -z "$SCREEN_RES" ]; then
    SCREEN_RES=$(xrandr | grep '*' | awk '{print $1}')
  fi

  # Set font size based on screen resolution
  case "$SCREEN_RES" in
  "3840x2160")
    FONT_SIZE="16"
    ;;
  "2560x1440")
    FONT_SIZE="14"
    ;;
  "1920x1080")
    FONT_SIZE="12"
    ;;
  *)
    FONT_SIZE="10" # Default font size for unknown resolutions
    ;;
  esac
else
  # Headless environment - use sensible default
  FONT_SIZE="12"
fi

# Set the FONT environment variable
export FONT="pango:Fira Code $FONT_SIZE" 