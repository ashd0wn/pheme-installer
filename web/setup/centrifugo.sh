#!/usr/bin/env bash

CENTRIFUGO_VERSION="5.4.8"
ARCHITECTURE=$(dpkg --print-architecture | awk -F- '{ print $NF }')

# Mapper l'architecture Debian vers celle de GitHub releases
case "$ARCHITECTURE" in
    amd64) ARCH="amd64" ;;
    arm64) ARCH="arm64" ;;
    *)     ARCH="amd64" ;;
esac

echo "Téléchargement Centrifugo ${CENTRIFUGO_VERSION}..."
CENTRIFUGO_URL="https://github.com/centrifugal/centrifugo/releases/download/v${CENTRIFUGO_VERSION}/centrifugo_${CENTRIFUGO_VERSION}_linux_${ARCH}.tar.gz"

wget -O /tmp/centrifugo.tar.gz "$CENTRIFUGO_URL"
tar -xzf /tmp/centrifugo.tar.gz -C /tmp centrifugo
mv /tmp/centrifugo /usr/local/bin/centrifugo
chmod +x /usr/local/bin/centrifugo
rm -f /tmp/centrifugo.tar.gz

# Vérifier
centrifugo version

# Copier la config
cp web/centrifugo/config.json /var/pheme/centrifugo/config.json
