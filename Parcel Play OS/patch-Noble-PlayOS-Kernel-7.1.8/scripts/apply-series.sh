#!/usr/bin/env bash
set -euo pipefail

[[ ${1:-} == "--apply" && $# -eq 2 ]] || {
    echo "uso: $0 --apply /caminho/linux-7.1.8-limpo" >&2; exit 2; }
target=$2
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
kit_dir=$(cd "$script_dir/.." && pwd)

"$script_dir/check-series.sh" "$target"
while IFS= read -r entry; do
    [[ -z "$entry" || "$entry" == \#* ]] && continue
    git -C "$target" apply "$kit_dir/$entry"
done < "$kit_dir/series"
echo "série aplicada; configure e compile antes de promover"
