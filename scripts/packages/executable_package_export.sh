#!/bin/bash

# Package List Export Script for Arch Linux
# Exports pacman, yay, snap, and other software for comprehensive backup/restoration

# Set output directory (relative to script location)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="$SCRIPT_DIR/package-lists"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

echo "=== Comprehensive Package Export Script ==="
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

    # AUR packages only (redirect stderr to avoid warning messages)
    yay -Qqm 2>/dev/null > "$OUTPUT_DIR/aur-packages_$TIMESTAMP.txt"
    echo "✓ AUR packages: $OUTPUT_DIR/aur-packages_$TIMESTAMP.txt"

    # AUR packages with versions (redirect stderr to avoid warning messages)
    yay -Qm 2>/dev/null > "$OUTPUT_DIR/aur-packages-detailed_$TIMESTAMP.txt"
    echo "✓ AUR packages (detailed): $OUTPUT_DIR/aur-packages-detailed_$TIMESTAMP.txt"
else
    echo
    echo "⚠ yay not found - skipping AUR package export"
fi

# Snap packages skipped (removed per user request)

# Export Flatpak packages
echo
echo "Checking for Flatpak packages..."
if command_exists flatpak; then
    flatpak list --app --columns=application 2>/dev/null > "$OUTPUT_DIR/flatpak-packages_$TIMESTAMP.txt"
    if [[ -s "$OUTPUT_DIR/flatpak-packages_$TIMESTAMP.txt" ]]; then
        echo "✓ Flatpak packages: $OUTPUT_DIR/flatpak-packages_$TIMESTAMP.txt"
        flatpak list --app > "$OUTPUT_DIR/flatpak-packages-detailed_$TIMESTAMP.txt"
        echo "✓ Flatpak packages (detailed): $OUTPUT_DIR/flatpak-packages-detailed_$TIMESTAMP.txt"
    else
        echo "⚠ No flatpak packages found"
        rm "$OUTPUT_DIR/flatpak-packages_$TIMESTAMP.txt"
    fi
else
    echo "⚠ flatpak not found - skipping flatpak package export"
fi

# Export manual installations in /opt
echo
echo "Checking for manual installations..."
if [[ -d /opt && $(ls -A /opt 2>/dev/null) ]]; then
    ls -1 /opt > "$OUTPUT_DIR/opt-installations_$TIMESTAMP.txt"
    echo "✓ Manual installations in /opt: $OUTPUT_DIR/opt-installations_$TIMESTAMP.txt"
    ls -la /opt > "$OUTPUT_DIR/opt-installations-detailed_$TIMESTAMP.txt"
    echo "✓ Manual installations (detailed): $OUTPUT_DIR/opt-installations-detailed_$TIMESTAMP.txt"
else
    echo "⚠ No manual installations found in /opt"
fi

# Export user systemd services
echo
echo "Checking for user systemd services..."
if systemctl --user list-unit-files --state=enabled 2>/dev/null | grep -v "^UNIT FILE" | grep -v "^$" > "$OUTPUT_DIR/user-systemd-services_$TIMESTAMP.txt"; then
    if [[ -s "$OUTPUT_DIR/user-systemd-services_$TIMESTAMP.txt" ]]; then
        echo "✓ Enabled user systemd services: $OUTPUT_DIR/user-systemd-services_$TIMESTAMP.txt"
    else
        rm "$OUTPUT_DIR/user-systemd-services_$TIMESTAMP.txt"
        echo "⚠ No enabled user systemd services found"
    fi
else
    echo "⚠ Could not check user systemd services"
fi

