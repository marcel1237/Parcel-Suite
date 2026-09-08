#!/bin/sh
set -eu

target=$1
board=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

mkdir -p "$target/etc/rc.d" "$target/usr/sbin" "$target/var/lib/playpkg/installed" "$target/var/lib/playpkg/owners"
cp "$board/pkgtools/playpkg-install" "$board/pkgtools/playpkg-remove" "$target/usr/sbin/"
mkdir -p "$target/usr/lib"
cp "$board/overlay/etc/os-release" "$target/usr/lib/os-release"
ln -snf ../usr/lib/os-release "$target/etc/os-release"
chmod 0755 "$target/etc/rc.d/rc.S" "$target/etc/rc.d/rc.M" "$target/etc/rc.d/rc.6" "$target/usr/sbin/playpkg-install" "$target/usr/sbin/playpkg-remove"

for foreign in apt apt-get dpkg dpkg-deb rpm rpm2cpio; do
  test ! -e "$target/usr/bin/$foreign" || {
    echo "interface estrangeira inesperada no rootfs: $foreign" >&2
    exit 1
  }
done
