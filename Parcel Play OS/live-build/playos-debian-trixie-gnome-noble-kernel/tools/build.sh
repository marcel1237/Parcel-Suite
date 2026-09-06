#!/bin/sh
set -eu

profile=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$profile"

./tools/preflight.sh

if [ "$(id -u)" -ne 0 ]; then
  echo 'erro: execute o build em ambiente Debian trixie com sudo' >&2
  exit 1
fi

lb clean --purge
lb config
lb build

iso=$(find . -maxdepth 1 -type f -name '*.iso' -print -quit)
test -n "$iso" || { echo 'erro: lb build terminou sem ISO' >&2; exit 1; }
sha256sum "$iso" > "${iso}.sha256"
echo "ISO criada: $iso"
