#!/bin/sh
set -eu

recipe=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
native=$(CDPATH= cd -- "$recipe/../.." && pwd)
output=${1:-$native/output}
tmp=$(mktemp -d "${TMPDIR:-/tmp}/playos-base-files.XXXXXX")
trap 'rm -rf "$tmp"' EXIT HUP INT TERM

mkdir -p "$tmp/PLAYOS" "$tmp/etc/rc.d"
cp "$recipe/recipe.conf" "$tmp/PLAYOS/meta"
cp "$native/rootfs/etc/os-release" "$tmp/etc/os-release"
cp "$native/rootfs/etc/inittab" "$tmp/etc/inittab"
cp "$native/rootfs/etc/hostname" "$tmp/etc/hostname"
cp "$native/rootfs/etc/rc.d/"rc.* "$tmp/etc/rc.d/"
chmod 0755 "$tmp/etc/rc.d/"rc.*

mkdir -p "$tmp/var/lib/playpkg/installed" "$tmp/var/lib/playpkg/owners"
mkdir -p "$tmp/var/log" "$tmp/mnt" "$tmp/media" "$tmp/run" "$tmp/proc" "$tmp/sys" "$tmp/dev"

"$native/pkgtools/playpkg-build" "$tmp" "$output/playos-base-files-1.0-noarch-1.pxz"
