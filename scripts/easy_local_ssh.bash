#!/bin/bash

# Simple SSH connection script
# Change these variables to match your setup
REMOTE_USER="jg"         # Username on the remote machine
REMOTE_IP="192.168.1.100"      # IP address of the remote machine
SSH_KEY="~/id_ed25519_can"   # Path to the SSH key
SSH_PORT="57762"                  # SSH port (usually 22)

# Colors for better readability
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Display connection information
echo -e "${YELLOW}Connecting to ${REMOTE_USER}@${REMOTE_IP}...${NC}"

# Check if the remote host is reachable
ping -c 1 -W 1 ${REMOTE_IP} > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo -e "${RED}Cannot reach the remote host. Please check:${NC}"
    echo -e "  - The remote machine is powered on"
    echo -e "  - Both computers are on the same network"
    echo -e "  - The IP address (${REMOTE_IP}) is correct"
    exit 1
fi

# Connect using SSH with the specified key
echo -e "${GREEN}Host is reachable. Attempting SSH connection...${NC}"
ssh -i ${SSH_KEY} -p ${SSH_PORT} ${REMOTE_USER}@${REMOTE_IP}

# Check if SSH connection was successful
if [ $? -ne 0 ]; then
    echo -e "${RED}SSH connection failed. Please check:${NC}"
    echo -e "  - The SSH key is correct and has proper permissions"
    echo -e "  - The username is correct"
    echo -e "  - The SSH server is running on the remote machine"
    exit 1
fi

exit 0
