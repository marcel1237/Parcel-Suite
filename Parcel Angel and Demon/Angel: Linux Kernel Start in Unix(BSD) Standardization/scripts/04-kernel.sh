#!/bin/bash
# ==============================================================================
# Script 04: Kernel Linux Vanilla 7.3 & initramfs — Angel OS
# ==============================================================================

set -e

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
PROJECT_ROOT=$(cd -- "$SCRIPT_DIR/.." &>/dev/null && pwd)
BUILD_KERNEL="$PROJECT_ROOT/build/kernel"
BUILD_ROOTFS="$PROJECT_ROOT/build/rootfs"

CYAN='\033[1;36m'
GREEN='\033[1;32m'
NC='\033[0m'

echo -e "${CYAN}============================================================${NC}"
echo -e "${CYAN}      [04/13] ANGEL OS — Kernel Linux Vanilla 7.3 & initramfs ${NC}"
echo -e "${CYAN}============================================================${NC}"

mkdir -p "$BUILD_KERNEL" "$BUILD_ROOTFS/boot"

echo -e "${GREEN}[OK] Diretório do Kernel e Boot preparados:${NC}"
echo "  - Kernel Build: $BUILD_KERNEL"
echo "  - Boot RootFS: $BUILD_ROOTFS/boot"
