#!/bin/sh
set -eu

PATH=/sbin:/bin:/usr/sbin:/usr/bin
export PATH

test ! -r /etc/hostname || hostname "$(cat /etc/hostname)"

if command -v dbus-daemon >/dev/null 2>&1 && [ ! -e /run/dbus/pid ]; then
  dbus-daemon --system --fork
fi

if command -v crond >/dev/null 2>&1; then
  mkdir -p /var/spool/cron/crontabs
  crond
fi

system_name=PlayOS
if [ -r /etc/os-release ]; then
  system_name=$(sed -n 's/^PRETTY_NAME="\(.*\)"/\1/p' /etc/os-release)
fi
echo "${system_name:-PlayOS}: runlevel 3 ativo"