# Export system systemd services (custom ones)
echo
echo "Checking for custom system services..."
systemctl list-unit-files --state=enabled --no-pager 2>/dev/null | grep -E "\.(service|timer)" | grep -v -E "^(systemd-|getty@|dbus|NetworkManager|bluetooth|cups|avahi|colord|accounts-daemon|udisks2|upower|polkit|gdm|lightdm)" > "$OUTPUT_DIR/system-services_$TIMESTAMP.txt" 2>/dev/null || true
if [[ -s "$OUTPUT_DIR/system-services_$TIMESTAMP.txt" ]]; then
    echo "✓ Custom system services: $OUTPUT_DIR/system-services_$TIMESTAMP.txt"
else
    rm "$OUTPUT_DIR/system-services_$TIMESTAMP.txt" 2>/dev/null || true
    echo "⚠ No custom system services found"
fi

# Create a comprehensive summary
echo
echo "Creating comprehensive summary..."
{
    echo "# Comprehensive Package List Export"
    echo "# Generated on: $(date)"
    echo "# System: $(uname -a)"
    echo
    echo "## Pacman Packages (Explicitly Installed)"
    echo "Total: $(wc -l < "$OUTPUT_DIR/pacman-explicit_$TIMESTAMP.txt")"
    echo "File: pacman-explicit_$TIMESTAMP.txt"
    echo "Restore with: sudo pacman -S --needed - < pacman-explicit_$TIMESTAMP.txt"
    echo
    if command_exists yay; then
        echo "## AUR Packages"
        echo "Total: $(wc -l < "$OUTPUT_DIR/aur-packages_$TIMESTAMP.txt")"
        echo "File: aur-packages_$TIMESTAMP.txt"
        echo "Restore with: yay -S --needed - < aur-packages_$TIMESTAMP.txt"
        echo
    fi
    if [[ -f "$OUTPUT_DIR/flatpak-packages_$TIMESTAMP.txt" ]]; then
        echo "## Flatpak Packages"
        echo "Total: $(wc -l < "$OUTPUT_DIR/flatpak-packages_$TIMESTAMP.txt")"
        echo "File: flatpak-packages_$TIMESTAMP.txt"
        echo "Restore with: while read pkg; do flatpak install -y \$pkg; done < flatpak-packages_$TIMESTAMP.txt"
        echo
    fi
    if [[ -f "$OUTPUT_DIR/opt-installations_$TIMESTAMP.txt" ]]; then
        echo "## Manual Installations (/opt)"
        echo "Total: $(wc -l < "$OUTPUT_DIR/opt-installations_$TIMESTAMP.txt")"
        echo "File: opt-installations_$TIMESTAMP.txt"
        echo "Note: These require manual installation/copying"
        echo
    fi
    if [[ -f "$OUTPUT_DIR/user-systemd-services_$TIMESTAMP.txt" ]]; then
        echo "## User Systemd Services"
        echo "Total: $(wc -l < "$OUTPUT_DIR/user-systemd-services_$TIMESTAMP.txt")"
        echo "File: user-systemd-services_$TIMESTAMP.txt"
        echo "Note: May require manual enabling after package installation"
        echo
    fi
    if [[ -f "$OUTPUT_DIR/system-services_$TIMESTAMP.txt" ]]; then
        echo "## Custom System Services"
        echo "File: system-services_$TIMESTAMP.txt"
        echo "Note: Review and manually enable as needed"
        echo
    fi
    echo "## All Dependencies (pacman-all)"
    echo "Total: $(wc -l < "$OUTPUT_DIR/pacman-all_$TIMESTAMP.txt")"
    echo "File: pacman-all_$TIMESTAMP.txt"
    echo "Note: Use only if explicit installation doesn't restore everything"
    echo
    echo "## Files Generated"
    echo "Core package files:"
    echo "- pacman-explicit_$TIMESTAMP.txt (primary restore file)"
    if command_exists yay; then
        echo "- aur-packages_$TIMESTAMP.txt (AUR packages)"
    fi
    if [[ -f "$OUTPUT_DIR/flatpak-packages_$TIMESTAMP.txt" ]]; then
        echo "- flatpak-packages_$TIMESTAMP.txt (Flatpak packages)"
    fi
    echo
    echo "Additional files:"
    echo "- pacman-all_$TIMESTAMP.txt (all packages including dependencies)"
    echo "- *-detailed_$TIMESTAMP.txt (versions and detailed info)"
    if [[ -f "$OUTPUT_DIR/opt-installations_$TIMESTAMP.txt" ]]; then
        echo "- opt-installations_$TIMESTAMP.txt (manual installations)"
    fi
    if [[ -f "$OUTPUT_DIR/user-systemd-services_$TIMESTAMP.txt" ]]; then
        echo "- user-systemd-services_$TIMESTAMP.txt (user services)"
    fi
    if [[ -f "$OUTPUT_DIR/system-services_$TIMESTAMP.txt" ]]; then
        echo "- system-services_$TIMESTAMP.txt (system services)"
    fi
} > "$OUTPUT_DIR/README_$TIMESTAMP.txt"

