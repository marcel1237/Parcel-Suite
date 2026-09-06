#!/bin/sh
set -eu

profile=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

version=$(lb --version 2>&1 || true)
case "$version" in
  3.0~a57*)
    echo 'erro: live-build Ubuntu 3.0 antigo detectado; use live-build do Debian 13 trixie' >&2
    exit 1
    ;;
esac

for command in lb debootstrap mksquashfs xorriso dpkg-deb sha256sum; do
  command -v "$command" >/dev/null 2>&1 || { echo "erro: comando ausente: $command" >&2; exit 1; }
done

count=$(find "$profile/config/packages.chroot" -maxdepth 1 -type f -name '*.deb' | wc -l)
test "$count" -eq 3 || { echo "erro: esperados 3 pacotes .deb do kernel Noble; encontrados $count" >&2; exit 1; }

(cd "$profile/config/packages.chroot" && sha256sum -c ../../manifests/noble-kernel.sha256)

if grep -R -n -E '^(calamares|calamares-data|calamares-settings-debian|subiquity|curtin|casper)$' "$profile/config/package-lists"; then
  echo 'erro: instalador presente na lista' >&2
  exit 1
fi

echo 'preflight estático concluído'
