#!/bin/sh
set -eu

native=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
project=$(CDPATH= cd -- "$native/../.." && pwd)
work=${PLAYOS_STAGE1_WORK:-/home/marcel/kernel-work/playos-native-stage1}
source_dir=$work/source
output_dir=$work/output
final_dir=$project/build/playos-native-stage2-graphics/output

echo '== PlayOS Stage2 Graphics: preflight =='
test -f "$source_dir/Makefile" || {
  echo 'Execute e conclua o Stage1 antes do Stage2.' >&2
  exit 1
}
for command in make gcc g++ patch perl python3 rsync file bc sha256sum; do
  command -v "$command" >/dev/null || { echo "ferramenta ausente: $command" >&2; exit 1; }
done
available_kib=$(df -Pk "$project" | awk 'NR == 2 {print $4}')
required_kib=15728640
test "$available_kib" -ge "$required_kib" || {
  echo 'Stage2 exige pelo menos 15 GiB livres para continuar com segurança.' >&2
  exit 1
}

mkdir -p "$source_dir/board/playos/pkgtools" "$source_dir/board/playos/overlay/etc" "$final_dir"
cp -a "$native/buildroot/overlay/." "$source_dir/board/playos/overlay/"
cp "$native/buildroot/overlay-stage2/etc/os-release" "$source_dir/board/playos/overlay/etc/os-release"
cp "$native/buildroot/post-build.sh" "$source_dir/board/playos/post-build.sh"
cp "$native/pkgtools/playpkg-install" "$native/pkgtools/playpkg-remove" "$source_dir/board/playos/pkgtools/"
cp "$native/buildroot/playos-stage2-graphics_defconfig" "$source_dir/configs/playos_stage2_graphics_defconfig"

# Reutiliza com segurança os objetos e a toolchain do Stage1. Os artefatos
# finais do Stage1 já estão imutáveis em build/; somente o staging é promovido.
make -C "$source_dir" O="$output_dir" playos_stage2_graphics_defconfig
"$source_dir/utils/config" --file "$output_dir/.config" --set-str BR2_ROOTFS_OVERLAY 'board/playos/overlay'
"$source_dir/utils/config" --file "$output_dir/.config" --set-str BR2_ROOTFS_POST_BUILD_SCRIPT 'board/playos/post-build.sh'
make -C "$source_dir" O="$output_dir" olddefconfig

# O Stage1 constrói PCRE2 somente em 8 bits. Qt 6 seleciona também PCRE2-16,
# mas a troca incremental de defconfig não invalida automaticamente o stamp
# do pacote. Force uma única reconstrução quando a biblioteca nova faltar.
if [ ! -e "$output_dir/host/x86_64-buildroot-linux-gnu/sysroot/usr/lib/libpcre2-16.so" ]; then
  echo '== PlayOS Stage2 Graphics: promovendo PCRE2 para 8+16 bits =='
  make -C "$source_dir" O="$output_dir" pcre2-dirclean
fi
make -C "$source_dir" O="$output_dir" -j"$(getconf _NPROCESSORS_ONLN)"

cp "$output_dir/images/rootfs.tar" "$final_dir/playos-native-stage2-graphics-rootfs.tar.partial"
mv "$final_dir/playos-native-stage2-graphics-rootfs.tar.partial" "$final_dir/playos-native-stage2-graphics-rootfs.tar"
(cd "$final_dir" && sha256sum playos-native-stage2-graphics-rootfs.tar > playos-native-stage2-graphics-rootfs.tar.sha256)

echo 'PLAYOS_STAGE2_GRAPHICS_BUILD=SUCCESS'
echo "ROOTFS=$final_dir/playos-native-stage2-graphics-rootfs.tar"
