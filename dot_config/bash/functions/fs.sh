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
