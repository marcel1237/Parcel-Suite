#!/usr/bin/env bash
set -euo pipefail

if [[ ${1:-} != "--reverse" || $# -ne 2 ]]; then
    echo "uso: $0 --reverse /caminho/da/arvore-kernel" >&2
    exit 2
fi

target=$2
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
kit_dir=$(cd "$script_dir/.." && pwd)

if [[ ! -d "$target/.git" && ! -f "$target/.git" ]]; then
    echo "erro: alvo não é uma árvore Git" >&2
    exit 1
fi

mapfile -t entries < <(sed '/^[[:space:]]*$/d; /^[[:space:]]*#/d' "$kit_dir/series")
for ((i=${#entries[@]}-1; i>=0; i--)); do
    git -C "$target" apply --reverse --check "$kit_dir/${entries[$i]}"
done
for ((i=${#entries[@]}-1; i>=0; i--)); do
    echo "REVERSE ${entries[$i]}"
    git -C "$target" apply --reverse --index "$kit_dir/${entries[$i]}"
done

echo "patchset revertido do índice e da árvore de trabalho"
