# Manifesto do backport Linux 7.1.8 para Noble

## Baselines

- origem: Linux vanilla 7.1.8 local;
- destino: Ubuntu Noble Linux 6.8.4 local;
- alvo de produto: laboratório PlayOS;
- licença preservada: GPL-2.0-only e Linux-syscall-note conforme os arquivos.

## Série

1. `0001-ntsync-backport-linux-7.1.8-to-noble-6.8.patch`

O fragmento `config/ntsync.config` mantém o recurso como módulo.

## Arquivos esperados

- `drivers/misc/ntsync.c`;
- `include/uapi/linux/ntsync.h`;
- `Documentation/userspace-api/ntsync.rst`;
- integração Kconfig, Makefile, documentação e kselftest;
- `tools/testing/selftests/drivers/ntsync/`.

## Gates

- patch sem whitespace errors;
- configuração `CONFIG_NTSYNC=m`;
- módulo compilado contra Noble;
- selftest userspace compilado;
- selftest executado após carregar o módulo no novo kernel;
- boot e regressão antes de promoção.

## Resultado atual

- patch aplicado à árvore Noble;
- `ntsync.ko` compilado com BTF;
- selftest userspace compilado;
- runtime, boot, assinatura do módulo e regressão ainda pendentes.
