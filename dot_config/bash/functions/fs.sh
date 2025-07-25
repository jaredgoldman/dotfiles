#!/bin/bash

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

# Function to get SSH config hosts
get_ssh_hosts() {
  if [[ -f ~/.ssh/config ]]; then
    grep -E "^Host\s" ~/.ssh/config | awk '{print $2}' | grep -v "\*"
  fi
}

# Function to handle file path completion
_rsync_completion() {
  local cur prev opts
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD - 1]}"

  case $COMP_CWORD in
  1)
    # Complete file paths for source
    COMPREPLY=($(compgen -f -- "$cur"))
    ;;
  2)
    # Complete SSH hostnames for destination
    local hosts=$(get_ssh_hosts)
    COMPREPLY=($(compgen -W "$hosts" -- "$cur"))
    ;;
  3)
    # Complete remote paths using SSH
    local ssh_host="${COMP_WORDS[2]}"
    if [[ -n "$ssh_host" && "$cur" == */* ]]; then
      # Extract directory part and filename part
      local remote_dir="${cur%/*}/"
      local filename="${cur##*/}"

      # Get remote directory listing via SSH
      local remote_files
      remote_files=$(ssh "$ssh_host" "ls -1d ${remote_dir}*/ ${remote_dir}* 2>/dev/null | sed 's|^|${remote_dir%/}/|' | sed 's|//|/|g'" 2>/dev/null)

      if [[ $? -eq 0 && -n "$remote_files" ]]; then
        COMPREPLY=($(compgen -W "$remote_files" -- "$cur"))
      else
        # Fallback to basic completion
        COMPREPLY=($(compgen -f -- "$cur"))
      fi
    else
      # For paths without / or when SSH fails, try to get home directory listing
      local remote_files
      remote_files=$(ssh "$ssh_host" "ls -1d */ * 2>/dev/null" 2>/dev/null | sed 's|^|~/|')

      if [[ $? -eq 0 && -n "$remote_files" ]]; then
        COMPREPLY=($(compgen -W "$remote_files" -- "$cur"))
      else
        # Ultimate fallback
        COMPREPLY=($(compgen -f -- "$cur"))
      fi
    fi
    ;;
  esac
}

# Register completion function
complete -F _rsync_completion "$(basename "$0")"

# Main script function
transfer_files() {
  if [[ $# -lt 2 ]]; then
    echo "Usage: transfer_files <local_file_path> <ssh_host> [remote_path]"
    echo ""
    echo "Available SSH hosts:"
    get_ssh_hosts | sed 's/^/  /'
    echo ""
    echo "Examples:"
    echo "  transfer_files /path/to/file.txt myserver"
    echo "  transfer_files /path/to/file.txt myserver /remote/path/"
    echo "  transfer_files /path/to/directory/ myserver /remote/destination/"
    return 1
  fi

  local_path="$1"
  ssh_host="$2"
  remote_path="${3:-~}" # Default to home directory if not specified

  # Check if local file/directory exists
  if [[ ! -e "$local_path" ]]; then
    echo "Error: Local path '$local_path' does not exist"
    return 1
  fi

  # Check if SSH host is in config
  if ! get_ssh_hosts | grep -q "^$ssh_host$"; then
    echo "Warning: '$ssh_host' not found in SSH config, but proceeding anyway..."
  fi

  # Build rsync command
  rsync_cmd="rsync -avz --progress"

  # Add trailing slash for directories if needed
  if [[ -d "$local_path" && "$local_path" != */ ]]; then
    local_path="$local_path/"
  fi

  # Execute rsync
  echo "Syncing '$local_path' to '$ssh_host:$remote_path'"
  echo "Running: $rsync_cmd \"$local_path\" \"$ssh_host:$remote_path\""
  echo ""

  $rsync_cmd "$local_path" "$ssh_host:$remote_path"

  if [[ $? -eq 0 ]]; then
    echo ""
    echo "✓ Transfer completed successfully"
  else
    echo ""
    echo "✗ Transfer failed"
    return 1
  fi
}
