#!/bin/bash

# --- Configuration & Colors ---
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color
DEFAULT_KEY="$HOME/.ssh/id_rsa"

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

if [ ! -f "$SSH_KEY" ]; then
    echo -e "${RED}Error: Private key '$SSH_KEY' not found.${NC}"
    exit 1
fi

# --- Main Logic ---

echo "Verifying access for user: $USER"
echo "Using key: $SSH_KEY"
echo "------------------------------------------------"

while IFS= read -r HOST || [ -n "$HOST" ]; do
    # Skip empty lines or lines starting with #
    [[ $HOST =~ ^#.*$ ]] || [ -z "$HOST" ] && continue

    # Execution
    # -n: Redirects stdin from /dev/null (PREVENTS SSH FROM EATING THE LOOP)
    # -o BatchMode=yes: Fails immediately if password is asked
    # -o ConnectTimeout=5: Stops hanging on dead hosts
    # -o StrictHostKeyChecking=no: Avoids yes/no prompts
    
    OUTPUT=$(ssh -n -o BatchMode=yes -o ConnectTimeout=5 -o StrictHostKeyChecking=no -i "$SSH_KEY" "$USER@$HOST" "hostname" 2>&1)
    
    RET_CODE=$?

    # Monitor Steps
    if [ $RET_CODE -eq 0 ]; then
        echo -e "[ ${GREEN}OK${NC} ] $HOST -> $OUTPUT"
    else
        # Trim error message for cleaner output
        ERROR_MSG=$(echo "$OUTPUT" | head -n 1)
        echo -e "[ ${RED}KO${NC} ] $HOST ($ERROR_MSG)"
    fi

done < "$HOST_FILE"
