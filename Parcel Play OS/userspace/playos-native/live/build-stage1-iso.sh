#!/bin/sh
set -eu

native=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
project=$(CDPATH= cd -- "$native/../.." && pwd)
work=${PLAYOS_STAGE1_ISO_WORK:-/home/marcel/kernel-work/playos-native-stage1-iso}
stage0_dir=$project/build/playos-native-stage0/output
stage0_iso=$stage0_dir/playos-native-stage0-noble-amd64.iso
stage1_dir=$project/build/playos-native-stage1/output
stage1_rootfs=$stage1_dir/playos-native-stage1-rootfs.tar
kernel_packages=${PLAYOS_NOBLE_PACKAGES:-$project/live-build/playos-debian-trixie-xfce-noble-kernel/config/packages.chroot}
final_dir=$project/build/playos-native-stage1-iso/output
iso_name=playos-native-stage1-noble-amd64.iso

echo '== PlayOS Stage1 ISO: preflight =='
for command in sha256sum tar dpkg-deb mksquashfs grub-mkrescue xorriso; do
  command -v "$command" >/dev/null || { echo "ferramenta ausente: $command" >&2; exit 1; }
done
(cd "$stage0_dir" && sha256sum -c playos-native-stage0-noble-amd64.iso.sha256)
(cd "$stage1_dir" && sha256sum -c playos-native-stage1-rootfs.tar.sha256)
(cd "$kernel_packages" && sha256sum -c ../../manifests/noble-kernel.sha256)

for transient in rootfs kernel-root iso output; do
  rm -rf "$work/$transient"
done
mkdir -p "$work/rootfs" "$work/kernel-root" "$work/iso/boot/grub" "$work/iso/PLAYOS" "$work/output" "$final_dir"

echo '== PlayOS Stage1 ISO: extraindo rootfs e boot Stage0 =='
tar -xf "$stage1_rootfs" -C "$work/rootfs"
xorriso -osirrox on -indev "$stage0_iso" -extract /boot/vmlinuz "$work/iso/boot/vmlinuz"
xorriso -osirrox on -indev "$stage0_iso" -extract /boot/initramfs.img "$work/iso/boot/initramfs.img"

echo '== PlayOS Stage1 ISO: instalando módulos Noble =='
for package in "$kernel_packages"/*.deb; do
  case "$(basename "$package")" in linux-modules-*) dpkg-deb -x "$package" "$work/kernel-root" ;; esac
done
mkdir -p "$work/rootfs/lib"
cp -a "$work/kernel-root/lib/modules" "$work/rootfs/lib/"

test -x "$work/rootfs/sbin/init"
test -x "$work/rootfs/sbin/udevd"
test "$(sed -n 's/^ID=//p' "$work/rootfs/usr/lib/os-release")" = playos
for foreign in apt apt-get dpkg dpkg-deb rpm rpm2cpio; do
  test ! -e "$work/rootfs/usr/bin/$foreign" || { echo "interface estrangeira encontrada: $foreign" >&2; exit 1; }
done

echo '== PlayOS Stage1 ISO: SquashFS =='
mksquashfs "$work/rootfs" "$work/iso/PLAYOS/PLAYOS.squashfs" -noappend -all-root -comp xz
(cd "$work/iso/PLAYOS" && sha256sum PLAYOS.squashfs > PLAYOS.squashfs.sha256)
cp "$native/live/grub-stage1.cfg" "$work/iso/boot/grub/grub.cfg"

echo '== PlayOS Stage1 ISO: ISO híbrida =='
grub-mkrescue -o "$work/output/$iso_name" "$work/iso"
(cd "$work/output" && sha256sum "$iso_name" > "$iso_name.sha256")
xorriso -indev "$work/output/$iso_name" -report_el_torito plain
cp "$work/output/$iso_name" "$final_dir/$iso_name.partial"
cp "$work/output/$iso_name.sha256" "$final_dir/$iso_name.sha256"
mv "$final_dir/$iso_name.partial" "$final_dir/$iso_name"

echo 'PLAYOS_STAGE1_ISO_BUILD=SUCCESS'
echo "ISO=$final_dir/$iso_name"
