#!/bin/bash

# Package List Export Script for Arch Linux
# Exports pacman and yay package lists for backup/restoration

# Set output directory (relative to script location)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="$SCRIPT_DIR/package-lists"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

echo "=== Package List Export Script ==="
echo "Output directory: $OUTPUT_DIR"
echo "Timestamp: $TIMESTAMP"
echo

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Export pacman packages
echo "Exporting pacman packages..."

# Explicitly installed packages (recommended for restoration)
pacman -Qqe > "$OUTPUT_DIR/pacman-explicit_$TIMESTAMP.txt"
echo "✓ Explicitly installed packages: $OUTPUT_DIR/pacman-explicit_$TIMESTAMP.txt"

# All installed packages
pacman -Qq > "$OUTPUT_DIR/pacman-all_$TIMESTAMP.txt"
echo "✓ All installed packages: $OUTPUT_DIR/pacman-all_$TIMESTAMP.txt"

# Detailed package info with versions
pacman -Qe > "$OUTPUT_DIR/pacman-explicit-detailed_$TIMESTAMP.txt"
echo "✓ Detailed package list: $OUTPUT_DIR/pacman-explicit-detailed_$TIMESTAMP.txt"

# Export AUR packages if yay is available
if command_exists yay; then
    echo
    echo "Exporting AUR packages..."

    # AUR packages only
    yay -Qqm > "$OUTPUT_DIR/aur-packages_$TIMESTAMP.txt"
    echo "✓ AUR packages: $OUTPUT_DIR/aur-packages_$TIMESTAMP.txt"

    # AUR packages with versions
    yay -Qm > "$OUTPUT_DIR/aur-packages-detailed_$TIMESTAMP.txt"
    echo "✓ AUR packages (detailed): $OUTPUT_DIR/aur-packages-detailed_$TIMESTAMP.txt"
else
    echo
    echo "⚠ yay not found - skipping AUR package export"
fi

# Create a combined summary
echo
echo "Creating package summary..."
{
    echo "# Package List Export"
    echo "# Generated on: $(date)"
    echo "# System: $(uname -a)"
    echo
    echo "## Pacman Packages (Explicitly Installed)"
    echo "Total: $(wc -l < "$OUTPUT_DIR/pacman-explicit_$TIMESTAMP.txt")"
    echo
    if command_exists yay; then
        echo "## AUR Packages"
        echo "Total: $(wc -l < "$OUTPUT_DIR/aur-packages_$TIMESTAMP.txt")"
        echo
    fi
    echo "## Files Generated"
    echo "- pacman-explicit_$TIMESTAMP.txt (for restoration with: pacman -S --needed - < file)"
    echo "- pacman-all_$TIMESTAMP.txt (complete package list)"
    echo "- pacman-explicit-detailed_$TIMESTAMP.txt (with versions)"
    if command_exists yay; then
        echo "- aur-packages_$TIMESTAMP.txt (for restoration with: yay -S --needed - < file)"
        echo "- aur-packages-detailed_$TIMESTAMP.txt (with versions)"
    fi
} > "$OUTPUT_DIR/README_$TIMESTAMP.txt"

echo "✓ Summary: $OUTPUT_DIR/README_$TIMESTAMP.txt"

# Create latest symlinks for easy access
echo
echo "Creating latest symlinks..."
ln -sf "pacman-explicit_$TIMESTAMP.txt" "$OUTPUT_DIR/pacman-explicit-latest.txt"
ln -sf "pacman-all_$TIMESTAMP.txt" "$OUTPUT_DIR/pacman-all-latest.txt"
if command_exists yay; then
    ln -sf "aur-packages_$TIMESTAMP.txt" "$OUTPUT_DIR/aur-packages-latest.txt"
fi
ln -sf "README_$TIMESTAMP.txt" "$OUTPUT_DIR/README-latest.txt"

echo "✓ Created symlinks for latest files"

# Display summary
echo
echo "=== Export Complete ==="
echo "Pacman packages (explicit): $(wc -l < "$OUTPUT_DIR/pacman-explicit_$TIMESTAMP.txt")"
echo "Pacman packages (total): $(wc -l < "$OUTPUT_DIR/pacman-all_$TIMESTAMP.txt")"
if command_exists yay; then
    echo "AUR packages: $(wc -l < "$OUTPUT_DIR/aur-packages_$TIMESTAMP.txt")"
fi
echo
echo "To restore packages on a new system:"
echo "  sudo pacman -S --needed - < $OUTPUT_DIR/pacman-explicit-latest.txt"
if command_exists yay; then
    echo "  yay -S --needed - < $OUTPUT_DIR/aur-packages-latest.txt"
fi
echo
echo "Files saved in: $OUTPUT_DIR"
