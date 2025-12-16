#!/bin/bash

# --- Configuration & Colors ---
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# The packages to install
PACKAGES="openldap-clients krb5-workstation krb5-libs freeipa-client"

# --- Usage Help ---
usage() {
    echo "Usage: $0 <host_file>"
    echo "Example: $0 hosts.txt"
    exit 1
}

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

# --- Main Logic ---

echo "Installing packages on remote hosts..."
echo "Packages: $PACKAGES"
echo "------------------------------------------------"

while IFS= read -r HOST || [ -n "$HOST" ]; do
    # Skip empty lines or comments
    [[ $HOST =~ ^#.*$ ]] || [ -z "$HOST" ] && continue

    # Build the installation command
    # We use -y to assume 'yes' to prompts so the script doesn't hang
    INSTALL_CMD="yum install -y $PACKAGES"

    # Execution
    # -n: Redirects stdin from /dev/null (Crucial for loops!)
    # 2>&1: Captures both standard output and errors
    OUTPUT=$(ssh -n -o BatchMode=yes -o ConnectTimeout=10 -o StrictHostKeyChecking=no "$HOST" "$INSTALL_CMD" 2>&1)
    
    RET_CODE=$?

    # Monitor Steps
    if [ $RET_CODE -eq 0 ]; then
        echo -e "[ ${GREEN}OK${NC} ] $HOST (Installation successful)"
    else
        # If it fails, we show the first line of the error for context
        # usually "Permission denied" or "Could not resolve host" or a yum error
        ERROR_MSG=$(echo "$OUTPUT" | head -n 1)
        
        # If the error is overly long, truncate it
        if [ ${#ERROR_MSG} -gt 50 ]; then
             ERROR_MSG="${ERROR_MSG:0:47}..."
        fi
        
        echo -e "[ ${RED}KO${NC} ] $HOST ($ERROR_MSG)"
    fi

done < "$HOST_FILE"
