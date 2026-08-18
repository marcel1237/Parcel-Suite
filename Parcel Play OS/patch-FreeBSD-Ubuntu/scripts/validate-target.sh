#!/usr/bin/env bash
set -euo pipefail

compatibility=0
if [[ ${1:-} == "--compatibility-check" ]]; then
    compatibility=1
    shift
fi

if [[ $# -ne 1 ]]; then
    echo "uso: $0 [--compatibility-check] /caminho/da/arvore-kernel" >&2
    exit 2
fi

target=$1
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

if [[ ! -f "$target/Makefile" || ! -f "$target/Kconfig" ]]; then
    echo "erro: alvo não parece uma árvore Linux completa" >&2
    exit 1
fi
if [[ ! -d "$target/.git" && ! -f "$target/.git" ]]; then
    echo "erro: alvo não é uma árvore Git" >&2
    exit 1
fi
if [[ ! -f "$target/debian.master/changelog" ]]; then
    echo "erro: empacotamento Ubuntu debian.master não encontrado" >&2
    exit 1
fi

physical=$(cd "$target" && pwd -P)
if [[ $compatibility -eq 0 && "$physical" =~ [[:space:]:] ]]; then
    echo "erro: Kbuild requer caminho sem espaços ou dois-pontos: $physical" >&2
    exit 1
fi

if [[ $compatibility -eq 0 ]] && ! sed -n '1p' "$target/debian.master/changelog" | grep -qi 'resolute'; then
    echo "erro: primeiro registro do changelog não declara Resolute" >&2
    exit 1
fi

if [[ $compatibility -eq 0 && -n $(git -C "$target" status --porcelain=v1) ]]; then
    echo "erro: árvore-alvo possui alterações locais" >&2
    exit 1
fi

if [[ $compatibility -eq 0 && $(git -C "$target" rev-parse --is-shallow-repository) == true ]]; then
    echo "erro: clone raso; obtenha o histórico necessário e fixe o baseline" >&2
    exit 1
fi

"$script_dir/identify-target.sh" "$target"
if [[ $compatibility -eq 1 ]]; then
    echo "mode=compatibility-only"
else
    echo "mode=resolute-application"
fi
