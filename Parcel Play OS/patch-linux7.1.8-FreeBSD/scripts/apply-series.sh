#!/usr/bin/env bash
set -euo pipefail

[[ ${1:-} == --apply && $# -eq 2 ]] || {
    echo "uso: $0 --apply /caminho/freebsd-src" >&2; exit 2; }
target=$2
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
kit_dir=$(cd "$script_dir/.." && pwd)

"$script_dir/check-series.sh" "$target"
"$script_dir/identify-target.sh" "$target" > "$kit_dir/results/target-identity.txt"
: > "$kit_dir/results/patch-sha256.txt"
while IFS= read -r entry; do
    [[ -z "$entry" || "$entry" == \#* ]] && continue
    sha256sum "$kit_dir/$entry" >> "$kit_dir/results/patch-sha256.txt"
done < "$kit_dir/series"
while IFS= read -r entry; do
    [[ -z "$entry" || "$entry" == \#* ]] && continue
    echo "APPLY $entry"
    git -C "$target" apply --index "$kit_dir/$entry"
done < "$kit_dir/series"
echo "patchset aplicado ao índice; revise e crie um commit por patch"
