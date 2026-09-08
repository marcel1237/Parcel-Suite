#!/bin/sh
set -eu

native=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
project=$(CDPATH= cd -- "$native/../.." && pwd)
version=2026.02
archive=buildroot-$version.tar.xz
url=https://buildroot.org/downloads/$archive
sha256=d54b7ffece06ff28cbb81e28e3de74ea405ca6b77c38fbe8b18fa57bef585f8b
work=${PLAYOS_STAGE1_WORK:-/home/marcel/kernel-work/playos-native-stage1}
source_dir=$work/source
output_dir=$work/output
download_dir=$project/build/playos-native-stage1/downloads
final_dir=$project/build/playos-native-stage1/output

mkdir -p "$work" "$download_dir" "$final_dir"

echo '== PlayOS Stage1: preflight =='
for command in curl sha256sum tar make gcc g++ patch perl python3 rsync file bc; do
  command -v "$command" >/dev/null || { echo "ferramenta ausente: $command" >&2; exit 1; }
done
available_kib=$(df -Pk "$project" | awk 'NR == 2 {print $4}')
required_kib=26214400
if [ -f "$output_dir/.config" ]; then
  required_kib=5242880
fi
test "$available_kib" -ge "$required_kib" || {
  echo "Stage1 exige pelo menos $((required_kib / 1048576)) GiB livres neste estado." >&2
  exit 1
}

if [ ! -s "$download_dir/$archive" ]; then
  curl --fail --location --retry 5 --retry-all-errors -o "$download_dir/$archive.partial" "$url"
  mv "$download_dir/$archive.partial" "$download_dir/$archive"
fi
printf '%s  %s\n' "$sha256" "$archive" > "$download_dir/$archive.sha256"
(cd "$download_dir" && sha256sum -c "$archive.sha256")

if [ ! -f "$source_dir/Makefile" ]; then
  mkdir -p "$source_dir"
  tar -xJf "$download_dir/$archive" -C "$source_dir" --strip-components=1
fi

mkdir -p "$source_dir/board/playos"
cp -a "$native/buildroot/overlay" "$source_dir/board/playos/"
cp "$native/buildroot/post-build.sh" "$source_dir/board/playos/post-build.sh"
mkdir -p "$source_dir/board/playos/pkgtools"
cp "$native/pkgtools/playpkg-install" "$native/pkgtools/playpkg-remove" "$source_dir/board/playos/pkgtools/"
cp "$native/buildroot/playos-stage1_defconfig" "$source_dir/configs/playos_stage1_defconfig"

make -C "$source_dir" O="$output_dir" playos_stage1_defconfig
"$source_dir/utils/config" --file "$output_dir/.config" --set-str BR2_ROOTFS_OVERLAY 'board/playos/overlay'
"$source_dir/utils/config" --file "$output_dir/.config" --set-str BR2_ROOTFS_POST_BUILD_SCRIPT 'board/playos/post-build.sh'
make -C "$source_dir" O="$output_dir" olddefconfig
make -C "$source_dir" O="$output_dir" -j"$(getconf _NPROCESSORS_ONLN)"

cp "$output_dir/images/rootfs.tar" "$final_dir/playos-native-stage1-rootfs.tar.partial"
mv "$final_dir/playos-native-stage1-rootfs.tar.partial" "$final_dir/playos-native-stage1-rootfs.tar"
(cd "$final_dir" && sha256sum playos-native-stage1-rootfs.tar > playos-native-stage1-rootfs.tar.sha256)

echo 'PLAYOS_STAGE1_BUILD=SUCCESS'
echo "ROOTFS=$final_dir/playos-native-stage1-rootfs.tar"
