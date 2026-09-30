#!/bin/bash
# ==============================================================================
# Script 06: Display Server (Wayland, Protocols, XWayland) — Angel OS
# ==============================================================================

set -e

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
PROJECT_ROOT=$(cd -- "$SCRIPT_DIR/.." &>/dev/null && pwd)
BUILD_ROOTFS="$PROJECT_ROOT/build/rootfs"

CYAN='\033[1;36m'
GREEN='\033[1;32m'
NC='\033[0m'

echo -e "${CYAN}============================================================${NC}"
echo -e "${CYAN}      [06/13] ANGEL OS — Compositor Wayland & XWayland      ${NC}"
echo -e "${CYAN}============================================================${NC}"

mkdir -p "$BUILD_ROOTFS/usr/share/wayland-sessions"
echo -e "${GREEN}[OK] Estrutura Wayland e sessões configurada.${NC}"
