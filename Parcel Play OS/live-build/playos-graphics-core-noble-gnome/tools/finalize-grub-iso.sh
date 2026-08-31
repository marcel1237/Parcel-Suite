#!/bin/sh
set -eu

output=${1:-playos-noble-gnome-calamares-amd64.iso}

if [ -d binary ]; then
	iso_tree=binary
elif [ -d chroot/binary ]; then
	iso_tree=chroot/binary
else
	echo "erro: árvore binária não encontrada em binary/ ou chroot/binary/" >&2
	exit 1
fi

command -v grub-mkrescue >/dev/null 2>&1 || {
	echo "erro: grub-mkrescue não está instalado" >&2
	exit 1
}
command -v xorriso >/dev/null 2>&1 || {
	echo "erro: xorriso não está instalado" >&2
	exit 1
}

temporary="${output}.tmp.$$"
trap 'rm -f "$temporary"' EXIT HUP INT TERM
grub-mkrescue -o "$temporary" "$iso_tree"
mv -f "$temporary" "$output"
trap - EXIT HUP INT TERM
sha256sum "$output"
