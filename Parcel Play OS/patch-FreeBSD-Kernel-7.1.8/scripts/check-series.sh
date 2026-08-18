#!/usr/bin/env bash
set -euo pipefail

compatibility=0
if [[ ${1:-} == "--compatibility-only" ]]; then compatibility=1; shift; fi
[[ $# -eq 1 ]] || { echo "uso: $0 [--compatibility-only] /caminho/linux-7.1.8" >&2; exit 2; }
target=$1
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
kit_dir=$(cd "$script_dir/.." && pwd)

if [[ $compatibility -eq 1 ]]; then
    "$script_dir/validate-target.sh" --compatibility-only "$target"
else
    "$script_dir/validate-target.sh" "$target"
fi

while IFS= read -r entry; do
    [[ -z "$entry" || "$entry" == \#* ]] && continue
    [[ -s "$kit_dir/$entry" ]] || { echo "erro: patch ausente: $entry" >&2; exit 1; }
    echo "CHECK $entry"
    if [[ $compatibility -eq 1 ]]; then
        (cd "$target" && git apply --check --no-index --whitespace=error-all "$kit_dir/$entry")
    else
        git -C "$target" apply --check --whitespace=error-all "$kit_dir/$entry"
    fi
done < "$kit_dir/series"
echo "series: PASS"
