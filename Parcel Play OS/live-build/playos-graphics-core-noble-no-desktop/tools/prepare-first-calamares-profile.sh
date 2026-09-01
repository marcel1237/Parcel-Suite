#!/bin/sh
set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
profile_dir=$(CDPATH= cd -- "$script_dir/.." && pwd)
destination=${1:-}

if [ -z "$destination" ]; then
    echo "uso: $0 DIRETORIO-NOVO" >&2
    exit 2
fi

case "$destination" in
    /|.|..|"$profile_dir"|"$profile_dir"/*)
        echo "erro: destino inseguro ou dentro do perfil-fonte: $destination" >&2
        exit 2
        ;;
esac

if [ -e "$destination" ]; then
    echo "erro: o destino já existe: $destination" >&2
    exit 2
fi

mkdir -p "$destination"
cp -a "$profile_dir/." "$destination/"
cp "$profile_dir/legacy-first-iso/settings.conf" \
    "$destination/config/includes.chroot/etc/calamares/settings.conf"

package_list="$destination/config/package-lists/playos-graphics-core.list.chroot"
sed -i -e '/^subiquity-server$/d' -e '/^curtin$/d' -e '/^casper$/d' \
    "$package_list"

rm -rf \
    "$destination/config/includes.chroot/usr/lib/calamares/modules/subiquity_bridge" \
    "$destination/config/includes.chroot/usr/lib/calamares/modules/subiquity_exec"

if grep -qxE '(subiquity-server|curtin|casper)' "$package_list"; then
    echo 'erro: pacote do backend híbrido permaneceu no perfil' >&2
    exit 1
fi
if find "$destination/config/includes.chroot/usr/lib/calamares/modules" \
    -maxdepth 1 -type d -name 'subiquity_*' | grep -q .; then
    echo 'erro: módulo híbrido permaneceu no perfil' >&2
    exit 1
fi

grep -q '^      - unpackfs$' \
    "$destination/config/includes.chroot/etc/calamares/settings.conf"
grep -q '^      - bootloader$' \
    "$destination/config/includes.chroot/etc/calamares/settings.conf"
grep -q '^live-boot$' "$package_list"

echo "perfil histórico preparado em: $destination"
echo 'pipeline obrigatório: live-build + live-boot + /live + boot=live'
