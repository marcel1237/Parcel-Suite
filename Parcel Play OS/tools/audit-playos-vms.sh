#!/bin/sh
set -eu

output=${1:-/tmp/playos-lxc-audit.txt}

{
  echo '# PlayOS LXC storage audit'
  date --iso-8601=seconds
  echo
  echo '## Instances'
  lxc list
  echo
  echo '## Storage pools'
  lxc storage list
  echo
  echo '## Default storage volumes'
  lxc storage volume list default
  echo
  echo '## Default storage configuration'
  lxc storage show default
  echo
  echo '## Instance configurations'
  for instance in $(lxc list --format csv -c n); do
    echo
    echo "### $instance"
    lxc config show "$instance" --expanded
  done
  echo
  echo '## Storage directories'
  du -h --max-depth=3 /var/snap/lxd/common/lxd/storage-pools 2>/dev/null | sort -h | tail -100 || true
  echo
  echo '## Host filesystem'
  df -h /
} > "$output"

chmod 0644 "$output"
echo "Relatório criado em: $output"
