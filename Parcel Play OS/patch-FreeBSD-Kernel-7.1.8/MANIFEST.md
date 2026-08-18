# Manifesto

## Fontes analisadas

- Linux: `../Kernels/kernel linux-7.1.8/`;
- FreeBSD: `../Kernels/FreeBSD 15/sys/kern/`;
- FreeBSD auditado: 248 arquivos, sendo 231 fontes C;
- candidatos revistos: boottrace, fail, ULE, sendfile, kTLS, Jail, VFS cache,
  PID controller, clock calibration, filters e statistics.

## Resultado da tradução

| FreeBSD | Linux 7.1.8 | Decisão |
|---|---|---|
| `kern_boottrace.c` | bootconfig/ftrace/initcall | usar Linux existente |
| `kern_fail.c` | fault injection/debugfs | variante lab |
| `sched_ule.c` | EEVDF + `sched_ext` | eBPF experimental |
| `kern_sendfile.c` | sendfile/splice | benchmark/selftest |
| `uipc_ktls.c` | `net/tls` | selftests e NIC real |
| `kern_jail.c` | namespaces/cgroup/LSM | userspace |
| `vfs_cache.c` | dcache/RCU-walk | perf/BPF antes de patch |
| `subr_pidctrl.c` | política userspace | não integrar agora |
| `subr_filter.c` | helpers específicos | consumidor antes de patch |
| `subr_stats.c` | tracepoints/perf/BPF | não portar framework |
| APIs de sync | locks/RCU/lockdep Linux | não copiar |
| NTSYNC | driver Linux oficial | usar o existente |

## Licenças observadas novamente

Entre as fontes C com SPDX explícito foram encontrados:

- 127 BSD-2-Clause;
- 63 BSD-3-Clause;
- 9 BSD-4-Clause;
- 2 Beerware;
- 2 combinações BSD.

Arquivos sem SPDX ou trechos mistos exigem auditoria individual. A série ativa
é implementação/documentação independente sob GPL-2.0 e não inclui código BSD.

## Série ativa

- documentação;
- amostra bootconfig inerte por padrão;
- selftests não destrutivos.

## Fora da série

- fault injection e sanitizers: configuração lab;
- scheduler inspirado no ULE: proposta `sched_ext` futura;
- kTLS e VFS: aguardam perfis reproduzíveis;
- algoritmos: aguardam consumidor e KUnit;
- Jail/Capsicum/VNET: composição userspace.
