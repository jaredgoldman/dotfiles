#!/bin/bash
# Image Processing Functions

## Convert all HEIC files in a dir to PNG
function heictopng() {
  for file in *.heic; do
    heif-convert "$file" "${file%.heic}.png"
  done
}

## Optimize all PNGs into a single file
function optpngs() {
  # Prompt user before executing
  read -p "Are you sure you want to optimize these images? [y/n] " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    for file in *.png; do
      optipng -o7 "$file"
    done
  fi
} 