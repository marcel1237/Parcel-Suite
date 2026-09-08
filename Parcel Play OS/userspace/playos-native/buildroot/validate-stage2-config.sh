#!/bin/sh
set -eu

native=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
project=$(CDPATH= cd -- "$native/../.." && pwd)
source_dir=${PLAYOS_BUILDROOT_SOURCE:-/home/marcel/kernel-work/playos-native-stage1/source}
validation_dir=${PLAYOS_STAGE2_CONFIG_WORK:-/home/marcel/kernel-work/playos-native-stage2-config}

test -f "$source_dir/Makefile" || {
  echo "fonte Buildroot Stage1 ausente: $source_dir" >&2
  exit 1
}

rm -rf "$validation_dir"
mkdir -p "$validation_dir"
cp "$native/buildroot/playos-stage2-graphics_defconfig" \
  "$source_dir/configs/playos_stage2_graphics_defconfig"
make -C "$source_dir" O="$validation_dir" playos_stage2_graphics_defconfig
make -C "$source_dir" O="$validation_dir" olddefconfig

effective="$validation_dir/.config"
for symbol in \
  BR2_PACKAGE_MESA3D BR2_PACKAGE_XSERVER_XORG_SERVER BR2_PACKAGE_XWAYLAND \
  BR2_PACKAGE_WESTON BR2_PACKAGE_PIPEWIRE BR2_PACKAGE_WIREPLUMBER \
  BR2_PACKAGE_QT6BASE BR2_PACKAGE_QT6WAYLAND; do
  grep -qx "$symbol=y" "$effective" || {
    echo "símbolo obrigatório não resolvido: $symbol" >&2
    exit 1
  }
done

echo 'PLAYOS_STAGE2_CONFIG=VALID'
echo "CONFIG=$effective"
