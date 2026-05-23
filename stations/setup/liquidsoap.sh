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

# Liquidsoap 2.2.4 depuis les repos Ubuntu officiels
# Compatible avec Pheme 0.19.1 — 2.4.x introduit des breaking changes
apt_get_with_lock install -y --no-install-recommends liquidsoap

ln -sf /usr/bin/liquidsoap /usr/local/bin/liquidsoap 2>/dev/null || true

echo "Liquidsoap version : $(liquidsoap --version 2>/dev/null || echo 'inconnue')"
