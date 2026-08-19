# Mapeamento FreeBSD–Linux

ID: `KB-FBSD-LINUX-MAP`

- tipo: `decision`
- confiança: `high`
- estado: `current`
- verificado em: `2026-08-19`
- fontes: `SRC-FBSD-PORTABILITY`, `SRC-FBSD-INTEGRATION`, `SRC-FBSD-LINUX-REVERSE`

## Matriz operacional

| Meta | FreeBSD | Linux | Ação permitida |
|---|---|---|---|
| Boot ordenado | SYSINIT/`mi_startup` | initcalls, initramfs, systemd | medir boottrace e otimizar nativamente |
| Isolamento | Jails/VNET | namespaces+cgroup | contrato userspace com backends distintos |
| Least privilege | Capsicum/MAC | capabilities/seccomp/LSM/Landlock | combinar mecanismos nativos |
| Recursos | RACCT/RCTL | cgroup v2/PSI | mapear política e métricas |
| Scheduler | ULE | CFS/EEVDF, `sched_ext` quando disponível | benchmark; não copiar run queues |
| Zero-copy | sendfile/kTLS/BPF | sendfile/splice/kTLS/AF_XDP | comparar throughput, CPU e latência |
| Memória | UMA/page queues | SLUB/page allocator/memcg | estudar algoritmo, não estruturas |
| Concorrência | mutex/epoch/SMR | mutex/spinlock/RCU/SRCU | usar primitives Linux |
| Dispositivos | Newbus/KOBJ | device model/bus/driver | rejeitar wrapper ABI genérico |
| VFS | vnode/namei | inode/dentry/path | rejeitar porte direto |
| Rede interna | mbuf/VNET | sk_buff/netns | rejeitar porte direto |
| Tracing | DTrace/SDT/KTR | ftrace/perf/eBPF/tracepoints | alinhar eventos e métricas |
| Fault injection | failpoints | fault-injection/debugfs | apenas laboratório |
| Virtualização | bhyve/vmm | KVM/QEMU | manter kernels isolados |

## Fluxo de decisão

1. Definir comportamento desejado e métrica.
2. Procurar equivalente nativo no alvo.
3. Criar baseline sem patch.
4. Implementar menor mudança possível.
5. Testar correção, regressão, segurança e desempenho.
6. Rejeitar a mudança se não superar o mecanismo existente.

## Linux para FreeBSD

No sentido inverso, ideias como PSI, io_uring, NTSYNC, BPF moderno e sanitizers
podem inspirar wrappers ou experimentos FreeBSD. Não se deve copiar código GPL
para o kernel BSD de forma que comprometa a política de licença. LinuxKPI tem
escopo específico e não é um conversor universal de subsistemas Linux.
