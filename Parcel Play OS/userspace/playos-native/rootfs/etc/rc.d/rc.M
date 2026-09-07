#!/bin/sh
set -eu

PATH=/sbin:/bin:/usr/sbin:/usr/bin
export PATH

test ! -r /etc/hostname || hostname "$(cat /etc/hostname)"

mkdir -p /run/dbus
if command -v dbus-daemon >/dev/null 2>&1 && [ ! -s /run/dbus/pid ]; then
  dbus-daemon --system --fork
fi

if command -v elogind >/dev/null 2>&1; then
  elogind --daemon 2>/dev/null || true
fi

if command -v NetworkManager >/dev/null 2>&1; then
  NetworkManager --no-daemon >/var/log/NetworkManager.log 2>&1 &
fi

if command -v crond >/dev/null 2>&1; then
  crond
fi
