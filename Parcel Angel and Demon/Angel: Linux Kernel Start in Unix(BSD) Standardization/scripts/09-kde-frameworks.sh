#!/bin/bash
# ==============================================================================
# Script 09: KDE Frameworks 6 — Angel OS
# ==============================================================================

set -e

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
PROJECT_ROOT=$(cd -- "$SCRIPT_DIR/.." &>/dev/null && pwd)
BUILD_ROOTFS="$PROJECT_ROOT/build/rootfs"

CYAN='\033[1;36m'
GREEN='\033[1;32m'
NC='\033[0m'

echo -e "${CYAN}============================================================${NC}"
echo -e "${CYAN}      [09/13] ANGEL OS — KDE Frameworks 6                   ${NC}"
echo -e "${CYAN}============================================================${NC}"

mkdir -p "$BUILD_ROOTFS/usr/share/kf6"
echo -e "${GREEN}[OK] Estrutura do KDE Frameworks 6 pronta.${NC}"
