#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
kit_dir=$(cd "$script_dir/.." && pwd)
bash -n "$script_dir"/*.sh
grep -q '^CONFIG_NTSYNC=m$' "$kit_dir/config/ubuntu-noble-generic-7.1.8.config"
grep -q '^CONFIG_SCHED_CLASS_EXT=y$' "$kit_dir/config/ubuntu-noble-generic-7.1.8.config"
grep -q '^CONFIG_SECURITY_APPARMOR=y$' "$kit_dir/config/ubuntu-noble-generic-7.1.8.config"
grep -q '^CONFIG_SECURITY_LANDLOCK=y$' "$kit_dir/config/ubuntu-noble-generic-7.1.8.config"
grep -q '^CONFIG_SYSTEM_TRUSTED_KEYS=""$' "$kit_dir/config/ubuntu-noble-generic-7.1.8.config"
while IFS= read -r entry; do
    [[ -z "$entry" || "$entry" == \#* ]] && continue
    [[ -s "$kit_dir/$entry" ]]
done < "$kit_dir/series"
echo "kit PlayOS Kernel 7.1.8: PASS"
