#!/usr/bin/env bash

CENTRIFUGO_VERSION="5.4.8"
ARCHITECTURE=$(dpkg --print-architecture | awk -F- '{ print $NF }')

case "$ARCHITECTURE" in
    amd64) ARCH="amd64" ;;
    arm64) ARCH="arm64" ;;
    *)     ARCH="amd64" ;;
esac

CENTRIFUGO_URL="https://github.com/centrifugal/centrifugo/releases/download/v${CENTRIFUGO_VERSION}/centrifugo_${CENTRIFUGO_VERSION}_linux_${ARCH}.tar.gz"

echo "Téléchargement Centrifugo ${CENTRIFUGO_VERSION}..."
curl -L --retry 3 --output /tmp/centrifugo.tar.gz "$CENTRIFUGO_URL"

tar -xzf /tmp/centrifugo.tar.gz -C /tmp centrifugo
mv /tmp/centrifugo /usr/local/bin/centrifugo
chmod +x /usr/local/bin/centrifugo
rm -f /tmp/centrifugo.tar.gz

echo "Centrifugo version : $(/usr/local/bin/centrifugo version 2>/dev/null || echo 'inconnue')"

cp "$installerHome/web/centrifugo/config.json" /var/pheme/centrifugo/config.json
chown pheme:pheme /var/pheme/centrifugo/config.json
