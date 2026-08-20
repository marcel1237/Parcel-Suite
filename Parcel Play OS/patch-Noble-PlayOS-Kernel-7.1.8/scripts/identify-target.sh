#!/usr/bin/env bash
set -euo pipefail

[[ $# -eq 1 ]] || { echo "uso: $0 /caminho/linux-7.1.8" >&2; exit 2; }
target=$1

version=$(awk '/^VERSION =/{print $3}' "$target/Makefile")
patchlevel=$(awk '/^PATCHLEVEL =/{print $3}' "$target/Makefile")
sublevel=$(awk '/^SUBLEVEL =/{print $3}' "$target/Makefile")
[[ "$version.$patchlevel.$sublevel" == "7.1.8" ]] || {
    echo "alvo rejeitado: esperado Linux 7.1.8, obtido $version.$patchlevel.$sublevel" >&2
    exit 1
}
echo "Linux $version.$patchlevel.$sublevel"
