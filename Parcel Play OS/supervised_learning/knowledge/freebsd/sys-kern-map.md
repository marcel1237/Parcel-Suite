# FreeBSD `sys/kern`: mapa técnico

ID: `KB-FBSD-SYSKERN`

- tipo: `fact`
- confiança: `high`
- estado: `current`
- verificado em: `2026-08-19`
- fontes: `SRC-FBSD-SOURCE`, `SRC-FBSD-PORTABILITY`, `SRC-FBSD-INTEGRATION`

## O que é

`sys/kern` é parte central do kernel FreeBSD, não uma biblioteca autônoma. O
levantamento anterior da cópia parcial encontrou 248 arquivos no primeiro nível
e forte dependência de cabeçalhos e estruturas internas como `proc`, `thread`,
`vnode`, `ucred`, `mbuf`, VNET, UMA, SYSINIT, epoch e locks BSD.

## Famílias

| Família | Exemplos FreeBSD | Uso no PlayOS/Linux |
|---|---|---|
| Boot | `init_main.c`, SYSINIT | comparar boottrace; usar initcalls Linux |
| Processos/syscalls | `kern_exec.c`, `kern_fork.c` | não portar; usar APIs Linux |
| Scheduler/SMP | `sched_ule.c`, `subr_smp.c` | comparar política e medir |
| Locks | `kern_mutex.c`, `kern_rwlock.c` | não copiar; respeitar lockdep/PI/RCU Linux |
| Tempo | callout, clocks, timers | mapear para hrtimer/timer wheel |
| Segurança | jail, prison, MAC, audit | namespaces+cgroup+LSM+seccomp+Landlock |
| Memória | malloc, UMA, physmem | SLUB/page allocator/memcg nativos |
| Dispositivos | Newbus/KOBJ | driver model Linux; ABI incompatível |
| VFS | vnode/namei/mount | não portar; usar VFS Linux |
| Rede/IPC | socket, sendfile, sysv | usar implementações Linux equivalentes |
| Debug | KDB, DDB, SDT, witness | ftrace/perf/eBPF/lockdep/KASAN |

## Símbolos verificados

- `init_main.c`: `mi_startup` e `sysinit_list`;
- `kern_jail.c`: `prison0` e hierarquia de prisons;
- `sched_ule.c`: `ts_rltick` usado para afinidade;
- `kern_mutex.c`: implementação de mutexes BSD;
- `subr_bus.c`: infraestrutura Newbus.

## Decisão

O caminho aprovado é extrair princípios e contratos observáveis, não copiar o
subsistema. Algoritmos pequenos só podem avançar quando independentes das APIs
BSD, licenciados corretamente, cobertos por teste diferencial e melhores que o
equivalente Linux medido.
