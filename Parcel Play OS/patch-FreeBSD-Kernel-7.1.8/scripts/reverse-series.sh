#!/usr/bin/env bash
set -euo pipefail

[[ ${1:-} == "--reverse" && $# -eq 2 ]] || {
    echo "uso: $0 --reverse /caminho/linux-7.1.8" >&2; exit 2; }
target=$2
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
kit_dir=$(cd "$script_dir/.." && pwd)

git -C "$target" rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
    echo "erro: alvo não é Git" >&2; exit 1; }
mapfile -t entries < <(sed '/^[[:space:]]*$/d; /^[[:space:]]*#/d' "$kit_dir/series")
for ((i=${#entries[@]}-1; i>=0; i--)); do
    git -C "$target" apply -R --check "$kit_dir/${entries[$i]}"
done
for ((i=${#entries[@]}-1; i>=0; i--)); do
    echo "REVERSE ${entries[$i]}"
    git -C "$target" apply -R --index "$kit_dir/${entries[$i]}"
done
echo "patchset revertido"
