#!/usr/bin/env bash

# Packages required by Liquidsoap and Audio Post-processing
PACKAGES=(
    libao4 libfaad2 libfdk-aac2 libgd3 liblo7 libmad0 libmagic1
    libportaudio2 libsdl2-image-2.0-0 libsdl2-ttf-2.0-0 libsoundtouch1 libxpm4
    libasound2-plugins libasound2-data libavcodec60 libavdevice60 libavfilter9
    libavformat60 libavutil58 libpulse0 libsamplerate0 libswresample4 libswscale7
    libtag1v5 libsrt1.5-openssl bubblewrap ffmpeg liblilv-0-0 libjemalloc2 ladspa-sdk
)

apt_get_with_lock update
apt_get_with_lock install -y --no-install-recommends "${PACKAGES[@]}"

# Détecter la version Ubuntu pour choisir le bon package
UBUNTU_CODENAME=$(lsb_release -cs 2>/dev/null || echo "noble")
ARCHITECTURE=$(dpkg --print-architecture | awk -F- '{ print $NF }')

LIQUIDSOAP_VERSION="2.4.1"
LIQUIDSOAP_DEB_URL="https://github.com/savonet/liquidsoap/releases/download/v${LIQUIDSOAP_VERSION}/liquidsoap_${LIQUIDSOAP_VERSION}-ubuntu-${UBUNTU_CODENAME}-ocaml5.4.0-1_${ARCHITECTURE}.deb"

echo "Téléchargement Liquidsoap ${LIQUIDSOAP_VERSION} pour ${UBUNTU_CODENAME}/${ARCHITECTURE}..."
wget -O liquidsoap.deb "$LIQUIDSOAP_DEB_URL"

if [ $? -ne 0 ]; then
    echo "Échec du téléchargement pour ${UBUNTU_CODENAME}, tentative avec noble..."
    LIQUIDSOAP_DEB_URL="https://github.com/savonet/liquidsoap/releases/download/v${LIQUIDSOAP_VERSION}/liquidsoap_${LIQUIDSOAP_VERSION}-ubuntu-noble-ocaml5.4.0-1_${ARCHITECTURE}.deb"
    wget -O liquidsoap.deb "$LIQUIDSOAP_DEB_URL"
fi

dpkg -i liquidsoap.deb
apt_get_with_lock install -y -f --no-install-recommends

ln -sf /usr/bin/liquidsoap /usr/local/bin/liquidsoap
rm -f liquidsoap.deb
cd "$installerHome"
