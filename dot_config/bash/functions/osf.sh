#!/bin/bash
# OSF/Work-Specific Functions

# Mount remote filesystem
mount_remote_fs() {
  # Step 1: Prompt for SSH alias (with tab autocomplete)
  read -e -p "Enter SSH alias: " ssh_alias

  # Step 2: Create a directory with the SSH alias as its name if it doesn't exist
  local_dir="$HOME/dev/osf/$ssh_alias"
  if [ ! -d "$local_dir" ]; then
    mkdir -p "$local_dir"
    echo "Directory $local_dir created."
  fi

  # Step 3: Mount the remote filesystem
  remote_dir="/home/ec2-user"
  sshfs ec2-user@"$ssh_alias":"$remote_dir" "$local_dir"

  echo "Mounted $ssh_alias:$remote_dir to $local_dir"
}

## Function to tail AWS logs
function interactive_logs() {
  # Default values
  local aws_profile=""
  local osf_env=""
  local osf_endpoint=""
  local path=""

  # AWS Profile prompt
  while [ -z "$aws_profile" ]; do
    read -p "Enter AWS profile (default: prod): " aws_profile
    aws_profile=${aws_profile:-prod}
  done

  # OSF Environment prompt
  while [ -z "$osf_env" ]; do
    read -p "Enter OSF environment (default: production): " osf_env
    osf_env=${osf_env:-production}
  done

  # OSF Endpoint prompt
  while [ -z "$osf_endpoint" ]; do
    read -p "Enter OSF endpoint (default: ui): " osf_endpoint
    osf_endpoint=${osf_endpoint:-ui}
  done

  # Path prompt
  while [ -z "$path" ]; do
    read -p "Enter path (default: /ledgers/v2/unfinished): " path
    path=${path:-/ledgers/v2/unfinished}
  done

  # Execute the command
  echo "Executing: pnpm logs:tail --aws-profile $aws_profile --osf-env $osf_env --osf-endpoint $osf_endpoint $path"
  pnpm logs:tail --aws-profile "$aws_profile" --osf-env "$osf_env" --osf-endpoint "$osf_endpoint" "$path"
} 