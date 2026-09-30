#!/bin/bash
# ==============================================================================
# Script 02: RootFS Base (Layout FHS, BusyBox, Coreutils, kmod) — Angel OS
# ==============================================================================

set -e

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
PROJECT_ROOT=$(cd -- "$SCRIPT_DIR/.." &>/dev/null && pwd)
BUILD_ROOTFS="$PROJECT_ROOT/build/rootfs"

CYAN='\033[1;36m'
GREEN='\033[1;32m'
NC='\033[0m'

echo -e "${CYAN}============================================================${NC}"
echo -e "${CYAN}      [02/13] ANGEL OS — Inicializando Layout FHS e RootFS  ${NC}"
echo -e "${CYAN}============================================================${NC}"

# Criando estrutura FHS
mkdir -p "$BUILD_ROOTFS"/{bin,boot,dev,etc,home,proc,root,run,sbin,sys,tmp,var}
mkdir -p "$BUILD_ROOTFS/usr"/{bin,include,lib,sbin,share}
mkdir -p "$BUILD_ROOTFS/var"/{log,tmp,run}

# Criando links simbólicos FHS modernos
ln -sf usr/bin "$BUILD_ROOTFS/bin" 2>/dev/null || true
ln -sf usr/sbin "$BUILD_ROOTFS/sbin" 2>/dev/null || true
ln -sf usr/lib "$BUILD_ROOTFS/lib" 2>/dev/null || true
ln -sf usr/lib "$BUILD_ROOTFS/lib64" 2>/dev/null || true

# Criando /etc/os-release
cat << 'EOF' > "$BUILD_ROOTFS/etc/os-release"
NAME="Angel OS"
VERSION="1.0.0-alpha (KDE-Full)"
ID=angelos
ID_LIKE="unix-like"
PRETTY_NAME="Angel OS KDE-Full v1.0.0 (Seraphin 7.3)"
ANSI_COLOR="1;36"
HOME_URL="https://angelos.org"
EOF

# Criando /etc/hostname
echo "angelos" > "$BUILD_ROOTFS/etc/hostname"

echo -e "${GREEN}[OK] Estrutura FHS e arquivos de sistema criados em $BUILD_ROOTFS${NC}"
