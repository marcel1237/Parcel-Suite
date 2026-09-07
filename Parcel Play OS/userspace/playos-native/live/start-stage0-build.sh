#!/bin/sh
set -eu

native=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
project=$(CDPATH= cd -- "$native/../.." && pwd)
work=$project/build/playos-native-stage0
mkdir -p "$work"

if [ -s "$work/build.pid" ] && kill -0 "$(cat "$work/build.pid")" 2>/dev/null; then
  echo "Build já ativo: PID $(cat "$work/build.pid")"
  exit 1
fi

nohup "$native/live/build-stage0.sh" > "$work/bootstrap.log" 2>&1 &
pid=$!
printf '%s\n' "$pid" > "$work/build.pid"
echo "Build iniciado: PID $pid"
echo "Log: $work/bootstrap.log"
