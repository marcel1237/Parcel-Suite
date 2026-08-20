# Validação do backport NTSYNC

Data: 2026-08-19

## Escopo

- origem: Linux vanilla 7.1.8 local;
- destino: Ubuntu Noble Linux 6.8.4 local;
- release do build: `6.8.4-playos-freebsd-lab1+`;
- configuração: `CONFIG_NTSYNC=m`;
- estado: compilado, ainda não inicializado nem testado no kernel produzido.

## Resultado do módulo

O alvo isolado foi compilado com:

```text
CC [M]  drivers/misc/ntsync.o
MODPOST Module.symvers
CC [M]  drivers/misc/ntsync.mod.o
LD [M]  drivers/misc/ntsync.ko
BTF [M] drivers/misc/ntsync.ko
```

O `modinfo` confirmou licença GPL, módulo `intree`, ausência de dependências e
`vermagic` compatível com o build. O ELF contém a seção `.BTF`. A configuração
foi restaurada usando o `pahole` 1.31 do toolchain local e terminou com:

```text
CONFIG_PAHOLE_VERSION=131
CONFIG_NTSYNC=m
CONFIG_DEBUG_INFO_BTF=y
CONFIG_DEBUG_INFO_BTF_MODULES=y
```

O alvo isolado não gerou seção de assinatura. Assinatura e empacotamento devem
ser validados no próximo build completo de módulos.

## Selftest

O teste upstream em `tools/testing/selftests/drivers/ntsync/ntsync.c` compilou
contra uma cópia sanitizada da UAPI. Com `-Werror`, o harness kselftest antigo
do Noble e duas variáveis não usadas do teste geram avisos; o Makefile upstream
não ativa `-Werror` e a compilação normal concluiu.

A execução no kernel host terminou com 0 de 11 casos porque `/dev/ntsync` não
existe nesse kernel. Isso é bloqueio esperado de ambiente e não deve ser
registrado como aprovação funcional.

## Ocorrência não relacionada

Uma tentativa de construir todo `drivers/misc/` parou em um include de tracing
do driver MEI (`mei-trace.h`). O alvo isolado NTSYNC compilou; o problema MEI é
preexistente e precisa de investigação separada se o diretório inteiro for usado
como gate.

## Gates pendentes

1. build completo do kernel e de todos os módulos com o novo patch;
2. assinatura e empacotamento de `ntsync.ko`;
3. boot em QEMU ou hardware;
4. carregar o módulo, confirmar `/dev/ntsync` e executar os 11 selftests;
5. regressão de futex, Wine/Proton e suspensão;
6. benchmark A/B antes de qualquer alegação de ganho de desempenho.
