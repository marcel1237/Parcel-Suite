#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
kit_dir=$(cd "$script_dir/.." && pwd)
bash -n "$script_dir"/*.sh
while IFS= read -r entry; do
    [[ -z "$entry" || "$entry" == \#* ]] && continue
    [[ -s "$kit_dir/$entry" ]]
done < "$kit_dir/series"
grep -q '^options.*TSLOG' "$kit_dir/config/PARCEL-LAB"
grep -q '^options.*KCOV' "$kit_dir/config/PARCEL-LAB"
echo "kit: PASS"
