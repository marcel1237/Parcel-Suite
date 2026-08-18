# Propostas ainda não convertidas em patches

## Scheduler inspirado no ULE

Implementar primeiro como política `sched_ext` quando presente no baseline.
Exigir fallback automático e benchmarks de frame time, throughput, PSI,
energia e starvation. Não copiar `sched_ule.c`.

## kTLS e sendfile

Executar selftests Linux, iperf3 e testes em NIC real. O patch só será aberto
se houver lacuna reproduzível; o caminho existente é o baseline.

## VFS/namecache

Perfilar RCU-walk, dcache e pathname lookup. Não tocar `fs/namei.c` ou dcache
com base apenas em diferenças arquiteturais do FreeBSD.

## Algoritmos isolados

Manter PID e regressão no daemon userspace. Para eventual uso kernel, remover
ponto flutuante, definir overflow/unidades e criar KUnit junto ao consumidor.

## Jail/Capsicum/VNET

Implementar como composição userspace de namespaces, cgroup v2, seccomp,
Landlock, capabilities e AppArmor. Não criar um segundo modelo de isolamento
dentro do kernel.
