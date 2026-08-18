#!/bin/sh
set -eu

base=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

for required in README.md COMPATIBILITY_MATRIX.md IMPLEMENTATION_PLAN.md \
    config/capability-policy.tsv scripts/audit-host.sh; do
    if [ ! -f "$base/$required" ]; then
        printf 'FAIL missing=%s\n' "$required" >&2
        exit 1
    fi
done

sh -n "$base/scripts/audit-host.sh"

awk -F '\t' '
    /^#/ || NF == 0 { next }
    NF != 4 { printf "FAIL invalid-policy-line=%d fields=%d\n", NR, NF; bad=1 }
    END { exit bad }
' "$base/config/capability-policy.tsv"

rows=$(awk -F '\t' '!/^#/ && NF == 4 { count++ } END { print count+0 }' \
    "$base/config/capability-policy.tsv")
printf 'PASS policy_rows=%s\n' "$rows"
printf 'PASS kit=freebsd-compatibility\n'
