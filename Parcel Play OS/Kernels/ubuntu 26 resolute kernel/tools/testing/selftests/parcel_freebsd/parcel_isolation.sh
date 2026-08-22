#!/bin/sh
# SPDX-License-Identifier: GPL-2.0

echo "TAP version 13"
echo "1..5"

if [ -f /sys/fs/cgroup/cgroup.controllers ]; then
        controllers=$(tr '\n' ' ' < /sys/fs/cgroup/cgroup.controllers)
        echo "ok 1 - cgroup v2 controllers are visible ($controllers)"
else
        echo "not ok 1 - cgroup v2 unified hierarchy is unavailable"
fi

if [ -e /proc/self/ns/user ] && [ -e /proc/self/ns/pid ] &&
   [ -e /proc/self/ns/net ] && [ -e /proc/self/ns/mnt ]; then
        echo "ok 2 - user, PID, network and mount namespaces are available"
else
        echo "not ok 2 - namespace handles required by Play Sandbox are missing"
fi

seccomp=$(awk '/^Seccomp:/ { print $2 }' /proc/self/status 2>/dev/null)
case "$seccomp" in
0|1|2) echo "ok 3 - seccomp process state is visible (mode $seccomp)" ;;
*) echo "not ok 3 - seccomp process state is unavailable" ;;
esac

if [ -r /proc/pressure/cpu ] && [ -r /proc/pressure/memory ] &&
   [ -r /proc/pressure/io ]; then
        echo "ok 4 - PSI exposes CPU, memory and I/O pressure"
else
        echo "ok 4 - complete PSI interface unavailable # SKIP"
fi

if [ -d /sys/module/apparmor ]; then
        echo "ok 5 - AppArmor kernel module is present"
else
        echo "ok 5 - AppArmor module is absent # SKIP"
fi
