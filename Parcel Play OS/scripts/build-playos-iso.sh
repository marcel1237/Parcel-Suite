#!/bin/sh
# Build PlayOS ISO - v1.1.2
# Ajuste técnico para boot híbrido e partição EFI
set -eu

project_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
iso_tree="$project_dir/build/resolute-mvp/work/iso-tree"
output_iso="$project_dir/build/resolute-mvp/output/playos-26.04-amd64.iso"
grub_cfg_source="$project_dir/config/boot/grub-playos.cfg"
original_iso="$project_dir/build/resolute-mvp/download/resolute-desktop-amd64.iso"

echo ">> Iniciando build da ISO PlayOS..."

# 1. Verificar ISO Original (Fonte do Boot EFI)
if [ ! -f "$original_iso" ]; then
    echo "ERRO: ISO original não encontrada em $original_iso"
    exit 1
fi

# 2. Garantir permissões de escrita
echo "Ajustando permissões da árvore ISO..."
chmod -R u+w "$iso_tree"

# 3. Atualizar menu GRUB
if [ -f "$grub_cfg_source" ]; then
    echo "Aplicando branding PlayOS ao menu GRUB..."
    cp "$grub_cfg_source" "$iso_tree/boot/grub/grub.cfg"
    cp "$grub_cfg_source" "$iso_tree/boot/grub/loopback.cfg"
fi

# 4. Atualizar fontes Subiquity
install_sources="$iso_tree/casper/install-sources.yaml"
if [ -f "$install_sources" ]; then
    echo "Customizando opções do instalador Subiquity..."
    sed -i 's/Ubuntu Desktop/PlayOS Desktop/g' "$install_sources"
fi

# 5. Repacotamento com xorriso (REPLAY do boot original)
echo "Repacotando ISO com xorriso (Usando boot da ISO original)..."

# Note: Extraímos a partição 2 e o MBR diretamente da ISO original para garantir o boot.
xorriso -as mkisofs \
    -r -V "PLAYOS_2604" \
    -J -joliet-long -l \
    -b boot/grub/i386-pc/eltorito.img \
    -c boot.catalog \
    -no-emul-boot -boot-load-size 4 -boot-info-table \
    --grub2-boot-info \
    --grub2-mbr --interval:local_fs:0s-15s:zero_mbrpt,zero_gpt:"$original_iso" \
    --protective-msdos-label \
    -partition_cyl_align off \
    -partition_offset 16 \
    --mbr-force-bootable \
    -append_partition 2 28732ac11ff8d211ba4b00a0c93ec93b --interval:local_fs:12254148d-12264443d::"$original_iso" \
    -appended_part_as_gpt \
    -iso_mbr_part_type a2a0d0ebe5b9334487c068b6b72699c7 \
    -eltorito-alt-boot \
    -e '--interval:appended_partition_2:all::' \
    -no-emul-boot \
    -isohybrid-gpt-basdat \
    -o "$output_iso" "$iso_tree"

echo ">> ISO gerada com sucesso em: $output_iso"
sha256sum "$output_iso" > "$output_iso.sha256"
