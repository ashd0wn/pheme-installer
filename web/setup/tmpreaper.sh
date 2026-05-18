#!/usr/bin/env bash

# Pré-accepter la configuration debconf de tmpreaper
# pour éviter l'interaction utilisateur pendant l'installation
echo "tmpreaper tmpreaper/readsecurity boolean true" | debconf-set-selections
echo "tmpreaper tmpreaper/readsecurity_upgrading boolean true" | debconf-set-selections

DEBIAN_FRONTEND=noninteractive apt_get_with_lock install -y --no-install-recommends tmpreaper
