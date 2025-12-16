#!/bin/bash

# --- Configuration & Colors ---
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# --- Dependency Check ---
if ! command -v dig &> /dev/null; then
    echo -e "${RED}Error: 'dig' command not found.${NC}"
    echo "Please install it:"
    echo "  - RHEL/CentOS: yum install bind-utils"
    echo "  - Debian/Ubuntu: apt install dnsutils"
    exit 1
fi

# --- Usage Help ---
usage() {
    echo "Usage: $0 <host_file>"
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

# --- Helper Function: Check if input is an IP ---
is_ip() {
    [[ $1 =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]
}

# --- Main Logic ---

echo "DNS Verification (Forward & Reverse)"
echo "File: $HOST_FILE"
echo "------------------------------------------------"

while IFS= read -r HOST || [ -n "$HOST" ]; do
    # Skip empty lines or comments
    [[ $HOST =~ ^#.*$ ]] || [ -z "$HOST" ] && continue

    echo -n "Checking: $HOST ... "

    # 1. Determine Identity (IP or Hostname)
    TARGET_IP=""
    
    if is_ip "$HOST"; then
        # Input is an IP
        TARGET_IP="$HOST"
        echo -e "${YELLOW}(Input is IP)${NC}"
    else
        # Input is a Hostname -> Perform Forward Lookup (dig)
        # +short gives just the IP. grep -v ignores CNAMEs to find the IP line
        RESOLVED_IP=$(dig +short "$HOST" | grep -E '^[0-9.]+$' | head -n 1)

        if [ -n "$RESOLVED_IP" ]; then
            echo -e "${GREEN}Forward OK${NC} -> $RESOLVED_IP"
            TARGET_IP="$RESOLVED_IP"
        else
            echo -e "${RED}Forward KO${NC} (No A Record found)"
            # If forward fails, we usually can't check reverse meaningfuly for a hostname
            echo "   --------------------------------------------"
            continue 
        fi
    fi

    # 2. Perform Reverse Lookup (dig -x) on the Target IP
    # +short returns the FQDN
    PTR_RECORD=$(dig -x "$TARGET_IP" +short)

    if [ -n "$PTR_RECORD" ]; then
        # Remove trailing dot from PTR if present for cleaner display
        PTR_CLEAN=${PTR_RECORD%.}
        echo -e "   Reverse: [ ${GREEN}OK${NC} ] $TARGET_IP -> $PTR_CLEAN"
    else
        echo -e "   Reverse: [ ${RED}KO${NC} ] $TARGET_IP -> (No PTR Record)"
    fi

    echo "   --------------------------------------------"

done < "$HOST_FILE"
