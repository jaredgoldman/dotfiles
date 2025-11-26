#!/bin/bash

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
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    
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
            # Complete remote paths (basic completion)
            COMPREPLY=($(compgen -f -- "$cur"))
            ;;
    esac
}

# Register completion function
complete -F _rsync_completion "$(basename "$0")"

# Main script function
main() {
    if [[ $# -lt 2 ]]; then
        echo "Usage: $0 <local_file_path> <ssh_host> [remote_path]"
        echo ""
        echo "Available SSH hosts:"
        get_ssh_hosts | sed 's/^/  /'
        echo ""
        echo "Examples:"
        echo "  $0 /path/to/file.txt myserver"
        echo "  $0 /path/to/file.txt myserver /remote/path/"
        echo "  $0 /path/to/directory/ myserver /remote/destination/"
        exit 1
    fi
    
    local_path="$1"
    ssh_host="$2"
    remote_path="${3:-~}"  # Default to home directory if not specified
    
    # Check if local file/directory exists
    if [[ ! -e "$local_path" ]]; then
        echo "Error: Local path '$local_path' does not exist"
        exit 1
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
        exit 1
    fi
}

# Only run main if script is executed directly (not sourced for completion)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
