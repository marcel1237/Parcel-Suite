#!/bin/sh
# SPDX-License-Identifier: GPL-2.0
echo "TAP version 13"; echo "1..8"
[ -d /sys/kernel/tracing ] || [ -d /sys/kernel/debug/tracing ] && echo "ok 1 - tracing available" || echo "ok 1 - tracing unavailable # SKIP"
[ -r /proc/cgroups ] && echo "ok 2 - cgroups available" || echo "not ok 2 - cgroups unavailable"
[ -e /proc/self/ns/user ] && [ -e /proc/self/ns/net ] && echo "ok 3 - namespaces available" || echo "not ok 3 - namespaces unavailable"
[ -r /proc/sys/kernel/unprivileged_bpf_disabled ] && echo "ok 4 - BPF policy visible" || echo "ok 4 - BPF policy unavailable # SKIP"
[ -e /sys/kernel/sched_ext/state ] && echo "ok 5 - sched_ext available" || echo "ok 5 - sched_ext unavailable # SKIP"
[ -e /dev/ntsync ] && echo "ok 6 - NTSYNC available" || echo "ok 6 - NTSYNC unavailable # SKIP"
[ -d /sys/module/tls ] && echo "ok 7 - kTLS present" || echo "ok 7 - kTLS not loaded # SKIP"
[ -d /sys/kernel/debug/failslab ] && echo "ok 8 - fault injection present" || echo "ok 8 - fault injection absent # SKIP lab-only"
