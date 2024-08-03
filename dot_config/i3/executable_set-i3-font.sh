#!/bin/bash

# Get the screen resolution
SCREEN_RES=$(xrandr | grep '*' | awk '{print $1}')

# Set font size based on screen resolution
case "$SCREEN_RES" in
    "3840x2160")
        FONT_SIZE="14"
        ;;
    "1920x1080")
        FONT_SIZE="10"
        ;;
    *)
        FONT_SIZE="10"
        ;;
esac

echo "font pango:Fira Code $FONT_SIZE"
