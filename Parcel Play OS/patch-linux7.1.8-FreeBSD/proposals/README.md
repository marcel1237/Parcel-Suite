# Propostas ainda não implementadas

## PSI nativo do FreeBSD

Estudar uma interface agregada de pressão de CPU, memória e I/O inspirada no
Linux PSI. Antes de criar ABI, inventariar `vm.stats`, RACCT, scheduler stats,
GEOM e métricas existentes. Exigir custo mensurado e consumidor real.

## Sincronização NT

NTSYNC do Linux é GPL-2.0 e não deve ser copiado. Uma implementação FreeBSD
precisaria de especificação de ABI independente, testes de compatibilidade,
integração com kqueue/poll, limites por jail e revisão de segurança.

## Scheduler extensível

Não portar `sched_ext` ou verifier/BPF Linux. Avaliar primeiro se o selector de
schedulers, módulos experimentais ou uma interface limitada podem oferecer
fallback seguro sem expor estruturas internas do scheduler.

## I/O assíncrono

Comparar io_uring com kqueue, POSIX AIO e `socket_splice`. Definir workloads e
lacunas antes de propor uma nova fila compartilhada ou ABI.

## Integridade/imutabilidade

Comparar IMA/fs-verity com MAC/veriexec, ZFS boot environments e assinatura de
pacotes. A solução deve seguir o modelo de confiança FreeBSD.

## Telemetria e tracing

Mapear tracepoints Linux úteis que não tenham equivalente em SDT/DTrace, KTR,
TSLOG, HWPMC ou sysctls. Adicionar probes pequenos somente com consumidor.
