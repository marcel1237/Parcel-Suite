#!/bin/sh
set -eu

project=$(CDPATH= cd -- "$(dirname -- "$0")/../../.." && pwd)
script=$project/userspace/playos-native/buildroot/build-stage2-graphics.sh
log=$project/build/playos-native-stage2-graphics/build.log
unit=playos-native-stage2-graphics-build

mkdir -p "$(dirname "$log")"
: > "$log"
systemd-run --user --unit="$unit" \
  --property="WorkingDirectory=$project" \
  --property="StandardOutput=append:$log" \
  --property="StandardError=append:$log" \
  "$script"

echo "UNIT=$unit.service"
echo "LOG=$log"
