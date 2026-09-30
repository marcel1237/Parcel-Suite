#!/bin/bash
# ==============================================================================
# Script 10: KDE Plasma 6 Desktop & KWin — Angel OS
# ==============================================================================

set -e

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
PROJECT_ROOT=$(cd -- "$SCRIPT_DIR/.." &>/dev/null && pwd)
BUILD_ROOTFS="$PROJECT_ROOT/build/rootfs"

CYAN='\033[1;36m'
GREEN='\033[1;32m'
NC='\033[0m'

echo -e "${CYAN}============================================================${NC}"
echo -e "${CYAN}      [10/13] ANGEL OS — KDE Plasma 6 Desktop & KWin        ${NC}"
echo -e "${CYAN}============================================================${NC}"

mkdir -p "$BUILD_ROOTFS/usr/share/plasma"
echo -e "${GREEN}[OK] Estrutura do KDE Plasma 6 Desktop configurada.${NC}"
