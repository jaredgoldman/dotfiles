setup_wireguard() {
  local address="$1"

  # Check if address parameter is provided
  if [ -z "$address" ]; then
    echo "Usage: setup_wireguard <address>"
    echo "Example: setup_wireguard 10.0.0.1/24"
    return 1
  fi

  # Install WireGuard
  sudo pacman -Sy wireguard-tools

  # Generate key pair
  wg genkey | sudo tee /etc/wireguard/private.key | wg pubkey | sudo tee /etc/wireguard/public.key

  # Set proper permissions
  sudo chmod 600 /etc/wireguard/private.key
  sudo chmod 644 /etc/wireguard/public.key

  # Create basic config file with parameterized address
  sudo tee /etc/wireguard/wg0.conf >/dev/null <<EOF
[Interface]
PrivateKey = $(sudo cat /etc/wireguard/private.key)
Address = $address
ListenPort = 51820

# Add [Peer] sections as needed
EOF

  # Set config file permissions
  sudo chmod 600 /etc/wireguard/wg0.conf

  echo "Setup complete! WireGuard configured with address: $address"
  echo "Edit /etc/wireguard/wg0.conf with neovim to add peers and configure networking."
  echo ""
  echo "Next steps:"
  echo "1. Edit config: sudo neovim /etc/wireguard/wg0.conf"
  echo "2. Enable IP forwarding (if server): echo 'net.ipv4.ip_forward=1' | sudo tee -a /etc/sysctl.conf && sudo sysctl -p"
  echo "3. Start interface: sudo wg-quick up wg0"
  echo "4. Enable at boot: sudo systemctl enable wg-quick@wg0"
}

openvpn() {
  sudo wg-quick up ~/.config/vpn/vpn.conf
}

closevpn() {
  sudo wg-quick down ~/.config/vpn/vpn.conf
}

