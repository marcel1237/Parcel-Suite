#!/usr/bin/env bash
set -euo pipefail

[[ $# -eq 1 ]] || { echo "uso: $0 /caminho/linux-7.1.8-limpo" >&2; exit 2; }
target=$1
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
kit_dir=$(cd "$script_dir/.." && pwd)

"$script_dir/identify-target.sh" "$target"
while IFS= read -r entry; do
    [[ -z "$entry" || "$entry" == \#* ]] && continue
    [[ -s "$kit_dir/$entry" ]]
    git -C "$target" apply --check --whitespace=error-all "$kit_dir/$entry"
done < "$kit_dir/series"
echo "série aplicável: PASS"
