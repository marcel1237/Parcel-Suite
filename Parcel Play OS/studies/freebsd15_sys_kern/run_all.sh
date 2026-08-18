#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-only
set -euo pipefail

study_root=$(cd "$(dirname "$0")" && pwd)
cd "$study_root"
mkdir -p results

./collect_boot_study.sh results/boot-study.txt
./check_fault_injection.sh results/fault-injection-study.txt
./bin/algorithm_tests | tee results/algorithm-tests.txt
./bin/scheduler_bench other | tee results/scheduler-other.txt
./bin/scheduler_bench batch | tee results/scheduler-batch.txt
./bin/io_bench | tee results/io-study.txt

{
    echo "study=environment-capabilities"
    echo "date=$(date --iso-8601=seconds)"
    echo "kernel=$(uname -r)"
    for command in qemu-system-x86_64 iperf3 fio gamescope bpftrace trace-cmd bpftool; do
        if command -v "$command" >/dev/null; then
            echo "$command=yes"
        else
            echo "$command=no"
        fi
    done
    [[ -e /dev/kvm ]] && echo "kvm=yes" || echo "kvm=no"
    [[ -r /proc/net/tls_stat ]] && {
        echo "tls-stat=yes"
        cat /proc/net/tls_stat
    } || echo "tls-stat=no"
} >results/environment.txt

echo "all executable studies completed; see $study_root/results"

