#!/bin/sh

USER="jg"

# Check if yay is available
if command -v yay >/dev/null 2>&1; then
    sudo -u $USER yay -S --noconfirm --needed awsvpnclient
# Check if paru is available
elif command -v paru >/dev/null 2>&1; then
    sudo -u $USER paru -S --noconfirm --needed awsvpnclient
else
    echo "Error: No AUR helper (yay or paru) found. Please install one first."
    exit 1
fi

# Verify installation
if [ -f "/opt/awsvpnclient/AWS VPN Client" ]; then
    echo "AWS VPN Client installed successfully"
else
    echo "Error: AWS VPN Client installation failed"
    exit 1
fi

# Enable and start systemd-resolved if not already running
if ! systemctl is-active --quiet systemd-resolved.service; then
    echo "Enabling and starting systemd-resolved.service..."
    systemctl enable systemd-resolved.service
    systemctl start systemd-resolved.service
else
    echo "systemd-resolved.service is already running"
fi

# Enable and start awsvpnclient service
echo "Enabling and starting awsvpnclient.service..."
systemctl enable awsvpnclient.service
systemctl start awsvpnclient.service

# Verify services are running
if systemctl is-active --quiet awsvpnclient.service && systemctl is-active --quiet systemd-resolved.service; then
    echo "AWS VPN Client services configured successfully"
else
    echo "Warning: Some services may not be running properly"
    systemctl status awsvpnclient.service --no-pager
fi
