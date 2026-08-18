#!/usr/bin/env bash
set -euo pipefail

[[ $# -eq 1 ]] || { echo "uso: $0 /caminho/freebsd-src" >&2; exit 2; }
target=$1
[[ -f "$target/sys/conf/newvers.sh" ]] || { echo "erro: newvers.sh ausente" >&2; exit 1; }

physical=$(cd "$target" && pwd -P)
revision=$(sed -n 's/^REVISION="\([^"]*\)"/\1/p' "$target/sys/conf/newvers.sh")
branch=$(sed -n 's/^BRANCH="\([^"]*\)"/\1/p' "$target/sys/conf/newvers.sh")
printf 'path=%s\nrevision=%s\nrelease_branch=%s\n' "$physical" "$revision" "$branch"

git_root=$(git -C "$target" rev-parse --show-toplevel 2>/dev/null || true)
if [[ -n "$git_root" && $(cd "$git_root" && pwd -P) == "$physical" ]]; then
    printf 'git=true\ncommit=%s\n' "$(git -C "$target" rev-parse HEAD)"
    printf 'tag=%s\n' "$(git -C "$target" tag --points-at HEAD | head -n 1)"
    printf 'remote=%s\n' "$(git -C "$target" remote get-url origin 2>/dev/null || true)"
    printf 'shallow=%s\n' "$(git -C "$target" rev-parse --is-shallow-repository)"
else
    printf 'git=false\ncommit=unknown\ntag=unknown\nremote=unknown\nshallow=unknown\n'
fi
