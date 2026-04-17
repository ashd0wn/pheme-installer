#!/bin/bash
# misc/prepare_system.sh

# Détermine le répertoire de base du script pour sourcer correctement les outils
# La variable BASEDIR sera le répertoire "Pheme-Ubuntu/"
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/.."

# Source la fonction apt_get_with_lock pour la rendre disponible
# Cela charge le contenu de tools/apt_get_with_lock.sh dans ce script.
source "${BASEDIR}/tools/apt_get_with_lock.sh"

# Vérifie si le fichier de fonction a été sourcé correctement
if ! type "apt_get_with_lock" &> /dev/null; then
    echo "Error: apt_get_with_lock function not found. Ensure tools/apt_get_with_lock.sh is correctly sourced."
    exit 1
fi

echo "Updating system packages..."
apt_get_with_lock update || exit 1 # Utilisation de la fonction corrigée

echo "Installing essential system tools..."
apt_get_with_lock install -y nano curl git unzip screen htop lsb-release ca-certificates gnupg software-properties-common || exit 1

# Check for 'adm' group and create if not exists (already in your script)
if ! getent group adm >/dev/null; then
    echo "Creating 'adm' group..."
    groupadd adm
else
    echo "adm group already exists, nothing to do."
fi

# Set proper locale for the system (already in your script)
echo "Setting system locale..."
apt_get_with_lock install -y locales || exit 1
locale-gen en_US.UTF-8

echo "System preparation complete."
