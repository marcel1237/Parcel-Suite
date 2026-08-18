#!/usr/bin/env bash
set -euo pipefail

compatibility=0
if [[ ${1:-} == "--allow-non-resolute" ]]; then
    compatibility=1
    shift
fi
if [[ $# -ne 1 ]]; then
    echo "uso: $0 [--allow-non-resolute] /caminho/da/arvore-kernel" >&2
    exit 2
fi

target=$1
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
kit_dir=$(cd "$script_dir/.." && pwd)

if [[ $compatibility -eq 1 ]]; then
    "$script_dir/validate-target.sh" --compatibility-check "$target"
else
    "$script_dir/validate-target.sh" "$target"
fi

while IFS= read -r entry; do
    [[ -z "$entry" || "$entry" == \#* ]] && continue
    patch_file=$kit_dir/$entry
    if [[ ! -f "$patch_file" ]]; then
        echo "erro: patch ausente: $entry" >&2
        exit 1
    fi
    echo "CHECK $entry"
    git -C "$target" apply --check "$patch_file"
done < "$kit_dir/series"

echo "series: PASS"
