#!/bin/sh
set -eu

PATH=/sbin:/bin:/usr/sbin:/usr/bin
export PATH

mountpoint -q /proc || mount -t proc proc /proc
mountpoint -q /sys || mount -t sysfs sysfs /sys
mountpoint -q /run || mount -t tmpfs -o mode=0755,nosuid,nodev tmpfs /run
mkdir -p /run/lock /run/dbus /run/udev /dev/pts /dev/shm
mountpoint -q /dev/pts || mount -t devpts -o gid=5,mode=0620 devpts /dev/pts
mountpoint -q /dev/shm || mount -t tmpfs -o mode=1777,nosuid,nodev tmpfs /dev/shm

if command -v udevd >/dev/null 2>&1; then
  udevd --daemon
  udevadm trigger --action=add
  udevadm settle
fi

mount -a -O no_netdev 2>/dev/null || true
swapon -a 2>/dev/null || true
