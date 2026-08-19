# Referência de subsistemas FreeBSD para o PlayOS

ID: `KB-FBSD-SUBSYSTEMS`

- tipo: `fact`
- confiança: `high`
- estado: `current`
- verificado em: `2026-08-19`
- fontes: `SRC-FBSD-SOURCE`, `SRC-FBSD-INVENTORY`, `SRC-FBSD-PORTABILITY`

## Objetivo

Esta referência orienta uma IA a localizar o subsistema correto antes de propor
qualquer modificação. Caminhos pertencem à fonte completa FreeBSD 15.1-p2.

| Domínio | Caminhos principais | Conceitos | Regra PlayOS |
|---|---|---|---|
| Inicialização | `sys/kern/init_main.c` | SYSINIT, `mi_startup` | comparar ordem e boottrace |
| Processos | `sys/kern/kern_fork.c`, `kern_exec.c`, `kern_exit.c` | proc, thread, cred | não portar ABI |
| Scheduler | `sys/kern/sched_ule.c`, `sched_4bsd.c` | run queues, afinidade, balanceamento | benchmark de política |
| Locks | `sys/kern/kern_mutex.c`, `kern_rwlock.c`, `subr_lock.c` | mutex, rwlock, witness | usar primitives do alvo |
| Memória | `sys/vm/`, `sys/vm/uma_core.c` | páginas, objetos VM, UMA | comparar com MM/SLUB Linux |
| Jails | `sys/kern/kern_jail.c`, `sys/net/vnet.c` | prison, VNET | backend nativo FreeBSD |
| Recursos | `sys/kern/kern_racct.c`, `kern_rctl.c` | accounting e regras | mapear para cgroup no Linux |
| Capabilities | `sys/kern/sys_capability.c`, `sys/capsicum.h` | capability mode/rights | não confundir com capabilities Linux |
| MAC | `sys/security/mac/` | framework e políticas | comparar com LSM |
| VFS | `sys/kern/vfs_*`, `sys/sys/vnode.h` | vnode, namei, mount | não portar para inode/dentry |
| Rede | `sys/net/`, `sys/netinet/`, `sys/kern/uipc_*` | mbuf, sockets, VNET | medir; não transplantar stack |
| kTLS/sendfile | `sys/kern/uipc_ktls.c`, `sys/kern/kern_sendfile.c` | TLS no kernel, zero-copy | comparar com kTLS/sendfile Linux |
| Dispositivos | `sys/kern/subr_bus.c`, `sys/sys/bus.h`, `sys/dev/` | Newbus, KOBJ, device methods | drivers nativos por kernel |
| Armazenamento | `sys/geom/`, `sys/cam/`, `sys/dev/nvme/` | GEOM, CAM, NVMe | preservar stack FreeBSD |
| OpenZFS | `sys/contrib/openzfs/` | ARC, dbuf, ZIL, datasets | testar como filesystem, não copiar cache |
| Virtualização | `sys/amd64/vmm/`, `usr.sbin/bhyve` na árvore completa | vmm, bhyve | validar VM e passthrough |
| Tracing | `sys/cddl/`, SDT/KTR/DDB/KDB | DTrace e diagnóstico | alinhar eventos com Linux |
| Compatibilidade | `sys/compat/linux*` | Linuxulator | não equivale a kernel Linux |

## Perguntas obrigatórias antes de alterar

1. Qual comportamento observável está faltando?
2. Qual fonte e símbolo comprovam o mecanismo FreeBSD?
3. O kernel alvo já possui equivalente?
4. A proposta depende de estruturas internas incompatíveis?
5. Qual licença rege o trecho?
6. Qual baseline e qual métrica serão usados?
7. Como será testado rollback e regressão?

Sem respostas verificáveis, o estado correto é `proposal` ou `unknown`.
