#!/bin/sh
# Build PlayOS ISO - substituição de branding Ubuntu -> PlayOS
set -eu

project_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
iso_tree="$project_dir/build/resolute-mvp/work/iso-tree"
output_iso="$project_dir/build/resolute-mvp/output/playos-26.04-amd64.iso"
grub_cfg_source="$project_dir/config/boot/grub-playos.cfg"

echo ">> Iniciando build da ISO PlayOS..."

# 1. Atualizar menu GRUB com branding PlayOS
if [ -f "$grub_cfg_source" ]; then
    echo "Aplicando branding PlayOS ao menu GRUB..."
    chmod u+w "$iso_tree/boot/grub/grub.cfg" "$iso_tree/boot/grub/loopback.cfg"
    cp "$grub_cfg_source" "$iso_tree/boot/grub/grub.cfg"
    cp "$grub_cfg_source" "$iso_tree/boot/grub/loopback.cfg"
fi

# 2. Gerar ISO com Volume ID PlayOS
# Baseado nos parâmetros originais do Resolute daily build
echo "Repacotando ISO com xorriso..."
xorriso -as mkisofs \
    -r -V "PlayOS-26.04-amd64" \
    -J -joliet-long -l \
    -b boot/grub/i386-pc/eltorito.img \
    -c boot.catalog \
    -no-emul-boot -boot-load-size 4 -boot-info-table \
    --grub2-boot-info \
    --grub2-mbr /usr/lib/grub/i386-pc/boot_hybrid.img \
    -eltorito-alt-boot \
    -e '--interval:appended_partition_2:all::' \
    -no-emul-boot \
    -isohybrid-gpt-basdat \
    -o "$output_iso" "$iso_tree"

echo ">> ISO gerada com sucesso em: $output_iso"
sha256sum "$output_iso" > "$output_iso.sha256"
