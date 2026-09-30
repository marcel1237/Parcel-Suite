#!/bin/bash
# ==============================================================================
# Script 13: Geração da ISO Final (Angel-OS-KDE-Full.iso) — Angel OS
# ==============================================================================

set -e

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
PROJECT_ROOT=$(cd -- "$SCRIPT_DIR/.." &>/dev/null && pwd)
BUILD_ISO="$PROJECT_ROOT/build/iso"
BUILD_ROOTFS="$PROJECT_ROOT/build/rootfs"

CYAN='\033[1;36m'
GREEN='\033[1;32m'
NC='\033[0m'

echo -e "${CYAN}============================================================${NC}"
echo -e "${CYAN}      [13/13] ANGEL OS — Empacotando ISO Angel-OS-KDE-Full  ${NC}"
echo -e "${CYAN}============================================================${NC}"

mkdir -p "$BUILD_ISO"
OUTPUT_ISO="$BUILD_ISO/Angel-OS-KDE-Full.iso"

echo -e "${GREEN}[OK] Diretório da ISO preparado: $BUILD_ISO${NC}"
echo -e "Destino final da ISO: $OUTPUT_ISO"
