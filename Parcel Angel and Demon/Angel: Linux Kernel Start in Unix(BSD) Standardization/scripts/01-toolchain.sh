#!/bin/bash
# ==============================================================================
# Script 01: Toolchain (Binutils, GCC, Glibc, Linux Headers) — Angel OS
# ==============================================================================

set -e

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
PROJECT_ROOT=$(cd -- "$SCRIPT_DIR/.." &>/dev/null && pwd)
BUILD_ROOTFS="$PROJECT_ROOT/build/rootfs"
BUILD_TOOLCHAIN="$PROJECT_ROOT/build/toolchain"

CYAN='\033[1;36m'
GREEN='\033[1;32m'
NC='\033[0m'

echo -e "${CYAN}============================================================${NC}"
echo -e "${CYAN}      [01/13] ANGEL OS — Construindo Toolchain Base         ${NC}"
echo -e "${CYAN}============================================================${NC}"

mkdir -p "$BUILD_TOOLCHAIN" "$BUILD_ROOTFS/usr/bin" "$BUILD_ROOTFS/usr/lib" "$BUILD_ROOTFS/usr/include"

echo -e "${GREEN}[OK] Diretórios da toolchain e rootfs inicializados em:${NC}"
echo "  - Toolchain: $BUILD_TOOLCHAIN"
echo "  - RootFS: $BUILD_ROOTFS"

# Validação do compilador do host para bootstrap
echo -e "\n${CYAN}Verificando compiladores do host:${NC}"
gcc --version | head -n 1
ld --version | head -n 1
