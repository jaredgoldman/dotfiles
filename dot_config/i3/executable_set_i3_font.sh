#!/bin/bash

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
        FONT_SIZE="10"  # Default font size for unknown resolutions
        ;;
esac

# Output the font configuration
echo "pango:Fira Code $FONT_SIZE"
