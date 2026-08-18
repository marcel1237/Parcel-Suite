#!/usr/bin/env bash
set -euo pipefail

[[ $# -eq 1 ]] || { echo "uso: $0 /caminho/linux-7.1.8" >&2; exit 2; }
target=$1
[[ -f "$target/Makefile" ]] || { echo "erro: Makefile ausente" >&2; exit 1; }

physical=$(cd "$target" && pwd -P)
version=$(sed -n -E \
    -e 's/^VERSION = (.*)$/\1/p' \
    -e 's/^PATCHLEVEL = (.*)$/\1/p' \
    -e 's/^SUBLEVEL = (.*)$/\1/p' "$target/Makefile" | paste -sd.)

printf 'path=%s\n' "$physical"
printf 'kernel_version=%s\n' "$version"
git_root=$(git -C "$target" rev-parse --show-toplevel 2>/dev/null || true)
if [[ -n "$git_root" && $(cd "$git_root" && pwd -P) == "$physical" ]]; then
    printf 'git=true\n'
    printf 'commit=%s\n' "$(git -C "$target" rev-parse HEAD)"
    printf 'branch=%s\n' "$(git -C "$target" branch --show-current)"
    printf 'remote=%s\n' "$(git -C "$target" remote get-url origin 2>/dev/null || true)"
else
    printf 'git=false\ncommit=unknown\nbranch=unknown\nremote=unknown\n'
fi
