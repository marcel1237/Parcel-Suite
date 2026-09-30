#!/bin/bash
# ==============================================================================
# Script de Execução Rápida em QEMU/KVM — Angel OS
# ==============================================================================

set -e

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
PROJECT_ROOT=$(cd -- "$SCRIPT_DIR/.." &>/dev/null && pwd)
OUTPUT_ISO="$PROJECT_ROOT/output/Angel-OS-KDE-Full.iso"
BUILD_KERNEL="$PROJECT_ROOT/build/kernel/vmlinuz-7.3-seraphin"
BUILD_INITRD="$PROJECT_ROOT/build/kernel/initramfs.img"

CYAN='\033[1;36m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
NC='\033[0m'

echo -e "${CYAN}============================================================${NC}"
echo -e "${CYAN}            ANGEL OS — Teste de Boot no QEMU/KVM            ${NC}"
echo -e "${CYAN}============================================================${NC}"

if ! command -v qemu-system-x86_64 &>/dev/null; then
    echo -e "${RED}[X] qemu-system-x86_64 não encontrado no host.${NC}"
    echo "Instale o QEMU com: sudo apt install qemu-system-x86"
    exit 1
fi

KVM_OPTS="-enable-kvm"
if ! [ -e /dev/kvm ]; then
    echo -e "${YELLOW}[!] /dev/kvm não detectado. Executando emulação pura sem KVM.${NC}"
    KVM_OPTS=""
fi

OVMF_OPTS=""
if [ -f /usr/share/OVMF/OVMF_CODE.fd ]; then
    echo -e "${GREEN}[OK] Firmware UEFI (OVMF) detectado.${NC}"
    OVMF_OPTS="-bios /usr/share/OVMF/OVMF_CODE.fd"
fi

if [ -f "$OUTPUT_ISO" ]; then
    echo -e "${GREEN}Iniciando QEMU a partir da ISO $OUTPUT_ISO...${NC}"
    exec qemu-system-x86_64 $KVM_OPTS $OVMF_OPTS -m 4096 -smp 4 -cdrom "$OUTPUT_ISO" -boot d -vga virtio -display default
elif [ -f "$BUILD_KERNEL" ] && [ -f "$BUILD_INITRD" ]; then
    echo -e "${GREEN}Iniciando QEMU a partir do Kernel Vanilla 7.3 e initramfs...${NC}"
    exec qemu-system-x86_64 $KVM_OPTS -m 2096 -smp 2 -kernel "$BUILD_KERNEL" -initrd "$BUILD_INITRD" -append "console=ttyS0 quiet" -nographic
else
    echo -e "${YELLOW}[!] Mídia ISO ou Kernel+Initramfs ainda não gerados.${NC}"
    echo -e "Para gerar a ISO do Angel OS, execute:"
    echo "  ./angel-build all"
fi
