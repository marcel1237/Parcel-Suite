#!/usr/bin/env bash
set -euo pipefail

[[ $# -eq 2 ]] || { echo "uso: $0 /caminho/linux-7.1.8 /diretorio/output" >&2; exit 2; }
source_tree=$1
output=$2
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
kit_dir=$(cd "$script_dir/.." && pwd)

"$script_dir/identify-target.sh" "$source_tree"
command -v pahole >/dev/null || {
    echo "pahole não encontrado; adicione pahole >= 1.24 ao PATH" >&2
    exit 1
}
mkdir -p "$output"
cp "$kit_dir/config/ubuntu-noble-generic-7.1.8.config" "$output/.config"
make -C "$source_tree" O="$output" olddefconfig
grep -q '^CONFIG_DEBUG_INFO_BTF=y$' "$output/.config"
grep -q '^CONFIG_SCHED_CLASS_EXT=y$' "$output/.config"
echo "configuração preparada em $output/.config"
