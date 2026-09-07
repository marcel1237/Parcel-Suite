#!/bin/sh
set -eu

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
required_kib=$((30 * 1024 * 1024))
available_kib=$(df -Pk "$root" | awk 'NR == 2 { print $4 }')

for command in lb debootstrap mksquashfs xorriso; do
  command -v "$command" >/dev/null || {
    echo "Ferramenta ausente: $command" >&2
    exit 1
  }
done

if [ "$available_kib" -lt "$required_kib" ]; then
  echo "Espaço insuficiente: KDE Full exige pelo menos 30 GiB livres no staging." >&2
  echo "Disponível: $((available_kib / 1024 / 1024)) GiB" >&2
  exit 1
fi

echo 'Preflight aprovado.'
