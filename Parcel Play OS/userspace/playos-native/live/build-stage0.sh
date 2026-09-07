#!/bin/sh
set -eu

native=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
project=$(CDPATH= cd -- "$native/../.." && pwd)
work=${PLAYOS_STAGE0_WORK:-/tmp/playos-native-stage0-work}
final_output=$project/build/playos-native-stage0/output
kernel_packages=${PLAYOS_NOBLE_PACKAGES:-$project/live-build/playos-debian-trixie-xfce-noble-kernel/config/packages.chroot}
busybox_version=1.37.0
busybox_archive=busybox-$busybox_version.tar.bz2
busybox_url=https://busybox.net/downloads/$busybox_archive
busybox_fallback=https://sources.buildroot.net/busybox/$busybox_archive
busybox_sha256=3311dff32e746499f4df0d5df04d7eb396382d7e108bb9250e7b519b837043a4

mkdir -p "$work/sources" "$work/source" "$final_output"
for transient in rootfs kernel-root initramfs iso output; do
  rm -rf "$work/$transient"
done
mkdir -p "$work/rootfs" "$work/kernel-root" "$work/initramfs" "$work/iso/boot/grub" "$work/iso/PLAYOS" "$work/output"

echo '== PlayOS Stage0: preflight =='
for command in curl sha256sum tar make gcc dpkg-deb mksquashfs cpio gzip grub-mkrescue xorriso; do
  command -v "$command" >/dev/null || { echo "ferramenta ausente: $command" >&2; exit 1; }
done

for package in \
  linux-image-6.8.0-138-generic_6.8.0-138.138_amd64.deb \
  linux-modules-6.8.0-138-generic_6.8.0-138.138_amd64.deb \
  linux-modules-extra-6.8.0-138-generic_6.8.0-138.138_amd64.deb
do
  test -s "$kernel_packages/$package" || { echo "kernel ausente: $package" >&2; exit 1; }
done
(cd "$kernel_packages" && sha256sum -c ../../manifests/noble-kernel.sha256)

echo '== PlayOS Stage0: fonte BusyBox =='
if [ ! -s "$work/sources/$busybox_archive" ]; then
  if ! curl --fail --location --retry 2 --retry-all-errors --connect-timeout 20 --max-time 180 \
    -o "$work/sources/$busybox_archive.partial" "$busybox_url"; then
    echo 'Fonte primária indisponível; usando mirror de fontes do Buildroot.'
    curl --fail --location --retry 5 --retry-all-errors --connect-timeout 30 --max-time 600 \
      -o "$work/sources/$busybox_archive.partial" "$busybox_fallback"
  fi
  mv "$work/sources/$busybox_archive.partial" "$work/sources/$busybox_archive"
fi
printf '%s  %s\n' "$busybox_sha256" "$busybox_archive" > "$work/sources/$busybox_archive.sha256"
(cd "$work/sources" && sha256sum -c "$busybox_archive.sha256")

echo '== PlayOS Stage0: compilando BusyBox estático =='
if [ ! -d "$work/source/busybox-$busybox_version" ]; then
  tar -xjf "$work/sources/$busybox_archive" -C "$work/source"
fi
cd "$work/source/busybox-$busybox_version"
make distclean
make defconfig
sed -i 's/^# CONFIG_STATIC is not set/CONFIG_STATIC=y/' .config
# O applet tc não participa do boot do Stage0 e BusyBox 1.37.0 ainda usa
# constantes CBQ removidas dos headers Linux recentes presentes no host.
sed -i 's/^CONFIG_TC=y/# CONFIG_TC is not set/' .config
# O userspace nativo expõe somente o formato PlayOS .pxz e playpkg. Evite
# interfaces de gerenciadores de pacotes pertencentes a outras distribuições.
for foreign_pkg_applet in DPKG DPKG_DEB RPM RPM2CPIO; do
  sed -i "s/^CONFIG_${foreign_pkg_applet}=y/# CONFIG_${foreign_pkg_applet} is not set/" .config
