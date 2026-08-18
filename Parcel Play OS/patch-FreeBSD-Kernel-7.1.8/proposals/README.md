# Propostas condicionais

## Scheduler ULE → sched_ext

Usar os exemplos e selftests existentes em `tools/testing/selftests/sched_ext`.
Uma futura política Parcel deve ser eBPF, sair com segurança para EEVDF e medir
frame time, input latency, throughput, PSI, energia e starvation. Não copiar
runqueues, locks ou topologia de `sched_ule.c`.

## kTLS/sendfile

Executar os selftests de rede e comparar read/write, splice e sendfile em page
cache frio/quente, loopback e NIC real. Medir kTLS TX/RX software e offload.
Não portar mbufs, UMA, VNET ou workqueues FreeBSD.

## VFS/namecache

Perfilar dcache, RCU-walk e pathname lookup com perf/BPF. Alterações em VFS só
avançam com regressão reproduzível e teste de correção.

## PID, filtros e estatísticas

Continuam em userspace. Antes de uso kernel: consumidor real, aritmética sem
ponto flutuante, limites/overflow documentados e KUnit determinístico.

## Jail/Capsicum/VNET

Implementar em userspace com namespaces, cgroup v2, seccomp, Landlock,
capabilities e LSM. Não criar APIs paralelas no kernel.
