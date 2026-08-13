#!/bin/bash
# Thunder Browser - Optimization & Startup Script
# Versão: 1.0.0

set -e

# Configurações de Ambiente para Dark Volt (EGLFS)
export QT_QPA_PLATFORM=eglfs
export QT_QPA_EGLFS_KMS_CONFIG=/etc/thunder/kms-config.json
export QT_QPA_EGLFS_FORCE888=1

# Flags de Performance do Chromium
export QTWEBENGINE_CHROMIUM_FLAGS="--kiosk \
    --noerrdialogs \
    --disable-infobars \
    --ignore-gpu-blocklist \
    --enable-gpu-rasterization \
    --enable-native-gpu-memory-buffers \
    --num-raster-threads=4 \
    --disable-session-crashed-bubble \
    --disk-cache-dir=/tmp/thunder-cache \
    --disk-cache-size=209715200"

echo "Iniciando Thunder Browser em modo Ultra-Acelerado..."
# /usr/bin/thunder-browser-binary "$@"
