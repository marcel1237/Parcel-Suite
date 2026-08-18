#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-only
set -euo pipefail

runs=${1:-5}
output=${2:-results/repeated-benchmarks.txt}

if ! [[ "$runs" =~ ^[1-9][0-9]*$ ]]; then
    echo "runs must be a positive integer" >&2
    exit 2
fi

mkdir -p "$(dirname "$output")"
{
    echo "study=repeated-userspace-benchmarks"
    echo "date=$(date --iso-8601=seconds)"
    echo "kernel=$(uname -r)"
    echo "runs=$runs"
    for ((run = 1; run <= runs; run++)); do
        echo "run=$run"
        ./bin/scheduler_bench other
        ./bin/scheduler_bench batch
        ./bin/io_bench
    done
} >"$output"

echo "repeated benchmarks written to $output"

