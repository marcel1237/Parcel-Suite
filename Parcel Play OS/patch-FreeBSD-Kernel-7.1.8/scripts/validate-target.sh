#!/usr/bin/env bash
set -euo pipefail

compatibility=0
if [[ ${1:-} == "--compatibility-only" ]]; then compatibility=1; shift; fi
[[ $# -eq 1 ]] || { echo "uso: $0 [--compatibility-only] /caminho/linux-7.1.8" >&2; exit 2; }
target=$1
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

for required in Makefile Kconfig kernel/sched/ext.c kernel/trace/trace_boot.c \
    lib/fault-inject.c net/tls/tls_main.c drivers/misc/ntsync.c; do
    [[ -e "$target/$required" ]] || { echo "erro: ausente: $required" >&2; exit 1; }
done

version=$(sed -n -E \
    -e 's/^VERSION = (.*)$/\1/p' \
    -e 's/^PATCHLEVEL = (.*)$/\1/p' \
    -e 's/^SUBLEVEL = (.*)$/\1/p' "$target/Makefile" | paste -sd.)
[[ "$version" == 7.1.8 ]] || { echo "erro: esperado 7.1.8, encontrado $version" >&2; exit 1; }

physical=$(cd "$target" && pwd -P)
if [[ $compatibility -eq 0 && "$physical" =~ [[:space:]:] ]]; then
    echo "erro: Kbuild exige caminho sem espaços ou dois-pontos" >&2
    exit 1
fi

if [[ $compatibility -eq 0 ]]; then
    git_root=$(git -C "$target" rev-parse --show-toplevel 2>/dev/null || true)
    [[ -n "$git_root" && $(cd "$git_root" && pwd -P) == "$physical" ]] || {
        echo "erro: alvo final deve possuir histórico Git verificável" >&2; exit 1; }
    [[ -z $(git -C "$target" status --porcelain=v1) ]] || {
        echo "erro: árvore Git possui alterações locais" >&2; exit 1; }
    [[ -n $(git -C "$target" remote get-url origin 2>/dev/null || true) ]] || {
        echo "erro: remote origin não configurado" >&2; exit 1; }
fi

"$script_dir/identify-target.sh" "$target"
if [[ $compatibility -eq 1 ]]; then
    echo "mode=compatibility-only"
else
    echo "mode=vanilla-application"
fi
