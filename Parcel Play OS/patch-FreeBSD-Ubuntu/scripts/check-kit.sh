#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
kit_dir=$(cd "$script_dir/.." && pwd)

bash -n "$script_dir"/*.sh

while IFS= read -r entry; do
    [[ -z "$entry" || "$entry" == \#* ]] && continue
    test -s "$kit_dir/$entry"
done < "$kit_dir/series"

grep -q '^CONFIG_FAULT_INJECTION=y$' "$kit_dir/config/parcel-lab.config"
grep -q 'events.initcall.initcall_finish.enable' \
    "$kit_dir/bootconfig/parcel-boottrace.bconf"

echo "kit: PASS"
