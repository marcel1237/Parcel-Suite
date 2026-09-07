#!/bin/sh
set -eu

pool=default
volume=playos-d13-xfce-noble-iso
artifact='/home/marcel/Parcel-Suite/Parcel Suite/Parcel Play OS/build/playos-debian-trixie-xfce-noble/output/live-image-amd64.hybrid.iso'
report='/home/marcel/Parcel-Suite/Parcel Suite/Parcel Play OS/build/lxc-volume-delete.txt'

test -s "$artifact" || {
  echo "ABORTADO: ISO local preservada não encontrada: $artifact" >&2
  exit 1
}

{
  echo '# Exclusão do volume ISO duplicado no LXD'
  date --iso-8601=seconds
  echo "ISO local preservada: $artifact"
  sha256sum "$artifact"
  echo

  if ! lxc storage volume show "$pool" "$volume" >/tmp/playos-volume-show.txt 2>&1; then
    echo "Volume já ausente: $volume"
  else
    cat /tmp/playos-volume-show.txt
    if sed -n '/^used_by:/,$p' /tmp/playos-volume-show.txt | grep -q '/instances/'; then
      echo "ABORTADO: o volume ainda está ligado a uma instância" >&2
      exit 1
    fi
    echo "Excluindo somente o volume: $volume"
    if ! lxc storage volume delete "$pool" "$volume"; then
      dataset='default/custom/default_playos-d13-xfce-noble-iso.iso'
      echo "Volume ocupado por mount residual; desmontando somente: $dataset"
      zfs unmount -f "$dataset" 2>/dev/null || true
      udevadm settle || true
      lxc storage volume delete "$pool" "$volume"
    fi
  fi

  echo
  lxc storage volume list "$pool"
  fstrim -av || true
  df -h /
} > "$report" 2>&1

chmod 0644 "$report"
echo "Operação concluída. Relatório: $report"
