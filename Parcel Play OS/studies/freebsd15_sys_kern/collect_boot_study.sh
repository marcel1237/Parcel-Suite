#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-only
set -u
set -o pipefail

output=${1:-results/boot-study.txt}
mkdir -p "$(dirname "$output")"

{
    echo "study=boottrace-equivalent"
    echo "date=$(date --iso-8601=seconds)"
    echo "kernel=$(uname -r)"
    echo "cmdline=$(cat /proc/cmdline)"
    echo
    echo "[systemd-analyze]"
    systemd-analyze 2>&1 || true
    echo
    echo "[systemd-analyze-blame]"
    systemd-analyze blame 2>&1 | head -50 || true
    echo
    echo "[tracefs]"
    mount | grep tracefs || true
    if [[ -r /sys/kernel/tracing/available_events ]]; then
        echo "tracefs-readable=yes"
        wc -l /sys/kernel/tracing/available_events
    else
        echo "tracefs-readable=no"
    fi
    if [[ -w /sys/kernel/tracing/tracing_on ]]; then
        echo "tracefs-writable=yes"
    else
        echo "tracefs-writable=no"
    fi
    echo
    echo "[kernel-log-landmarks]"
    dmesg 2>&1 | grep -Ei 'Linux version|Command line|Run /init|Freeing unused|systemd|Reached target|startup' | head -100 || true
} >"$output"

echo "boot study written to $output"

