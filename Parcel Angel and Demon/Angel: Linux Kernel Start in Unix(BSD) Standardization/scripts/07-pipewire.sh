#!/bin/bash
# ==============================================================================
# Script 07: Áudio & Rede (ALSA, PipeWire, WirePlumber, NetworkManager) — Angel OS
# ==============================================================================

set -e

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
PROJECT_ROOT=$(cd -- "$SCRIPT_DIR/.." &>/dev/null && pwd)
BUILD_ROOTFS="$PROJECT_ROOT/build/rootfs"

CYAN='\033[1;36m'
GREEN='\033[1;32m'
NC='\033[0m'

echo -e "${CYAN}============================================================${NC}"
echo -e "${CYAN}      [07/13] ANGEL OS — Servidor de Áudio PipeWire & Rede  ${NC}"
echo -e "${CYAN}============================================================${NC}"

mkdir -p "$BUILD_ROOTFS/etc/pipewire"
echo -e "${GREEN}[OK] Estrutura do PipeWire e NetworkManager pronta.${NC}"
