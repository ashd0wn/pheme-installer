#!/bin/bash
# apt_get_with_lock.sh

# This script defines a helper function to safely run apt-get commands
# by waiting for any existing APT/DPKG locks to be released.

# Function to wait for APT/DPKG locks
apt_get_with_lock() {
    echo "Attempting to acquire APT lock. Waiting if necessary..."

    # Check for various common lock files for apt and dpkg
    # Loop indefinitely until all locks are released
    while fuser /var/lib/dpkg/lock >/dev/null 2>&1 || \
          fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1 || \
          fuser /var/lib/apt/lists/lock >/dev/null 2>&1 || \
          fuser /var/cache/apt/archives/lock >/dev/null 2>&1; do

        echo "Lock file(s) in use. Waiting 5 seconds..."
        sleep 5
    done

    echo "APT lock released. Executing: sudo apt-get $@"

    # Execute the actual apt-get command with all passed arguments
    # Using 'sudo' here ensures the command runs with necessary permissions
    sudo apt-get "$@"

    # Check the exit status of the apt-get command
    if [ $? -ne 0 ]; then
        echo "Error: apt-get command failed. Please check the output above."
        return 1 # Return a non-zero exit code to indicate failure
    fi

    return 0 # Return 0 for success
}

# --- IMPORTANT ---
# This script is designed to be SOURCED by other scripts (e.g., prepare_system.sh),
# not executed directly. Sourcing it makes the 'apt_get_with_lock' function
# available in the parent script's environment.

# Example of how to source this script in another script:
# SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
# source "${SCRIPT_DIR}/../tools/apt_get_with_lock.sh"
#
# Then you can call the function like this:
# apt_get_with_lock update
# apt_get_with_lock install -y some-package