echo "✓ Comprehensive summary: $OUTPUT_DIR/README_$TIMESTAMP.txt"

# Create latest symlinks for easy access
echo
echo "Creating latest symlinks..."
ln -sf "pacman-explicit_$TIMESTAMP.txt" "$OUTPUT_DIR/pacman-explicit-latest.txt"
ln -sf "pacman-all_$TIMESTAMP.txt" "$OUTPUT_DIR/pacman-all-latest.txt"
if command_exists yay; then
    ln -sf "aur-packages_$TIMESTAMP.txt" "$OUTPUT_DIR/aur-packages-latest.txt"
fi
if [[ -f "$OUTPUT_DIR/flatpak-packages_$TIMESTAMP.txt" ]]; then
    ln -sf "flatpak-packages_$TIMESTAMP.txt" "$OUTPUT_DIR/flatpak-packages-latest.txt"
fi
if [[ -f "$OUTPUT_DIR/opt-installations_$TIMESTAMP.txt" ]]; then
    ln -sf "opt-installations_$TIMESTAMP.txt" "$OUTPUT_DIR/opt-installations-latest.txt"
fi
if [[ -f "$OUTPUT_DIR/user-systemd-services_$TIMESTAMP.txt" ]]; then
    ln -sf "user-systemd-services_$TIMESTAMP.txt" "$OUTPUT_DIR/user-systemd-services-latest.txt"
fi
if [[ -f "$OUTPUT_DIR/system-services_$TIMESTAMP.txt" ]]; then
    ln -sf "system-services_$TIMESTAMP.txt" "$OUTPUT_DIR/system-services-latest.txt"
fi
ln -sf "README_$TIMESTAMP.txt" "$OUTPUT_DIR/README-latest.txt"

echo "✓ Created symlinks for latest files"

# Display comprehensive summary
echo
echo "=== Comprehensive Export Complete ==="
echo "Pacman packages (explicit): $(wc -l < "$OUTPUT_DIR/pacman-explicit_$TIMESTAMP.txt")"
echo "Pacman packages (total): $(wc -l < "$OUTPUT_DIR/pacman-all_$TIMESTAMP.txt")"
if command_exists yay; then
    echo "AUR packages: $(wc -l < "$OUTPUT_DIR/aur-packages_$TIMESTAMP.txt")"
fi
if [[ -f "$OUTPUT_DIR/flatpak-packages_$TIMESTAMP.txt" ]]; then
    echo "Flatpak packages: $(wc -l < "$OUTPUT_DIR/flatpak-packages_$TIMESTAMP.txt")"
fi
if [[ -f "$OUTPUT_DIR/opt-installations_$TIMESTAMP.txt" ]]; then
    echo "Manual installations: $(wc -l < "$OUTPUT_DIR/opt-installations_$TIMESTAMP.txt")"
fi
echo
echo "To restore packages on a new system, see: $OUTPUT_DIR/README-latest.txt"
echo
echo "Files saved in: $OUTPUT_DIR"
