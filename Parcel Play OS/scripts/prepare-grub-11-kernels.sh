#!/bin/sh
set -eu

project_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
iso_tree=${1:-"$project_dir/build/resolute-mvp/work/iso-tree"}
source_cfg="$project_dir/config/boot/grub-11-kernels.cfg"
target_cfg="$iso_tree/boot/grub/grub.cfg"
loopback_cfg="$iso_tree/boot/grub/loopback.cfg"

if [ ! -f "$iso_tree/casper/vmlinuz" ] || [ ! -f "$iso_tree/casper/initrd" ]; then
    echo "erro: kernel/initrd Ubuntu ausentes em $iso_tree/casper" >&2
    exit 1
fi

if [ ! -f "$source_cfg" ]; then
    echo "erro: configuração fonte ausente: $source_cfg" >&2
    exit 1
fi

grub-script-check "$source_cfg"

# A extração por xorriso preserva diretórios 0555 da mídia somente leitura.
# A mudança abaixo afeta apenas a cópia de trabalho informada em iso_tree.
chmod u+w "$iso_tree/EFI" "$iso_tree/boot/grub"
chmod u+w "$target_cfg"
chmod u+w "$loopback_cfg"

mkdir -p \
    "$iso_tree/parcel/linux/arch" \
    "$iso_tree/parcel/linux/opensuse" \
    "$iso_tree/parcel/linux/fedora" \
    "$iso_tree/parcel/linux/debian" \
    "$iso_tree/parcel/linux/gentoo" \
    "$iso_tree/parcel/linux/centos" \
    "$iso_tree/parcel/linux/oracle" \
    "$iso_tree/EFI/parcel/freebsd" \
    "$iso_tree/EFI/parcel/netbsd" \
    "$iso_tree/EFI/parcel/openbsd"

if [ ! -f "$target_cfg.ubuntu-original" ]; then
    cp "$target_cfg" "$target_cfg.ubuntu-original"
fi
cp "$source_cfg" "$target_cfg"
grub-script-check "$target_cfg"

if [ ! -f "$loopback_cfg.ubuntu-original" ]; then
    cp "$loopback_cfg" "$loopback_cfg.ubuntu-original"
fi
cp "$source_cfg" "$loopback_cfg"
grub-script-check "$loopback_cfg"

echo "Menu Parcel instalado em: $target_cfg"
echo "Ubuntu: disponível"

for flavor in arch opensuse fedora debian gentoo centos oracle; do
    if [ -f "$iso_tree/parcel/linux/$flavor/vmlinuz" ] && [ -f "$iso_tree/parcel/linux/$flavor/initrd" ]; then
        echo "$flavor: disponível"
    else
        echo "$flavor: indisponível (esperando vmlinuz + initrd)"
    fi
done

for payload in \
    freebsd/loader.efi \
    netbsd/bootx64.efi \
    openbsd/BOOTX64.EFI
do
    if [ -f "$iso_tree/EFI/parcel/$payload" ]; then
        echo "$payload: disponível"
    else
        echo "$payload: indisponível"
    fi
done
