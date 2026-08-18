#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
    echo "uso: $0 /caminho/da/arvore-kernel" >&2
    exit 2
fi

target=$1
if [[ ! -d "$target/.git" && ! -f "$target/.git" ]]; then
    echo "erro: alvo não é uma árvore Git: $target" >&2
    exit 1
fi

physical=$(cd "$target" && pwd -P)
version=$(sed -n -E \
    -e 's/^VERSION = (.*)$/\1/p' \
    -e 's/^PATCHLEVEL = (.*)$/\1/p' \
    -e 's/^SUBLEVEL = (.*)$/\1/p' \
    "$target/Makefile" | paste -sd.)

printf 'path=%s\n' "$physical"
printf 'commit=%s\n' "$(git -C "$target" rev-parse HEAD)"
printf 'branch=%s\n' "$(git -C "$target" branch --show-current)"
printf 'shallow=%s\n' "$(git -C "$target" rev-parse --is-shallow-repository)"
printf 'kernel_version=%s\n' "$version"
printf 'changelog=%s\n' "$(sed -n '1p' "$target/debian.master/changelog" 2>/dev/null || true)"
printf 'remote=%s\n' "$(git -C "$target" remote get-url origin 2>/dev/null || true)"
