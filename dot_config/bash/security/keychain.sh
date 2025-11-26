#!/bin/bash
# Security and Keychain Configuration

# Function to find and add all SSH private keys to keychain
load_ssh_keys() {
    local ssh_dir="$HOME/.ssh"
    local keys=()
    
    # Check if .ssh directory exists
    if [[ ! -d "$ssh_dir" ]]; then
        echo "Warning: SSH directory $ssh_dir not found"
        return 1
    fi
    
    # Check if keychain command is available
    if ! command -v keychain >/dev/null 2>&1; then
        echo "Warning: keychain command not found"
        return 1
    fi
    
    # Look for SSH private keys with common naming patterns
    # Pattern 1: id_* files (most common)
    if compgen -G "$ssh_dir/id_*" >/dev/null 2>&1; then
        for key_file in "$ssh_dir"/id_*; do
            if [[ -f "$key_file" && "$key_file" != *.pub ]]; then
                local key_name=$(basename "$key_file")
                keys+=("$key_name")
            fi
        done
    fi
    
    # Pattern 2: Common algorithm names without id_ prefix
    for algo in rsa dsa ecdsa ed25519; do
        if [[ -f "$ssh_dir/$algo" ]]; then
            keys+=("$algo")
        fi
    done
    
    # Pattern 3: Look for any file that might be a private key by checking content
    for potential_key in "$ssh_dir"/*; do
        if [[ -f "$potential_key" && -r "$potential_key" ]]; then
            local filename=$(basename "$potential_key")
            # Skip known non-key files
            if [[ "$filename" =~ ^(known_hosts|config|authorized_keys|\.pub)$ ]]; then
                continue
            fi
            # Skip files already found
            if [[ " ${keys[*]} " =~ " ${filename} " ]]; then
                continue
            fi
            # Check if file looks like a private key
            if head -n 1 "$potential_key" 2>/dev/null | grep -q "BEGIN.*PRIVATE KEY\|BEGIN OPENSSH PRIVATE KEY"; then
                keys+=("$filename")
            fi
        fi
    done
    
    # Remove duplicates
    local unique_keys=($(printf "%s\n" "${keys[@]}" | sort -u))
    
    # Load keys into keychain
    if [[ ${#unique_keys[@]} -gt 0 ]]; then
        eval $(keychain --eval --quiet "${unique_keys[@]}" 2>/dev/null) || {
            echo "Warning: Failed to load some keys with keychain"
            return 1
        }
    else
        echo "No SSH private keys found in $ssh_dir"
        
        # Fallback to original hardcoded keys if they exist
        local fallback_keys=()
        for key in id_ed25519_gh id_ed25519_osf id_rsa id_ed25519 id_ecdsa; do
            if [[ -f "$ssh_dir/$key" ]]; then
                fallback_keys+=("$key")
            fi
        done
        
        if [[ ${#fallback_keys[@]} -gt 0 ]]; then
            echo "Using fallback keys: ${fallback_keys[*]}"
            eval $(keychain --eval --quiet "${fallback_keys[@]}" 2>/dev/null) || {
                echo "Warning: Failed to load fallback keys with keychain"
                return 1
            }
        else
            echo "No SSH keys found to load"
            return 1
        fi
    fi
}

# Only load SSH keys if we're in an interactive shell and keychain is available
if [[ $- == *i* ]] && command -v keychain >/dev/null 2>&1; then
    load_ssh_keys
else
    echo "Skipping SSH key loading (non-interactive shell or keychain not available)"
fi 
