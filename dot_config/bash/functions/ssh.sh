#!/bin/bash
# SSH Management Functions

# Function to check and start ssh-agent if needed
function ensure_ssh_agent() {
  # Check if ssh-agent is running by testing if we can list keys
  if ! ssh-add -l &>/dev/null; then
    # ssh-agent not running or not accessible, start it
    echo "Starting ssh-agent..."
    eval "$(ssh-agent -s)"

    # Verify it started successfully
    if ! ssh-add -l &>/dev/null; then
      echo "Error: Failed to start ssh-agent"
      return 1
    fi
    echo "ssh-agent started successfully"
  else
    echo "ssh-agent is already running"
  fi
  return 0
}

# Function to generate an SSH key pair
function generate_ssh_key() {
  # Ensure ssh-agent is running before proceeding
  if ! ensure_ssh_agent; then
    echo "Error: Cannot proceed without ssh-agent"
    return 1
  fi

  # Prompt for a custom string to append to the filename
  read -p "Enter a custom string to append to the key filename: " custom_string
  # Validate custom string isn't empty
  if [[ -z "$custom_string" ]]; then
    echo "Error: Custom string cannot be empty"
    return 1
  fi
  # Prompt for type of key to generate
  read -p "Enter the type of key to generate (ed25519, rsa, ecdsa): " key_type
  # Validate key type
  case "$key_type" in
  ed25519 | rsa | ecdsa) ;;
  *)
    echo "Error: Invalid key type. Must be ed25519, rsa, or ecdsa"
    return 1
    ;;
  esac
  # Define the key file names
  private_key="$HOME/.ssh/id_${key_type}_${custom_string}"
  public_key="$HOME/.ssh/id_${key_type}_${custom_string}.pub"
  # Check if key already exists
  if [[ -f "$private_key" ]]; then
    read -p "Key already exists. Overwrite? (y/N): " overwrite
    if [[ ! "$overwrite" =~ ^[Yy]$ ]]; then
      echo "Aborted"
      return 1
    fi
  fi
  # Create .ssh directory if it doesn't exist
  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"
  # Generate the key pair
  if ! ssh-keygen -t "$key_type" -f "$private_key" -N ""; then
    echo "Error: Failed to generate SSH key"
    return 1
  fi
  # Set appropriate permissions
  chmod 600 "$private_key"
  chmod 644 "$public_key"
  # Add key to SSH agent
  if ! ssh-add "$private_key"; then
    echo "Error: Failed to add key to SSH agent"
    return 1
  fi
  # Print the public key
  echo -e "\nPublic Key:"
  cat "$public_key"
  echo -e "\nKey pair generated successfully:"
  echo "Private key: $private_key"
  echo "Public key:  $public_key"
} 