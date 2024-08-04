#!/bin/bash

# Get the screen resolution
SCREEN_RES=$(xrandr | grep '*' | awk '{print $1}')

# Set font size based on screen resolution
case "$SCREEN_RES" in
    "3840x2160")
        SCALE_FACTOR=1.25
        ;;
    "1920x1080")
        SCALE_FACTOR=1
        ;;
    *)
        SCALE_FACTOR=1
        ;;
esac

echo $SCALE_FACTOR
