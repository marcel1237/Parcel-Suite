#!/bin/sh
set -eu

native=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
project=$(CDPATH= cd -- "$native/../.." && pwd)
log=$project/build/playos-native-stage1/build.log
unit=playos-native-stage1-build

mkdir -p "$(dirname -- "$log")"

if systemctl --user is-active --quiet "$unit.service"; then
  echo "build já está ativo: $unit.service"
  exit 0
fi

systemd-run --user --unit="$unit" --collect \
  --working-directory="$project" \
  --property="StandardOutput=append:$log" \
  --property="StandardError=append:$log" \
  "$native/buildroot/build-stage1.sh"

echo "UNIT=$unit.service"
echo "LOG=$log"
