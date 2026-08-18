#!/bin/bash
# Nitro-Hybrid Handoff: Secure Library Isolation (Bubblewrap logic)
# Versão: 1.0.0
# Descrição: Cria namespaces isolados para rodar apps do Arch/AUR sobre o host Ubuntu.

set -e

APP_NAME=$1
ZONE_PATH="/var/lib/nitrocore/arch/rootfs"

if [ -z "$APP_NAME" ]; then
    echo "Uso: nitro-hybrid-handoff.sh [executable_name]"
    exit 1
fi

echo "Nitro-APX: Iniciando Simbiose Híbrida para '$APP_NAME'..."

# 1. Comando Bubblewrap
# --ro-bind: Mapeia as bibliotecas do Arch (Zona B) como somente leitura.
# --bind: Compartilha as pastas de dados do Host (Zona A) para persistência.
bwrap \
    --unshare-all \
    --share-net \
    --proc /proc \
    --dev /dev \
    --tmpfs /tmp \
    --tmpfs /run \
    --ro-bind "$ZONE_PATH/usr" /usr \
    --ro-bind "$ZONE_PATH/lib" /lib \
    --ro-bind "$ZONE_PATH/lib64" /lib64 \
    --ro-bind "$ZONE_PATH/bin" /bin \
    --bind "$HOME" "$HOME" \
    --bind "/etc/resolv.conf" "/etc/resolv.conf" \
    --setenv LD_LIBRARY_PATH "/lib:/usr/lib" \
    "$APP_NAME"

echo ">> Handoff concluído para '$APP_NAME'."
