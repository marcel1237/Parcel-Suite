#!/bin/sh
set -eu

if [ "$#" -ne 3 ]; then
  echo "uso: $0 IMAGE.deb MODULES.deb MODULES_EXTRA.deb" >&2
  exit 2
fi

profile=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
destination=$profile/config/packages.chroot
manifest=$profile/manifests/noble-kernel.sha256

for package in "$@"; do
  test -f "$package" || { echo "erro: pacote ausente: $package" >&2; exit 1; }
  architecture=$(dpkg-deb -f "$package" Architecture)
  case "$architecture" in amd64|all) ;; *) echo "erro: arquitetura $architecture em $package" >&2; exit 1;; esac
  name=$(dpkg-deb -f "$package" Package)
  case "$name" in
    linux-image-6.8.0-138-generic|linux-modules-6.8.0-138-generic|linux-modules-extra-6.8.0-138-generic) ;;
    *) echo "erro: pacote inesperado: $name" >&2; exit 1 ;;
  esac
  cp -f -- "$package" "$destination/"
done

(cd "$destination" && sha256sum ./*.deb) > "$manifest"
cat "$manifest"
