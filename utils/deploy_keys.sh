#!/bin/bash

# --- Configuration & Colors ---
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color
DEFAULT_KEY="$HOME/.ssh/id_rsa"

# --- dependency check ---
if ! command -v sshpass &> /dev/null; then
    echo -e "${RED}Error: sshpass is not installed.${NC}"
    echo "Please install it (e.g., sudo apt install sshpass) and try again."
    exit 1
fi

# --- Usage Help ---
usage() {
    echo "Usage: $0 [-i path_to_private_key] <host_file>"
    echo "  -i : Specify identity file (default: ~/.ssh/id_rsa)"
    exit 1
}

# --- Argument Parsing ---
SSH_KEY="$DEFAULT_KEY"

while getopts ":i:" opt; do
  case $opt in
    i) SSH_KEY="$OPTARG" ;;
    \?) echo "Invalid option -$OPTARG" >&2; usage ;;
  esac
done

# Shift arguments so $1 becomes the host file
shift $((OPTIND -1))

HOST_FILE=$1

# --- Validation ---
if [ -z "$HOST_FILE" ]; then
    echo -e "${RED}Error: Missing host file argument.${NC}"
    usage
fi

if [ ! -f "$HOST_FILE" ]; then
    echo -e "${RED}Error: File '$HOST_FILE' not found.${NC}"
    exit 1
fi

# We actually need the public key for checking, usually it's private_key_path + .pub
PUB_KEY="${SSH_KEY}.pub"

if [ ! -f "$PUB_KEY" ]; then
    echo -e "${RED}Error: Public key not found at $PUB_KEY${NC}"
    echo "Please generate one using 'ssh-keygen' first."
    exit 1
fi

# --- Main Logic ---

echo "Deploying key: $PUB_KEY"
echo "User: $USER"
echo "------------------------------------------------"

# 1. Ask for password once (silently)
read -s -p "Enter SSH password for user '$USER': " SSH_PASSWORD
echo "" # Newline after password input
echo "------------------------------------------------"

# Export password so sshpass can pick it up safely from environment
export SSHPASS="$SSH_PASSWORD"

# 2. Loop through file
while IFS= read -r HOST || [ -n "$HOST" ]; do
    # Skip empty lines or lines starting with #
    [[ $HOST =~ ^#.*$ ]] || [ -z "$HOST" ] && continue

    # 3. Execution
    # -e: use env var for password
    # -o StrictHostKeyChecking=no: Auto-accept "yes" for new hosts
    # > /dev/null 2>&1: Hide technical output, we only want status
    sshpass -e ssh-copy-id -o StrictHostKeyChecking=no -i "$SSH_KEY" "$USER@$HOST" > /dev/null 2>&1
    
    EXIT_CODE=$?

    # 4. Monitor Steps (OK/KO)
    if [ $EXIT_CODE -eq 0 ]; then
        echo -e "[ ${GREEN}OK${NC} ] $HOST"
    else
        echo -e "[ ${RED}KO${NC} ] $HOST (Check connectivity or credentials)"
    fi

done < "$HOST_FILE"

# Clear password from variable for safety
unset SSHPASS
