#!/bin/sh
# SPDX-License-Identifier: GPL-2.0

ksft_skip=4
config=/boot/config-$(uname -r)

echo "TAP version 13"
echo "1..6"

if [ -r "$config" ]; then
        echo "ok 1 - running kernel configuration is readable"
else
        echo "ok 1 - running kernel configuration unavailable # SKIP"
fi

if [ -d /sys/kernel/tracing ]; then
        echo "ok 2 - tracefs is available"
elif [ -d /sys/kernel/debug/tracing ]; then
        echo "ok 2 - tracing is available through debugfs"
else
        echo "ok 2 - tracing filesystem is not mounted # SKIP"
fi

if [ -r /proc/cgroups ]; then
        echo "ok 3 - cgroup interface is available"
else
        echo "not ok 3 - cgroup interface is unavailable"
fi

if [ -e /proc/self/ns/user ] && [ -e /proc/self/ns/net ]; then
        echo "ok 4 - user and network namespace handles are available"
else
        echo "not ok 4 - required namespace handles are unavailable"
fi

if [ -r /proc/sys/kernel/unprivileged_bpf_disabled ]; then
        value=$(cat /proc/sys/kernel/unprivileged_bpf_disabled)
        echo "ok 5 - unprivileged BPF policy is visible ($value)"
else
        echo "ok 5 - unprivileged BPF policy is unavailable # SKIP"
fi

if [ -d /sys/kernel/debug/fail_function ] || \
   [ -d /sys/kernel/debug/failslab ] || \
   [ -d /sys/kernel/debug/fail_page_alloc ]; then
        echo "ok 6 - fault injection interface is present"
else
        echo "ok 6 - fault injection interface absent # SKIP lab-only"
fi

exit 0