done
make -j"$(getconf _NPROCESSORS_ONLN)"
make CONFIG_PREFIX="$work/rootfs" install

echo '== PlayOS Stage0: rootfs =='
cd "$project"
"$native/packages/playos-base-files/build.sh" "$work/output"
"$native/pkgtools/playpkg-install" --root "$work/rootfs" "$work/output/playos-base-files-1.0-noarch-1.pxz"
mkdir -p "$work/rootfs/etc/rc.d" "$work/rootfs/root" "$work/rootfs/tmp" "$work/rootfs/var/log" "$work/rootfs/var/spool/cron/crontabs" "$work/rootfs/mnt/live"
chmod 1777 "$work/rootfs/tmp"
ln -snf /bin/busybox "$work/rootfs/sbin/init"
printf '%s\n' 'root:x:0:0:root:/root:/bin/sh' > "$work/rootfs/etc/passwd"
printf '%s\n' 'root:x:0:' > "$work/rootfs/etc/group"
printf '%s\n' 'root::19700:0:99999:7:::' > "$work/rootfs/etc/shadow"
printf '%s\n' 'Welcome to PlayOS Native Stage0' > "$work/rootfs/etc/issue"

echo '== PlayOS Stage0: kernel e módulos Noble =='
for package in "$kernel_packages"/*.deb; do
  case "$(basename "$package")" in linux-image-*|linux-modules-*) dpkg-deb -x "$package" "$work/kernel-root" ;; esac
done
cp "$work/kernel-root/boot/vmlinuz-6.8.0-138-generic" "$work/iso/boot/vmlinuz"
mkdir -p "$work/initramfs/lib"
cp -a "$work/kernel-root/lib/modules" "$work/initramfs/lib/"

echo '== PlayOS Stage0: SquashFS =='
mksquashfs "$work/rootfs" "$work/iso/PLAYOS/PLAYOS.squashfs" -noappend -all-root -comp xz
sha256sum "$work/iso/PLAYOS/PLAYOS.squashfs" > "$work/iso/PLAYOS/PLAYOS.squashfs.sha256"

echo '== PlayOS Stage0: initramfs =='
cp -a "$work/rootfs/bin" "$work/rootfs/sbin" "$work/initramfs/"
mkdir -p "$work/initramfs/proc" "$work/initramfs/sys" "$work/initramfs/dev" "$work/initramfs/run" "$work/initramfs/media" "$work/initramfs/lower" "$work/initramfs/upper" "$work/initramfs/newroot"
cp "$native/live/init" "$work/initramfs/init"
chmod 0755 "$work/initramfs/init"
(cd "$work/initramfs" && find . -print0 | cpio --null -o --format=newc --owner=0:0 | gzip -9) > "$work/iso/boot/initramfs.img"
cp "$native/live/grub.cfg" "$work/iso/boot/grub/grub.cfg"

echo '== PlayOS Stage0: ISO híbrida =='
grub-mkrescue -o "$work/output/playos-native-stage0-noble-amd64.iso" "$work/iso"
(cd "$work/output" && sha256sum playos-native-stage0-noble-amd64.iso > playos-native-stage0-noble-amd64.iso.sha256)
xorriso -indev "$work/output/playos-native-stage0-noble-amd64.iso" -report_el_torito plain
cp "$work/output/playos-native-stage0-noble-amd64.iso" "$final_output/playos-native-stage0-noble-amd64.iso.partial"
cp "$work/output/playos-native-stage0-noble-amd64.iso.sha256" "$final_output/playos-native-stage0-noble-amd64.iso.sha256"
mv "$final_output/playos-native-stage0-noble-amd64.iso.partial" "$final_output/playos-native-stage0-noble-amd64.iso"

echo 'PLAYOS_STAGE0_BUILD=SUCCESS'
echo "ISO=$final_output/playos-native-stage0-noble-amd64.iso"
