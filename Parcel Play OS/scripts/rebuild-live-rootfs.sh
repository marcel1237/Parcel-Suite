#!/bin/bash
# rebuild-live-rootfs.sh - Transforma o Live CD do Ubuntu em PlayOS
# v1.1.0 - Suporte a injeção de Assets (Wallpaper/Logos)
# Este script EXIGE sudo e ferramentas squashfs-tools instaladas.

set -e

PROJECT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
ISO_TREE="$PROJECT_DIR/build/resolute-mvp/work/iso-tree"
WORK_DIR="$PROJECT_DIR/build/work"
ROOTFS="$WORK_DIR/rootfs"
SQUASHFS_FILE="$ISO_TREE/casper/minimal.squashfs"
ASSETS="$PROJECT_DIR/assets"

echo ">> Iniciando reconstrução do RootFS Live..."

# 1. Preparar ambiente
sudo mkdir -p "$ROOTFS"
sudo rm -rf "$ROOTFS"/*

# 2. Extrair o sistema original
echo "Extraindo SquashFS (isso pode demorar...)"
sudo unsquashfs -d "$ROOTFS" "$SQUASHFS_FILE"

# 3. Injetar Ativos Físicos (Wallpapers e Logos)
echo "Injetando ativos visuais do diretório assets/..."
if [ -f "$ASSETS/playos-wallpaper.png" ]; then
    echo ">> Injetando Wallpaper PlayOS..."
    sudo mkdir -p "$ROOTFS/usr/share/backgrounds/playos"
    sudo cp "$ASSETS/playos-wallpaper.png" "$ROOTFS/usr/share/backgrounds/playos/default.png"
fi

if [ -f "$ASSETS/logo.svg" ]; then
    echo ">> Injetando Logo PlayOS..."
    sudo mkdir -p "$ROOTFS/usr/share/icons/hicolor/scalable/apps"
    sudo cp "$ASSETS/logo.svg" "$ROOTFS/usr/share/icons/hicolor/scalable/apps/distributor-logo-ubuntu.svg"
fi

# 4. Aplicar a "Metamorfose" via script interno
echo "Aplicando branding PlayOS via chroot..."
sudo cp "$PROJECT_DIR/scripts/apply-internal-branding.sh" "$ROOTFS/tmp/"
sudo cp "$PROJECT_DIR/scripts/apply-distro-def.sh" "$ROOTFS/tmp/"
sudo chroot "$ROOTFS" /bin/bash /tmp/apply-distro-def.sh
sudo rm "$ROOTFS/tmp/apply-distro-def.sh"
sudo chroot "$ROOTFS" /bin/bash /tmp/apply-internal-branding.sh
sudo cp "$PROJECT_DIR/scripts/apply-distro-def.sh" "$ROOTFS/tmp/"
sudo chroot "$ROOTFS" /bin/bash /tmp/apply-distro-def.sh
sudo rm "$ROOTFS/tmp/apply-distro-def.sh"
sudo rm "$ROOTFS/tmp/apply-internal-branding.sh"
sudo cp "$PROJECT_DIR/scripts/apply-distro-def.sh" "$ROOTFS/tmp/"
sudo chroot "$ROOTFS" /bin/bash /tmp/apply-distro-def.sh
sudo rm "$ROOTFS/tmp/apply-distro-def.sh"

# 5. Compactar novamente com ZSTD (Alta Performance)
echo "Compactando novo SquashFS com ZSTD..."
sudo rm "$SQUASHFS_FILE"
sudo mksquashfs "$ROOTFS" "$SQUASHFS_FILE" -comp zstd -b 1M -noappend

# 6. Atualizar manifestos
echo "Atualizando manifestos da ISO..."
sudo chmod u+w "$ISO_TREE/casper/minimal.manifest"
sudo chroot "$ROOTFS" dpkg-query -W --showformat='${Package} ${Version}\n' > "$ISO_TREE/casper/minimal.manifest"

echo ">> Reconstrução concluída. Agora você pode rodar ./scripts/build-playos-iso.sh"
