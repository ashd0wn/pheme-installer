#!/bin/bash
# apt_get_with_lock.sh

apt_get_with_lock() {
    # Attendre que les locks APT/DPKG soient libérés
    while fuser /var/lib/dpkg/lock >/dev/null 2>&1 || \
          fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1 || \
          fuser /var/lib/apt/lists/lock >/dev/null 2>&1 || \
          fuser /var/cache/apt/archives/lock >/dev/null 2>&1; do
        echo "APT lock en cours d'utilisation. Attente 5 secondes..."
        sleep 5
    done

    # Forcer le mode non-interactif pour éviter toute demande utilisateur
    # (tmpreaper, postfix, grub, etc.)
    DEBIAN_FRONTEND=noninteractive \
    DEBCONF_NONINTERACTIVE_SEEN=true \
    sudo -E apt-get \
        -o Dpkg::Options::="--force-confold" \
        -o Dpkg::Options::="--force-confdef" \
        "$@"

    if [ $? -ne 0 ]; then
        echo "Erreur: apt-get a échoué."
        return 1
    fi

    return 0
}
