#!/usr/bin/env bash

### Description: Install Pheme
### OS: Ubuntu 22.04 LTS
### Run this script as root only
### mkdir /root/pheme_installer && cd /root/pheme_installer && git clone https://github.com/ashd0wn/Pheme-Installer.git . && chmod +x install.sh && ./install.sh -i

##############################################################################
# Pheme Installer
##############################################################################

set -eu -o errexit -o pipefail -o noclobber -o nounset

! getopt --test >/dev/null
if [[ ${PIPESTATUS[0]} -ne 4 ]]; then
    echo '`getopt --test` failed in this environment.'
    exit 1
fi

# Generate random passwords
mysql_root_pass=$(
    head /dev/urandom | tr -dc A-Za-z0-9 | head -c 16
    echo ''
)

generate_pheme_username=$(
    head /dev/urandom | tr -dc A-Za-z0-9 | head -c 16
    echo ''
)

generate_pheme_password=$(
    head /dev/urandom | tr -dc A-Za-z0-9 | head -c 16
    echo ''
)

### Global Installer Options
# Installer Home
installerHome=$PWD

# Misc Options
set_php_version="8.2"

# Pheme Database name cannot be changed.
# The migrate function does not support custom DB names.
set_pheme_database=pheme
set_pheme_username=$generate_pheme_username
set_pheme_password=$generate_pheme_password

# Pheme Version
set_pheme_version="0.19.1"

# Commands
LONGOPTS=help,version,install,changeports,clean
OPTIONS=hvico

if [ "$#" -eq 0 ]; then
    echo "No options specified. Use --help to learn more."
    exit 1
fi

! PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTS --name "$0" -- "$@")
if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
    exit 2
fi

eval set -- "$PARSED"

h=n v=n i=n c=n o=n

while true; do
    case "$1" in
    -h | --help)
        h=y
        break
        ;;
    -v | --version)
        v=y
        shift
        ;;
    -i | --install)
        i=y
        break
        ;;
    -c | --clean)
        c=y
        break
        ;;
    -o | --changeports)
        o=y
        break
        ;;
    --)
        shift
        break
        ;;
    *)
        echo "Invalid option(s) specified. Use help(-h) to learn more."
        exit 3
        ;;
    esac
done

if [ "$(id -u)" -ne 0 ]; then
    echo 'This needs to be run as root.' >&2
    exit 1
fi

trap exit_handler EXIT

# apt_get_with_lock
source tools/apt_get_with_lock.sh || { echo "Error sourcing apt_get_with_lock.sh"; exit 1; }

##############################################################################
# Invoked upon EXIT signal from bash
##############################################################################
function exit_handler() {
    if [ "$?" -ne 0 ]; then
        echo -en "\nSome error has occured. Check '$installerHome/pheme_installer.log' for details.\n"
        exit 1
    fi
}

##############################################################################
# Setup Installer Logging
##############################################################################
function pheme_installer_logging() {
    touch $installerHome/pheme_installer.log
    LOG_FILE="$installerHome/pheme_installer.log"
}

##############################################################################
# Print version (-v/--version)
##############################################################################
function pheme_version() {
    echo "---
Available Pheme Version: $set_pheme_version"

    azv=/var/pheme/www/src/Version.php
    if [ -f "$azv" ]; then
        FALLBACK_VERSION="$(grep -oE "\FALLBACK_VERSION = '.*';" $azv | sed "s/FALLBACK_VERSION = '//g;s/';//g")"
        echo -en "Installed Pheme Version: $FALLBACK_VERSION \n\n"
    else
        echo -en "\nPheme is not installed.\n---\n"
    fi
}

##############################################################################
# Install Pheme (-i/--install)
##############################################################################
function pheme_install() {
    pheme_git_version="stable"

    export DEBIAN_FRONTEND=noninteractive

    set_mariadb_version=11.5

    source install_default.sh
}

##############################################################################
# Clean Pheme www_tmp (-c/--clean)
##############################################################################
function tools_clean_pheme() {
    source tools/pheme/clean.sh
}

##############################################################################
# Change Pheme panel ports (-o/--changeports)
##############################################################################
function tools_change_pheme_ports() {
    source tools/pheme/change_ports.sh
}

##############################################################################
# Print help (-h/--help)
##############################################################################
function pheme_help() {
    cat <<EOF
---
Pheme Installer — Bare metal radio platform for Ubuntu 22.04 LTS

Usage: ./install.sh [option]

Installation
  -i, --install        Install Pheme $set_pheme_version

Maintenance
  -c, --clean          Clean Pheme's www_tmp directory
  -o, --changeports    Change the ports on which the Pheme panel runs

Info
  -v, --version        Display version information
  -h, --help           Display this help message

Exit status:
Returns 0 if successful; non-zero otherwise.
---
EOF
}

##############################################################################
# main
##############################################################################
function main() {
    pheme_installer_logging

    if [ "$h" == "y" ]; then
        pheme_help
    fi

    if [ "$v" == "y" ]; then
        pheme_version
    fi

    if [ "$i" == "y" ]; then
        pheme_install
    fi

    if [ "$c" == "y" ]; then
        tools_clean_pheme
    fi

    if [ "$o" == "y" ]; then
        tools_change_pheme_ports
    fi
}

main "$@"
