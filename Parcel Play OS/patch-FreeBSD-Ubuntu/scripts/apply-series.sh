#!/usr/bin/env bash
set -euo pipefail

if [[ ${1:-} != "--apply" || $# -ne 2 ]]; then
    echo "uso: $0 --apply /caminho/sem-espacos/ubuntu-resolute" >&2
    exit 2
fi

target=$2
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
kit_dir=$(cd "$script_dir/.." && pwd)
result_dir=$kit_dir/results

"$script_dir/check-series.sh" "$target"
"$script_dir/identify-target.sh" "$target" > "$result_dir/target-identity.txt"
: > "$result_dir/patch-sha256.txt"
while IFS= read -r entry; do
    [[ -z "$entry" || "$entry" == \#* ]] && continue
    sha256sum "$kit_dir/$entry" >> "$result_dir/patch-sha256.txt"
done < "$kit_dir/series"

while IFS= read -r entry; do
    [[ -z "$entry" || "$entry" == \#* ]] && continue
    echo "APPLY $entry"
    git -C "$target" apply --index "$kit_dir/$entry"
done < "$kit_dir/series"

echo "patchset aplicado ao índice; revise e crie um commit por patch"
