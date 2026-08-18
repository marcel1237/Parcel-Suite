# Manifesto da tradução Linux 7.1.8 → FreeBSD 15.1-p2

## Inventário

- Linux 7.1.8 local: aproximadamente 93.616 arquivos, sem Git próprio;
- FreeBSD 15.1-p2: aproximadamente 108.960 arquivos;
- kernel FreeBSD `sys/`: aproximadamente 33.186 arquivos;
- testes FreeBSD: aproximadamente 2.386 arquivos;
- fonte FreeBSD completa e com tag/commit verificáveis.

## Matriz conceitual

| Linux 7.1.8 | FreeBSD 15.1 | Ação |
|---|---|---|
| RCU | epoch + SMR | medir e usar APIs BSD |
| EEVDF/sched_ext | ULE + selector | estudar interface experimental, não portar BPF scheduler |
| cgroup v2 | RACCT/RCTL + Jails | compor ferramentas userspace |
| namespaces | Jails/VNET | manter modelo FreeBSD |
| seccomp/Landlock | Capsicum + MAC | políticas e testes userspace |
| fault injection | fail(9)/KFAIL_POINT | ampliar testes, não duplicar framework |
| ftrace/bootconfig | TSLOG/KTR/DTrace | perfil lab e coleta reproduzível |
| KASAN/KCSAN/KCOV | KASAN/KCSAN/KMSAN/KCOV | usar variantes existentes |
| sendfile/splice | sendfile/socket_splice | benchmark e testes ATF |
| kTLS | kTLS/OCF/ifnet offload | selftests e métricas |
| io_uring | kqueue/aio | estudo separado, sem emulação apressada |
| NTSYNC | nenhum equivalente direto | proposta de ABI nativa, licença limpa |
| BPF observability | DTrace/HWPMC/netlink | usar ferramentas BSD; avaliar lacunas |
| lockdep | WITNESS | ampliar cobertura de testes |
| PSI | métricas VM/RACCT existentes | estudar lacuna de pressão agregada |
| DAMON | mincore/VM telemetry | pesquisa de longo prazo |
| fs-verity/IMA | MAC/veriexec | comparar threat model |
| LinuxKPI | LinuxKPI existente | somente compatibilidade de drivers |

## Série ativa

1. manual técnico BSD-2-Clause;
2. kernel config `PARCEL-LAB` com diagnóstico opt-in;
3. ATF de baseline não destrutivo.

## Propostas futuras

- telemetria de pressão semelhante a PSI;
- ABI de sincronização NT implementada do zero;
- scheduler de pesquisa com seleção/fallback nativos;
- métricas kTLS/sendfile adicionais;
- políticas RACCT/RCTL orientadas a workloads interativos;
- veriexec/MAC para imagem imutável.

Nenhuma dessas propostas é classificada como implementada.
