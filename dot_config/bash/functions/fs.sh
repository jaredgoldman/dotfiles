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
      remote_files=$(ssh "$ssh_host" "ls -1d \"${remote_dir}\"*/ \"${remote_dir}\"* 2>/dev/null" 2>/dev/null | sed "s|^|${remote_dir%/}/|" | sed 's|//|/|g')

      if [[ $? -eq 0 && -n "$remote_files" ]]; then
        COMPREPLY=($(compgen -W "$remote_files" -- "$cur"))
      else
        # Fallback to basic completion
        COMPREPLY=($(compgen -f -- "$cur"))
      fi
    else
      # For paths without / or when SSH fails, try to get home directory listing
      local remote_files
      remote_files=$(ssh "$ssh_host" "ls -1d */ * 2>/dev/null" 2>/dev/null)

      if [[ $? -eq 0 && -n "$remote_files" ]]; then
        # Add ~/ prefix to each file/directory
        local prefixed_files=""
        while IFS= read -r line; do
          [[ -n "$line" ]] && prefixed_files="$prefixed_files ~/$line"
        done <<< "$remote_files"
        COMPREPLY=($(compgen -W "$prefixed_files" -- "$cur"))
      else
        # Ultimate fallback
        COMPREPLY=($(compgen -f -- "$cur"))
      fi
    fi
    ;;
  esac
}

# Register completion function
complete -F _rsync_completion transfer_files

# Main script function
transfer_files() {
  if [[ $# -lt 2 ]]; then
    echo "Usage: transfer_files <local_file_path>... <ssh_host> [remote_path]"
    echo ""
    echo "Available SSH hosts:"
    get_ssh_hosts | sed 's/^/  /'
    echo ""
    echo "Examples:"
    echo "  transfer_files /path/to/file.txt myserver"
    echo "  transfer_files /path/to/file.txt myserver /remote/path/"
    echo "  transfer_files /path/to/directory/ myserver /remote/destination/"
    echo "  transfer_files ~/Videos/* myserver /remote/videos/"
    echo "  transfer_files file1.txt file2.txt myserver"
    return 1
  fi

  # Parse arguments: all but last 1-2 are local paths
  local args=("$@")
  local num_args=$#
  
  # Determine if last argument is remote path or ssh host
  local ssh_host
  local remote_path="~"  # Default to home directory
  local local_paths=()
  
  if [[ $num_args -eq 2 ]]; then
    # Only 2 args: local_path ssh_host
    local_paths=("${args[0]}")
    ssh_host="${args[1]}"
  else
    # 3+ args: local_path(s)... ssh_host [remote_path]
    # Check if last arg looks like a path (contains / or starts with ~)
    local last_arg="${args[$((num_args-1))]}"
    if [[ "$last_arg" == */* ]] || [[ "$last_arg" == ~* ]]; then
      # Last arg is remote path
      ssh_host="${args[$((num_args-2))]}"
      remote_path="$last_arg"
      local_paths=("${args[@]:0:$((num_args-2))}")
    else
      # Last arg is ssh host
      ssh_host="$last_arg"
      local_paths=("${args[@]:0:$((num_args-1))}")
    fi
  fi

  # Validate local paths
  for local_path in "${local_paths[@]}"; do
    if [[ ! -e "$local_path" ]]; then
      echo "Error: Local path '$local_path' does not exist"
      return 1
    fi
  done

  # Check if SSH host is in config
  if ! get_ssh_hosts | grep -q "^$ssh_host$"; then
    echo "Warning: '$ssh_host' not found in SSH config, but proceeding anyway..."
  fi

  # Build rsync command
  rsync_cmd="rsync -avz --progress"

  # Prepare local paths for rsync
  local rsync_sources=()
  for local_path in "${local_paths[@]}"; do
    # Add trailing slash for directories if needed
    if [[ -d "$local_path" && "$local_path" != */ ]]; then
      rsync_sources+=("$local_path/")
    else
      rsync_sources+=("$local_path")
    fi
  done

  # Execute rsync
  echo "Syncing ${#local_paths[@]} item(s) to '$ssh_host:$remote_path'"
  echo "Sources: ${rsync_sources[*]}"
  echo "Running: $rsync_cmd ${rsync_sources[*]} \"$ssh_host:$remote_path\""
  echo ""

  $rsync_cmd "${rsync_sources[@]}" "$ssh_host:$remote_path"

  if [[ $? -eq 0 ]]; then
    echo ""
    echo "✓ Transfer completed successfully"
  else
    echo ""
    echo "✗ Transfer failed"
    return 1
  fi
}
