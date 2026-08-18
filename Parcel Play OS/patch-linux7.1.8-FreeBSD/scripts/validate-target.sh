#!/usr/bin/env bash
set -euo pipefail

compatibility=0
if [[ ${1:-} == "--compatibility-only" ]]; then compatibility=1; shift; fi
[[ $# -eq 1 ]] || { echo "uso: $0 [--compatibility-only] /caminho/freebsd-src" >&2; exit 2; }
target=$1
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

for required in Makefile sys/conf/newvers.sh sys/kern/sched_ule.c \
    sys/kern/kern_fail.c sys/kern/kern_sendfile.c sys/kern/uipc_ktls.c \
    sys/kern/subr_epoch.c sys/kern/subr_smr.c tests/sys/kern/Makefile; do
    [[ -e "$target/$required" ]] || { echo "erro: ausente: $required" >&2; exit 1; }
done

grep -q '^REVISION="15.1"' "$target/sys/conf/newvers.sh" || {
    echo "erro: esperado FreeBSD 15.1" >&2; exit 1; }
grep -q '^BRANCH="RELEASE-p2"' "$target/sys/conf/newvers.sh" || {
    echo "erro: esperado RELEASE-p2" >&2; exit 1; }

physical=$(cd "$target" && pwd -P)
if [[ $compatibility -eq 0 && "$physical" =~ [[:space:]:] ]]; then
    echo "erro: use caminho de build sem espaços ou dois-pontos" >&2
    exit 1
fi

if [[ $compatibility -eq 0 ]]; then
    git_root=$(git -C "$target" rev-parse --show-toplevel 2>/dev/null || true)
    [[ -n "$git_root" && $(cd "$git_root" && pwd -P) == "$physical" ]] || {
        echo "erro: alvo deve ser a raiz de uma árvore Git" >&2; exit 1; }
    [[ -z $(git -C "$target" status --porcelain=v1) ]] || {
        echo "erro: árvore FreeBSD possui alterações" >&2; exit 1; }
    remote=$(git -C "$target" remote get-url origin 2>/dev/null || true)
    [[ "$remote" == https://git.FreeBSD.org/src.git ]] || {
        echo "erro: remote oficial esperado" >&2; exit 1; }
    git -C "$target" tag --points-at HEAD | grep -qx 'release/15.1.0-p2' || {
        echo "erro: HEAD não está na tag release/15.1.0-p2" >&2; exit 1; }
fi

"$script_dir/identify-target.sh" "$target"
if [[ $compatibility -eq 1 ]]; then echo mode=compatibility-only; else echo mode=freebsd-application; fi
