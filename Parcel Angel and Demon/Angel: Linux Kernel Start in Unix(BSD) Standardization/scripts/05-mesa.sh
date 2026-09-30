#!/bin/bash
# ==============================================================================
# Script 05: GPU & Entrada (DRM, Mesa OpenGL/Vulkan, libinput) — Angel OS
# ==============================================================================

set -e

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
PROJECT_ROOT=$(cd -- "$SCRIPT_DIR/.." &>/dev/null && pwd)
BUILD_ROOTFS="$PROJECT_ROOT/build/rootfs"

CYAN='\033[1;36m'
GREEN='\033[1;32m'
NC='\033[0m'

echo -e "${CYAN}============================================================${NC}"
echo -e "${CYAN}      [05/13] ANGEL OS — Pilha Gráfica DRM, Mesa & Vulkan   ${NC}"
echo -e "${CYAN}============================================================${NC}"

mkdir -p "$BUILD_ROOTFS/usr/lib/dri"
echo -e "${GREEN}[OK] Estrutura Mesa/DRM/Vulkan inicializada.${NC}"
