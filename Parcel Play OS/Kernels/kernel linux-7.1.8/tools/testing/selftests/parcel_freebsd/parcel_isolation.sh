#!/bin/sh
# SPDX-License-Identifier: GPL-2.0
echo "TAP version 13"; echo "1..5"
[ -f /sys/fs/cgroup/cgroup.controllers ] && echo "ok 1 - cgroup v2 available" || echo "not ok 1 - cgroup v2 unavailable"
[ -e /proc/self/ns/user ] && [ -e /proc/self/ns/pid ] && [ -e /proc/self/ns/net ] && [ -e /proc/self/ns/mnt ] && echo "ok 2 - isolation namespaces available" || echo "not ok 2 - namespaces missing"
seccomp=$(awk '/^Seccomp:/ { print $2 }' /proc/self/status 2>/dev/null); case "$seccomp" in 0|1|2) echo "ok 3 - seccomp visible (mode $seccomp)" ;; *) echo "not ok 3 - seccomp unavailable" ;; esac
[ -r /proc/pressure/cpu ] && [ -r /proc/pressure/memory ] && [ -r /proc/pressure/io ] && echo "ok 4 - PSI available" || echo "ok 4 - PSI unavailable # SKIP"
[ -d /sys/module/apparmor ] && echo "ok 5 - AppArmor present" || echo "ok 5 - AppArmor absent # SKIP"
