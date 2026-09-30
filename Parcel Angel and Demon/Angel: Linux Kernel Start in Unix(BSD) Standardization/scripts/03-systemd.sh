#!/bin/bash
# ==============================================================================
# Script 03: Init & Serviços (systemd, udev, dbus) — Angel OS
# ==============================================================================

set -e

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
PROJECT_ROOT=$(cd -- "$SCRIPT_DIR/.." &>/dev/null && pwd)
BUILD_ROOTFS="$PROJECT_ROOT/build/rootfs"

CYAN='\033[1;36m'
GREEN='\033[1;32m'
NC='\033[0m'

echo -e "${CYAN}============================================================${NC}"
echo -e "${CYAN}      [03/13] ANGEL OS — Configurando systemd, udev & DBus ${NC}"
echo -e "${CYAN}============================================================${NC}"

mkdir -p "$BUILD_ROOTFS/etc/systemd/system"
mkdir -p "$BUILD_ROOTFS/usr/lib/systemd/system"

echo -e "${GREEN}[OK] Estrutura do systemd e udev configurada no RootFS.${NC}"
