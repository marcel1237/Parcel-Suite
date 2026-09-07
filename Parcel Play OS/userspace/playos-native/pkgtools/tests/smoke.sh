#!/bin/sh
set -eu

tools=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
tmp=$(mktemp -d "${TMPDIR:-/tmp}/playpkg-test.XXXXXX")
trap 'rm -rf "$tmp"' EXIT HUP INT TERM

mkdir -p "$tmp/tree/PLAYOS" "$tmp/tree/usr/bin" "$tmp/root"
printf '%s\n' \
  'NAME=hello-playos' \
  'VERSION=1.0' \
  'ARCH=x86_64' \
  'BUILD=1' \
  'LICENSE=MIT' > "$tmp/tree/PLAYOS/meta"
printf '#!/bin/sh\nprintf "hello PlayOS\\n"\n' > "$tmp/tree/usr/bin/hello-playos"
chmod 0755 "$tmp/tree/usr/bin/hello-playos"

"$tools/playpkg-build" "$tmp/tree" "$tmp/hello-playos-1.0-x86_64-1.pxz"
"$tools/playpkg-install" --root "$tmp/root" "$tmp/hello-playos-1.0-x86_64-1.pxz"
test "$("$tmp/root/usr/bin/hello-playos")" = 'hello PlayOS'
test -f "$tmp/root/var/lib/playpkg/installed/hello-playos.files"
test ! -e "$tmp/root/archive.list"
test ! -e "$tmp/root/payload.list"
"$tools/playpkg-remove" --root "$tmp/root" hello-playos
test ! -e "$tmp/root/usr/bin/hello-playos"
test ! -e "$tmp/root/var/lib/playpkg/installed/hello-playos.files"

mkdir -p "$tmp/one/PLAYOS" "$tmp/one/usr/bin" "$tmp/two/PLAYOS" "$tmp/two/usr/bin"
for tree in one two; do
  printf '%s\n' \
    "NAME=collision-$tree" \
    'VERSION=1.0' \
    'ARCH=x86_64' \
    'BUILD=1' \
    'LICENSE=MIT' > "$tmp/$tree/PLAYOS/meta"
  printf '%s\n' "$tree" > "$tmp/$tree/usr/bin/collision"
  "$tools/playpkg-build" "$tmp/$tree" "$tmp/collision-$tree-1.0-x86_64-1.pxz"
done

"$tools/playpkg-install" --root "$tmp/root" "$tmp/collision-one-1.0-x86_64-1.pxz"
if "$tools/playpkg-install" --root "$tmp/root" "$tmp/collision-two-1.0-x86_64-1.pxz"; then
  echo 'falha: colisão de payload foi aceita' >&2
  exit 1
fi
test "$(cat "$tmp/root/usr/bin/collision")" = one
"$tools/playpkg-remove" --root "$tmp/root" collision-one

mkdir -p "$tmp/unsafe/PLAYOS" "$tmp/unsafe/usr/lib"
printf '%s\n' \
  'NAME=unsafe-link' \
  'VERSION=1.0' \
  'ARCH=x86_64' \
  'BUILD=1' \
  'LICENSE=MIT' > "$tmp/unsafe/PLAYOS/meta"
ln -s /tmp "$tmp/unsafe/usr/lib/escape"
"$tools/playpkg-build" "$tmp/unsafe" "$tmp/unsafe-link-1.0-x86_64-1.pxz"
if "$tools/playpkg-install" --root "$tmp/root" "$tmp/unsafe-link-1.0-x86_64-1.pxz"; then
  echo 'falha: symlink absoluto foi aceito' >&2
  exit 1
fi

echo 'playpkg smoke: PASS'
