#!/bin/sh

# Install python-openpyxl
pacman -S --noconfirm --needed python-openpyxl

# Verify installation
if python -c "import openpyxl" >/dev/null 2>&1; then
    echo ""
    echo "python-openpyxl installation complete!"
    echo "Version: $(python -c 'import openpyxl; print(openpyxl.__version__)')"
    echo ""
else
    echo "ERROR: python-openpyxl installation failed"
    exit 1
fi
