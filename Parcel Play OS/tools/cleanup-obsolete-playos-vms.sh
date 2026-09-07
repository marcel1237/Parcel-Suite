#!/bin/sh
set -eu

preserved='livefs-builder-noble playos-noble-graphics-builder playos-noble-graphics-vm'
report=${1:-/tmp/playos-lxc-cleanup.txt}

# Refuse cleanup unless the principal completed ISO artifacts are outside LXD.
for artifact in \
  '/home/marcel/Parcel-Suite/Parcel Suite/Parcel Play OS/build/playos-graphics-core-noble/output/playos-noble-xfce-calamares-amd64.iso' \
  '/home/marcel/Parcel-Suite/Parcel Suite/Parcel Play OS/build/playos-debian-trixie-xfce-noble/output/live-image-amd64.hybrid.iso' \
  '/home/marcel/Parcel-Suite/Parcel Suite/Parcel Play OS/build/playos-debian-trixie-gnome-noble/output/live-image-amd64.hybrid.iso' \
  '/home/marcel/Parcel-Suite/Parcel Suite/Parcel Play OS/build/playos-debian-trixie-kde-full-noble/output/live-image-amd64.hybrid.iso'
do
  test -s "$artifact" || {
    echo "ABORTADO: artefato preservado ausente: $artifact" >&2
    exit 1
  }
done

targets='livefs-builder-resolute playos-d13-xfce-noble-boot-test playos-debian-trixie-builder'

{
  echo '# PlayOS LXC cleanup'
  date --iso-8601=seconds
  echo "Preservada: $preserved"
  echo "Removidas: $targets"
  echo

  for instance in $targets; do
    if lxc info "$instance" >/dev/null 2>&1; then
      echo "Removendo instância: $instance"
      lxc stop "$instance" --force 2>/dev/null || true
      lxc delete "$instance"
    else
      echo "Instância já ausente: $instance"
    fi
  done

  if lxc storage volume show default playos-d13-xfce-noble-iso >/dev/null 2>&1; then
    echo 'Removendo volume ISO LXD já copiado para o projeto: playos-d13-xfce-noble-iso'
    lxc storage volume delete default playos-d13-xfce-noble-iso
  fi

  echo
  echo 'Removendo imagens LXD sem consumidores'
  lxc image prune || true

  echo
  echo 'Instâncias restantes'
  lxc list
  echo
  echo 'Volumes restantes'
  lxc storage volume list default
  echo
  echo 'Capacidade do pool ZFS'
  zpool list default || true
  zfs list -r default || true
  echo
  echo 'Filesystem do host'
  fstrim -av || true
  df -h /
} > "$report" 2>&1

chmod 0644 "$report"
echo "Limpeza concluída. Relatório: $report"
