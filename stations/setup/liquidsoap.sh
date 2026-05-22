#!/usr/bin/env bash

PACKAGES=(
    libao4 libfaad2 libfdk-aac2 libgd3 liblo7 libmad0 libmagic1
    libportaudio2 libsdl2-image-2.0-0 libsdl2-ttf-2.0-0 libsoundtouch1 libxpm4
    libasound2-plugins libasound2-data libavcodec60 libavdevice60 libavfilter9
    libavformat60 libavutil58 libpulse0 libsamplerate0 libswresample4 libswscale7
    libtag1v5 libsrt1.5-openssl bubblewrap ffmpeg liblilv-0-0 libjemalloc2 ladspa-sdk
)

apt_get_with_lock update
apt_get_with_lock install -y --no-install-recommends "${PACKAGES[@]}"

LIQUIDSOAP_VERSION="2.4.4"
ARCHITECTURE=$(dpkg --print-architecture | awk -F- '{ print $NF }')
UBUNTU_CODENAME=$(lsb_release -cs 2>/dev/null || echo "noble")

# Les assets permanents sont sur savonet/liquidsoap-release-assets
# Le nom exact du fichier pour ubuntu noble :
# liquidsoap_2.4.4-ubuntu-noble-ocaml5.4.0-1_amd64.deb
LIQUIDSOAP_URL="https://github.com/savonet/liquidsoap-release-assets/releases/download/v${LIQUIDSOAP_VERSION}/liquidsoap_${LIQUIDSOAP_VERSION}-ubuntu-${UBUNTU_CODENAME}-ocaml5.4.0-1_${ARCHITECTURE}.deb"

echo "Téléchargement Liquidsoap ${LIQUIDSOAP_VERSION} (${UBUNTU_CODENAME}/${ARCHITECTURE})..."
curl -L --retry 3 --output /tmp/liquidsoap.deb "$LIQUIDSOAP_URL"

if [ $? -ne 0 ] || [ ! -s /tmp/liquidsoap.deb ]; then
    echo "Fallback: tentative avec noble..."
    LIQUIDSOAP_URL="https://github.com/savonet/liquidsoap-release-assets/releases/download/v${LIQUIDSOAP_VERSION}/liquidsoap_${LIQUIDSOAP_VERSION}-ubuntu-noble-ocaml5.4.0-1_${ARCHITECTURE}.deb"
    curl -L --retry 3 --output /tmp/liquidsoap.deb "$LIQUIDSOAP_URL"
fi

dpkg -i /tmp/liquidsoap.deb || apt_get_with_lock install -y -f
apt_get_with_lock install -y -f --no-install-recommends

ln -sf /usr/bin/liquidsoap /usr/local/bin/liquidsoap 2>/dev/null || true
rm -f /tmp/liquidsoap.deb

echo "Liquidsoap version : $(liquidsoap --version 2>/dev/null || echo 'inconnue')"
