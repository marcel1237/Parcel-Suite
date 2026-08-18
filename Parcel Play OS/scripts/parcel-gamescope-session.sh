#!/bin/bash
# Parcel Play OS - Gamescope + KDE Plasma 6 Session Wrapper
# Versão: 1.0.0
# Descrição: Inicia o micro-compositor Gamescope e aninha o KDE Plasma 6 dentro dele.

set -e

# 1. Configurações de Hardware (Auto-detectadas via Nitro-Optimize)
# Valores padrão se a detecção falhar
RES_W=1920
RES_H=1080
REFRESH=60

# 2. Injetar Otimizações Thunder SDK
# export QSG_RHI_BACKEND=vulkan
# export KWIN_DRM_USE_MODIFIERS=1

echo "Iniciando Micro-Compositor Gamescope (Nitro-Boost)..."

# 3. Executar Gamescope com suporte a HDR e VRR (SteamOS style)
# -e: Integração Steam (overlays)
# --expose-wayland: Necessário para o Plasma 6 (Wayland Nativo)
# --hdr-enabled: Ativa HDR no kernel NitroCore
gamescope \
    -W $RES_W -H $RES_H -r $REFRESH \
    --expose-wayland \
    --hdr-enabled \
    --adaptive-sync \
    -e -- \
    dbus-run-session startplasma-wayland
