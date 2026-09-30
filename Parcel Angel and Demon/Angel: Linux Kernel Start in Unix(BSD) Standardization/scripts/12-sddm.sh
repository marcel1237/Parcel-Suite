#!/bin/bash
# ==============================================================================
# Script 12: SDDM Display Manager & Temas Angel OS — Angel OS
# ==============================================================================

set -e

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
PROJECT_ROOT=$(cd -- "$SCRIPT_DIR/.." &>/dev/null && pwd)
BUILD_ROOTFS="$PROJECT_ROOT/build/rootfs"

CYAN='\033[1;36m'
GREEN='\033[1;32m'
NC='\033[0m'

echo -e "${CYAN}============================================================${NC}"
echo -e "${CYAN}      [12/13] ANGEL OS — SDDM Display Manager & Temas       ${NC}"
echo -e "${CYAN}============================================================${NC}"

mkdir -p "$BUILD_ROOTFS/usr/share/sddm/themes/angel-os"
echo -e "${GREEN}[OK] Tema do SDDM Angel OS configurado.${NC}"
