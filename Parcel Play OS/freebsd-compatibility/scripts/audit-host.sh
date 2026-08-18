#!/bin/sh
set -eu

pass() { printf 'PASS\t%s\n' "$1"; }
warn() { printf 'WARN\t%s\n' "$1"; }
fail() { printf 'FAIL\t%s\n' "$1"; }

if [ "$(uname -s 2>/dev/null || true)" != "FreeBSD" ]; then
    fail "host não é FreeBSD; auditoria de runtime não pode prosseguir"
    exit 1
fi

release=$(freebsd-version -ku 2>/dev/null | tr '\n' '/' || uname -r)
printf 'INFO\trelease=%s\n' "$release"

major=$(uname -K 2>/dev/null || printf '0')
if [ "$major" -ge 1500000 ] 2>/dev/null; then
    pass "kernel pertence à série FreeBSD 15 ou posterior"
else
    warn "kit foi projetado para FreeBSD 15.1; ABI encontrada: $major"
fi

if command -v pkg >/dev/null 2>&1; then pass "pkg disponível"; else fail "pkg ausente"; fi
if command -v zfs >/dev/null 2>&1 && zfs list -H >/dev/null 2>&1; then
    pass "ZFS ativo"
else
    warn "ZFS não ativo; snapshots/boot environments precisam de alternativa"
fi

if kldstat -q -m linux64 2>/dev/null || kldstat -q -m linux 2>/dev/null; then
    pass "Linux ABI carregada"
else
    warn "Linux ABI não carregada"
fi

for command_name in jail jexec bhyve bhyvectl wine Xwayland; do
    if command -v "$command_name" >/dev/null 2>&1; then
        pass "$command_name disponível"
    else
        warn "$command_name ausente"
    fi
done

if [ -c /dev/dri/card0 ]; then pass "DRM card0 presente"; else warn "DRM card0 ausente"; fi
if [ -c /dev/dri/renderD128 ]; then pass "DRM render node presente"; else warn "DRM render node ausente"; fi
if [ -c /dev/vmm/control ] || [ -d /dev/vmm ]; then pass "dispositivo bhyve presente"; else warn "dispositivo bhyve ausente"; fi

if sysctl -n hw.vmm.vmx.initialized 2>/dev/null | grep -q '^1$' ||
   sysctl -n hw.vmm.svm.features 2>/dev/null | grep -qv '^0$'; then
    pass "virtualização de hardware detectada"
else
    warn "virtualização de hardware não confirmada"
fi

printf 'INFO\tauditoria somente leitura concluída\n'
