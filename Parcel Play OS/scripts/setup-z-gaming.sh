#!/bin/bash
# Setup Z-Gaming Zone: Optimized ZFS Dataset for 2026 Gaming
# Versão: 1.0.0
# Baseado na inteligência do FreeBSD e Oracle.

set -e

POOL_NAME="z-nitro"
DATASET_NAME="gaming"
MOUNT_POINT="/mnt/nitro-games"

echo "Nitro-Storage: Criando a ZFS Gaming Zone em $POOL_NAME/$DATASET_NAME..."

# 1. Criar o Dataset com Otimizações de Elite
# recordsize=1M: Para carregamento massivo de ativos 3D.
# compression=zstd-3: Alinhado com DirectStorage 1.4.
# casesensitivity=insensitive: Vital para compatibilidade com jogos Windows.
# atime=off: Preservar vida útil do NVMe e reduzir latência.
zfs create \
    -o recordsize=1M \
    -o compression=zstd-3 \
    -o atime=off \
    -o xattr=sa \
    -o casesensitivity=insensitive \
    -o normalization=formD \
    -o mountpoint=$MOUNT_POINT \
    $POOL_NAME/$DATASET_NAME

# 2. Configurar Tuning de Latência
zfs set logbias=latency $POOL_NAME/$DATASET_NAME
zfs set redundant_metadata=most $POOL_NAME/$DATASET_NAME

echo ">> ZFS Gaming Zone pronta! Direcione sua Steam Library para: $MOUNT_POINT"
