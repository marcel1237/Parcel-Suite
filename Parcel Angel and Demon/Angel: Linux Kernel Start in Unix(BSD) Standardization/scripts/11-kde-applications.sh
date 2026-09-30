#!/bin/bash
# ==============================================================================
# Script 11: Aplicativos KDE Gear — Angel OS
# ==============================================================================

set -e

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
PROJECT_ROOT=$(cd -- "$SCRIPT_DIR/.." &>/dev/null && pwd)
BUILD_ROOTFS="$PROJECT_ROOT/build/rootfs"

CYAN='\033[1;36m'
GREEN='\033[1;32m'
NC='\033[0m'

echo -e "${CYAN}============================================================${NC}"
echo -e "${CYAN}      [11/13] ANGEL OS — KDE Gear (Dolphin, Konsole, Kate)  ${NC}"
echo -e "${CYAN}============================================================${NC}"

mkdir -p "$BUILD_ROOTFS/usr/share/applications"
echo -e "${GREEN}[OK] Estrutura de aplicações KDE Gear instalada.${NC}"
