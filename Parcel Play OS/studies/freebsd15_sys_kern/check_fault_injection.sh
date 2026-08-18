#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-only
set -u

output=${1:-results/fault-injection-study.txt}
mkdir -p "$(dirname "$output")"
config="/boot/config-$(uname -r)"

{
    echo "study=fault-injection-readiness"
    echo "date=$(date --iso-8601=seconds)"
    echo "kernel=$(uname -r)"
    if [[ -r "$config" ]]; then
        grep -E '^(CONFIG_(FAULT_INJECTION|FAULT_INJECTION_DEBUG_FS|FAILSLAB|FAIL_PAGE_ALLOC|FAIL_MAKE_REQUEST|FUNCTION_ERROR_INJECTION|FAIL_FUNCTION|KCOV|KASAN|KCSAN|UBSAN))=' "$config" || true
    else
        echo "kernel-config-readable=no"
    fi
    for node in /sys/kernel/debug/failslab /sys/kernel/debug/fail_page_alloc /sys/kernel/debug/fail_function; do
        if [[ -e "$node" ]]; then
            echo "node-present=$node"
        else
            echo "node-missing=$node"
        fi
    done
    if mount | grep -q 'debugfs .*[(,]rw[,)]'; then
        echo "debugfs-writable=yes"
    else
        echo "debugfs-writable=no"
    fi
    echo "injection-executed=no"
    echo "reason=requires writable debugfs, disposable VM, selected target and recovery assertion"
} >"$output"

echo "fault-injection readiness written to $output"

