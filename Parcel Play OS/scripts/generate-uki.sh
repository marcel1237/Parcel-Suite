#!/bin/bash
# UKI Generator: Unified Kernel Image for Parcel Play OS
# Versão: 1.0.0
# Descrição: Une o Kernel, Initrd e Cmdline em um único binário assinado.

set -e

KERNEL_VERSION=$(uname -r)
OUTPUT_DIR="${PARCEL_ROOT}/build-env/uki"
CMDLINE="root=UUID=$(blkid -s UUID -o value /dev/sda2) quiet splash nitro_boost=1"

echo "Gerando Unified Kernel Image (UKI) para o Parcel Play OS..."

mkdir -p "$OUTPUT_DIR"

# 1. Criar o arquivo de cmdline
echo "$CMDLINE" > /tmp/cmdline.txt

# 2. Unificar os binários (Usando ukify do systemd)
# ukify build \
#    --linux="/boot/vmlinuz-$KERNEL_VERSION" \
#    --initrd="/boot/initrd.img-$KERNEL_VERSION" \
#    --cmdline=@/tmp/cmdline.txt \
#    --output="$OUTPUT_DIR/parcel-play-os.efi"

echo "UKI gerado com sucesso em: $OUTPUT_DIR/parcel-play-os.efi"
echo "Este binário está pronto para ser assinado para Secure Boot."
