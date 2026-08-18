# Auditoria de Portabilidade — FreeBSD 15 `sys/kern` para Kernel Ubuntu Resolute

**Data:** 18 de agosto de 2026  
**Origem local analisada:** `Kernels/FreeBSD 15/sys/kern`  
**Destino pretendido:** kernel Ubuntu Resolute usado pelo Parcel Play OS  
**Escopo:** todos os 248 arquivos presentes no recorte local.

## 1. Conclusão executiva

O diretório FreeBSD `sys/kern` não pode ser copiado, incluído ou compilado diretamente dentro do Linux/Ubuntu. Os dois kernels possuem modelos internos incompatíveis de processos, threads, memória, VFS, rede, locks, drivers, módulos, syscalls, credenciais, namespaces e build.

Das formas possíveis de aproveitamento, a ordem recomendada é:

1. **usar como referência para testes, métricas e políticas**;
2. **mapear a ideia para um mecanismo Linux já existente**;
3. **prototipar algoritmos pequenos em userspace**;
4. **portar código isolado somente quando não houver equivalente Linux e existir benchmark que justifique**;
5. **não portar subsistemas completos**.

No estado atual, não existe nenhum arquivo cuja cópia direta para o kernel Resolute seja recomendada. Há cinco famílias úteis para experimentos comparativos:

- boot e shutdown tracing;
- fault injection;
- filtros estatísticos/PID controller;
- políticas do scheduler ULE por meio de `sched_ext` ou benchmark;
- métricas de sendfile, kTLS e cache de nomes.

Mesmo nessas famílias, a primeira opção é usar a infraestrutura Linux existente.

## 2. Limites da fonte local

O recorte contém:

- 248 arquivos;
- 231 arquivos C;
- 8 descrições de interface `.m`;
- 2 scripts Shell;
- 2 arquivos Assembly;
- arquivos de geração de syscalls e vnode;
- aproximadamente 7,7 MB.

Estão ausentes, entre outros:

- `sys/sys/`, onde ficam muitos headers usados;
- `sys/vm/`;
- `sys/net/` e `sys/netinet/`;
- `sys/security/`;
- headers de arquitetura em `sys/*/include/`;
- configuração de kernel;
- toolchain e Makefiles superiores;
- `COPYRIGHT` da raiz;
- metadados Git, remoto, branch, tag e commit.

Consequências:

- o recorte FreeBSD não é compilável isoladamente;
- não é possível confirmar a revisão exata somente pelo nome da pasta;
- uma análise de dependências completa exige a árvore `freebsd-src` integral;
- qualquer porte deve começar obtendo a fonte oficial com commit fixado.

Foi observado `sched_shim.c` com copyright de 2026. Isso reforça que o conteúdo pode corresponder a uma revisão de desenvolvimento associada ao FreeBSD 15, e não necessariamente a uma release imutável identificável.

## 3. Por que o código não encaixa diretamente no Linux

As inclusões mais frequentes mostram acoplamento profundo:

| Header FreeBSD | Ocorrências aproximadas | Dependência conceitual |
|---|---:|---|
| `sys/param.h` | 210 | tipos e parâmetros globais FreeBSD |
| `sys/systm.h` | 206 | utilidades internas do kernel |
| `sys/kernel.h` | 187 | inicialização/SYSINIT |
| `sys/proc.h` | 155 | processos e threads FreeBSD |
| `sys/lock.h` | 154 | framework de locks FreeBSD |
| `sys/sysctl.h` | 142 | sysctl FreeBSD |
| `sys/mutex.h` | 137 | mutexes FreeBSD |
| `sys/malloc.h` | 132 | allocator tipado FreeBSD |
| `vm/vm.h` | 65 | VM FreeBSD |
| `sys/vnode.h` | 62 | VFS/vnode FreeBSD |
| `vm/uma.h` | 41 | allocator UMA |
| `security/mac/mac_framework.h` | 40 | framework MAC FreeBSD |
| `sys/jail.h` | 44 | prisons/jails |
| `sys/capsicum.h` | 31 | capability mode FreeBSD |
| `sys/mbuf.h` | 19 | buffers de rede FreeBSD |

Equivalências aproximadas não tornam APIs compatíveis:

| FreeBSD | Linux |
|---|---|
| `struct proc` / `struct thread` | `task_struct` e estruturas relacionadas |
| `vnode` / `namei` | `inode`, `dentry`, `file`, `nameidata` Linux |
| UMA | SLAB/SLUB |
| `mbuf` | `sk_buff` |
| epoch/SMR | RCU/SRCU |
| taskqueue | workqueue/tasklet/irq_work conforme o contexto |
| jail/prison | combinação de namespaces, cgroups, LSM e userspace |
| Capsicum | sem equivalente único; Landlock/seccomp/fd discipline |
| RACCT/RCTL | cgroup v2, rlimits, PSI e accounting |
| pctrie | XArray/Maple Tree/radix structures |
| `SYSINIT` | initcalls e inicialização específica de subsistemas |
| KOBJ/Newbus | driver model Linux, buses e `struct device` |

## 4. Licenciamento

Contagem dos identificadores SPDX no recorte:

| Licença identificada | Arquivos |
|---|---:|
| BSD-2-Clause | 130 |
| BSD-3-Clause | 63 |
| BSD-4-Clause | 9 |
| Beerware | 2 |
| BSD-4-Clause AND BSD-2-Clause | 1 |
| BSD-3-Clause AND BSD-2-Clause | 1 |
| Sem SPDX explícito | 42 |

Os 42 arquivos sem SPDX não são automaticamente “sem licença”; muitos possuem blocos históricos de copyright e redistribuição. Eles exigem auditoria individual.

O kernel Linux é GPL-2.0-only como obra global e exige licença individual compatível e identificador SPDX preciso. A árvore Ubuntu local lista BSD-2-Clause e BSD-3-Clause entre licenças preferidas, mas não lista BSD-4-Clause ou Beerware como preferidas.

Regras obrigatórias para qualquer porte:

1. registrar o commit FreeBSD de origem;
2. preservar autores e avisos;
3. confirmar compatibilidade da licença do arquivo;
4. escolher expressão SPDX aceita pelo Linux;
5. documentar modificações;
6. passar revisão jurídica para BSD-4-Clause, Beerware, combinações e arquivos sem SPDX;
7. não republicar código BSD incorporado como se fosse criação original do NitroCore.

Referência local do Linux: `Documentation/process/license-rules.rst` e `LICENSES/` na árvore Ubuntu.

## 5. Modos possíveis de utilização

### Modo A — Configurar o equivalente Linux

É o modo preferido. Exemplos:

- WITNESS → LOCKDEP;
- epoch/SMR → RCU/SRCU;
- RACCT/RCTL → cgroup v2;
- Jail → namespaces + cgroups + LSM;
- failpoints → fault injection Linux;
- boottrace → ftrace/bootconfig/initcall tracing;
- KCOV/KASAN/KCSAN/UBSAN → implementações Linux já presentes;
- kTLS → `net/tls` Linux;
- pctrie → XArray/Maple Tree;
- taskqueue → workqueues;
- UMA → SLUB;
- process descriptors → pidfd;
- eventfd/timerfd/inotify → APIs nativas Linux.

### Modo B — Comparar política e comportamento

Executar FreeBSD e Ubuntu em VMs equivalentes e medir:

- boot e shutdown;
- latência de scheduler;
- distribuição de tarefas entre CPUs;
- sendfile/kTLS;
- cache de nomes e metadata;
- contenção de locks;
- limites de recursos;
- isolamento;
- fault injection e recuperação.

Esse método aproveita a engenharia FreeBSD sem criar um porte frágil.

### Modo C — Reimplementar a ideia usando APIs Linux

Adequado quando a política FreeBSD for interessante, mas a infraestrutura for incompatível. Exemplos:

- heurística ULE implementada experimentalmente em `sched_ext`;
- sandbox inspirado em Jail usando systemd, namespaces, cgroup v2 e Landlock;
- boot event landmarks usando tracepoints Linux;
- estatísticas usando tracepoints/eBPF/per-CPU counters;
- filtro temporal usando `win_minmax` Linux.

### Modo D — Extrair algoritmo pequeno

Somente para funções isoláveis, após verificar que não existe equivalente melhor. Candidatos teóricos:

- `subr_pidctrl.c`;
- `subr_clockcalib.c`;
- `subr_filter.c`;
- partes matemáticas de `subr_stats.c`.

Mesmo esses candidatos não devem ir diretamente ao kernel. Primeiro devem ser:

1. extraídos para um programa userspace;
2. cobertos por testes de vetor;
3. comparados com APIs Linux;
4. medidos;
5. submetidos a auditoria de overflow, concorrência e precisão;
6. portados apenas se houver consumidor real.

### Modo E — Porte direto de subsistema

Não recomendado para nenhum grupo do recorte. Exigiria reescrever a maior parte das interfaces e manter um fork invasivo do Linux.

## 6. Avaliação por família

### 6.1 Build, geração e interfaces — 16 arquivos

Arquivos:

`Make.tags.inc`, `Makefile`, `bus_if.m`, `clock_if.m`, `cpufreq_if.m`, `device_if.m`, `genassym.sh`, `genoffset.c`, `genoffset.sh`, `linker_if.m`, `msi_if.m`, `pic_if.m`, `serdev_if.m`, `syscalls.conf`, `syscalls.master`, `vnode_if.src`.

#### Utilização possível

- estudar geração de interfaces KOBJ;
- estudar tabelas de syscall FreeBSD;
- comparar geração de offsets para Assembly;
- estudar organização de build do sistema base.

#### Veredito

**Referência somente.** O Linux usa Kbuild, driver model, syscall tables e geradores próprios. Arquivos `.m` FreeBSD não são módulos Linux nem fontes Objective-C; são descrições consumidas por ferramentas FreeBSD.

### 6.2 Execução, syscalls e processos — 28 arquivos

Arquivos:

`coredump_vnode.c`, `imgact_aout.c`, `imgact_binmisc.c`, `imgact_elf.c`, `imgact_elf32.c`, `imgact_elf64.c`, `imgact_shell.c`, `init_main.c`, `init_sysent.c`, `kern_exec.c`, `kern_exit.c`, `kern_fork.c`, `kern_kthread.c`, `kern_loginclass.c`, `kern_proc.c`, `kern_procctl.c`, `kern_prot.c`, `kern_resource.c`, `kern_sharedpage.c`, `kern_sig.c`, `kern_syscalls.c`, `kern_thr.c`, `kern_thread.c`, `kern_ucoredump.c`, `subr_syscall.c`, `sys_procdesc.c`, `sys_process.c`, `systrace_args.c`.

#### Utilização possível

- comparar lifecycle de processos e threads;
- estudar `procctl` e reaper trees;
- comparar process descriptors com pidfd;
- comparar coredump e ELF activation;
- estudar init ordering via `SYSINIT`.

#### Equivalentes Linux

- pidfd e `clone3`;
- `task_struct` e APIs de processo;
- binfmt ELF/script/misc;
- coredump helpers;
- prctl, seccomp e subreapers;
- initcalls.

#### Veredito

**Não portar.** `sys_procdesc.c` é especialmente útil como comparação com pidfd, mas Linux já possui sua própria API. `imgact_aout.c` é legado e não atende ao objetivo moderno do Parcel.

### 6.3 Scheduler, locks e SMP — 25 arquivos

Arquivos:

`kern_condvar.c`, `kern_cpuset.c`, `kern_idle.c`, `kern_lock.c`, `kern_lockf.c`, `kern_lockstat.c`, `kern_membarrier.c`, `kern_mtxpool.c`, `kern_mutex.c`, `kern_rangelock.c`, `kern_rmlock.c`, `kern_rwlock.c`, `kern_sema.c`, `kern_switch.c`, `kern_sx.c`, `kern_synch.c`, `ksched.c`, `sched_4bsd.c`, `sched_shim.c`, `sched_ule.c`, `subr_lock.c`, `subr_sleepqueue.c`, `subr_smp.c`, `subr_turnstile.c`, `subr_witness.c`.

#### Utilização possível

- estudar runqueues por CPU do ULE;
- comparar afinidade, stealing, balanceamento e interatividade;
- comparar turnstiles e priority inheritance;
- usar WITNESS como referência para casos de teste de lock order;
- comparar lockstat e contenção.

#### Equivalentes Linux

- EEVDF e classes do scheduler Linux;
- `sched_ext` para experimentos;
- mutex, rtmutex, rwsem, completions e waitqueues;
- lockdep e perf lock;
- RCU e primitives SMP.

#### Veredito

**Não portar locks ou ULE diretamente.** É a família com maior potencial de aprendizagem e maior risco de porte. O experimento correto é reproduzir uma heurística isolada em `sched_ext`, não substituir o scheduler do Ubuntu.

O Linux possui RCU com integração a lockdep: <https://docs.kernel.org/RCU/lockdep.html>.

### 6.4 Tempo e timers — 15 arquivos

Arquivos:

`kern_clock.c`, `kern_clocksource.c`, `kern_et.c`, `kern_ffclock.c`, `kern_ntptime.c`, `kern_tc.c`, `kern_time.c`, `kern_timeout.c`, `p1003_1b.c`, `posix4_mib.c`, `subr_clock.c`, `subr_clockcalib.c`, `subr_rtc.c`, `subr_ticks.S`, `sys_timerfd.c`.

#### Utilização possível

- comparar timecounter/eventtimer com clocksource/clockevents Linux;
- testar a regressão estatística de `subr_clockcalib.c` em userspace;
- comparar precisão, custo e estabilidade de calibração;
- estudar ffclock apenas como pesquisa de sincronização.

#### Veredito

`subr_clockcalib.c` é um candidato algorítmico interessante, mas Linux já possui infraestrutura madura por arquitetura. **Prototipar e medir; não portar para o kernel sem lacuna demonstrada.** `sys_timerfd.c` implementa uma API originária do Linux e não deve ser portada de volta.

### 6.5 Jails, segurança e accounting — 9 arquivos

Arquivos:

`kern_acct.c`, `kern_jail.c`, `kern_jaildesc.c`, `kern_jailmeta.c`, `kern_priv.c`, `kern_racct.c`, `kern_rctl.c`, `subr_capability.c`, `sys_capability.c`.

#### Utilização possível

- extrair threat model e política de isolamento;
- comparar hierarquia de prisons com namespaces;
- mapear limites RACCT/RCTL para cgroup v2;
- estudar disciplina de descritores do Capsicum;
- criar perfis systemd para jogos/aplicações.

#### Equivalentes Linux

- namespaces de PID, rede, mount, user, IPC e cgroup;
- cgroup v2;
- capabilities Linux;
- seccomp;
- Landlock;
- LSM/AppArmor;
- rlimits e PSI.

O cgroup v2 organiza processos hierarquicamente e distribui recursos de forma controlada: <https://docs.kernel.org/admin-guide/cgroup-v2.html>.

#### Veredito

**Reimplementar a política em userspace/Linux nativo.** Não copiar `kern_jail.c` e não chamar namespaces de Capsicum. FreeBSD Jails e Capsicum também não são o mesmo subsistema.

### 6.6 Debug, tracing e sanitizers — 19 arquivos

Arquivos:

`kern_boottrace.c`, `kern_ctf.c`, `kern_dtrace.c`, `kern_fail.c`, `kern_kcov.c`, `kern_ktr.c`, `kern_ktrace.c`, `kern_pmc.c`, `kern_sdt.c`, `kern_tslog.c`, `kern_ubsan.c`, `stack_protector.c`, `subr_asan.c`, `subr_coverage.c`, `subr_csan.c`, `subr_kdb.c`, `subr_msan.c`, `subr_prof.c`, `subr_stack.c`.

#### Utilização possível

- copiar a metodologia de landmarks de boot/shutdown;
- criar uma matriz equivalente de failpoints;
- comparar cobertura e detecção de races;
- definir testes de recuperação para NitroCore.

#### Equivalentes Linux confirmados na árvore Ubuntu

- ftrace e boot tracing;
- fault injection e `FAIL_FUNCTION`;
- KCOV;
- KASAN;
- KCSAN;
- UBSAN;
- perf/PMU;
- tracepoints/eBPF;
- lockdep.

#### Veredito

**Família de maior retorno imediato**, mas por configuração e testes, não por cópia. Criar um perfil de kernel de teste com sanitizers/fault injection e usar os casos FreeBSD como inspiração.

### 6.7 Memória, alocação e DMA — 15 arquivos

Arquivos:

`kern_malloc.c`, `kern_physio.c`, `subr_atomic64.c`, `subr_blist.c`, `subr_bus_dma.c`, `subr_busdma_bounce.c`, `subr_busdma_bufalloc.c`, `subr_memdesc.c`, `subr_pcpu.c`, `subr_pctrie.c`, `subr_physmem.c`, `subr_sfbuf.c`, `subr_sglist.c`, `subr_smr.c`, `subr_vmem.c`.

#### Utilização possível

- comparar UMA/VMEM com SLUB/genalloc;
- comparar SMR com RCU;
- estudar bounce buffers e restrições DMA;
- comparar pctrie com XArray/Maple Tree;
- estudar sfbuf/sendfile em benchmark.

#### Equivalentes Linux

- SLUB;
- DMA API e swiotlb;
- scatterlist;
- per-CPU allocations;
- RCU/SRCU;
- XArray e Maple Tree;
- genalloc.

Maple Tree é otimizada para intervalos e pode operar em modo RCU-safe: <https://docs.kernel.org/core-api/maple_tree.html>.

#### Veredito

**Não portar.** Essas estruturas sustentam o kernel inteiro e são específicas ao modelo FreeBSD. O valor é comparar algoritmos e benchmarks. `subr_pctrie.c` e `subr_vmem.c` não devem duplicar XArray/Maple Tree/genalloc.

### 6.8 Devices, bus e interrupts — 13 arquivos

Arquivos:

`firmw.S`, `kern_conf.c`, `kern_cpu.c`, `kern_devctl.c`, `kern_intr.c`, `subr_autoconf.c`, `subr_bus.c`, `subr_devmap.c`, `subr_devstat.c`, `subr_disk.c`, `subr_firmware.c`, `subr_intr.c`, `subr_rman.c`.

#### Utilização possível

- estudar Newbus e resource managers;
- comparar interrupt threading, afinidade e estatísticas;
- comparar devctl com uevents/udev;
- estudar abstração de firmware.

#### Veredito

**Referência somente.** O Linux possui driver core, bus types, resources, IRQ domains, threaded IRQ, firmware loader e uevents. Portar Newbus destruiria compatibilidade com drivers Linux.

### 6.9 VFS e armazenamento — 20 arquivos

Arquivos:

`kern_vnodedumper.c`, `subr_acl_nfs4.c`, `subr_acl_posix1e.c`, `vfs_acl.c`, `vfs_aio.c`, `vfs_bio.c`, `vfs_cache.c`, `vfs_cluster.c`, `vfs_default.c`, `vfs_export.c`, `vfs_extattr.c`, `vfs_hash.c`, `vfs_init.c`, `vfs_inotify.c`, `vfs_lookup.c`, `vfs_mount.c`, `vfs_mountroot.c`, `vfs_subr.c`, `vfs_syscalls.c`, `vfs_vnops.c`.

#### Utilização possível

- comparar negative name caching;
- estudar fast-path lookup sob SMR;
- comparar cluster read/write e readahead;
- comparar ACLs e metadata;
- benchmark de pathname lookup e metadata-heavy workloads.

#### Equivalentes Linux

- dcache/inode/page cache;
- RCU path walk;
- iomap/buffered I/O;
- readahead;
- fsnotify/inotify nativo;
- POSIX/NFS ACL;
- VFS Linux.

#### Veredito

**Não portar VFS ou vnode.** `vfs_cache.c` é valioso para estudo de políticas e benchmark, mas depende de vnode/namecache/SMR FreeBSD. `vfs_inotify.c` é uma compatibilidade FreeBSD com uma API Linux já nativa.

### 6.10 Network, sockets e IPC — 26 arquivos

Arquivos:

`kern_mbuf.c`, `kern_poll.c`, `kern_sendfile.c`, `sys_eventfd.c`, `sys_generic.c`, `sys_getrandom.c`, `sys_pipe.c`, `sys_socket.c`, `sysv_ipc.c`, `sysv_msg.c`, `sysv_sem.c`, `sysv_shm.c`, `uipc_accf.c`, `uipc_debug.c`, `uipc_domain.c`, `uipc_ktls.c`, `uipc_mbuf.c`, `uipc_mbuf2.c`, `uipc_mbufhash.c`, `uipc_mqueue.c`, `uipc_sem.c`, `uipc_shm.c`, `uipc_sockbuf.c`, `uipc_socket.c`, `uipc_syscalls.c`, `uipc_usrreq.c`.

#### Utilização possível

- benchmark comparativo de sendfile e kTLS;
- estudar socket buffer autotuning;
- comparar accept filters com `TCP_DEFER_ACCEPT`, eBPF ou io_uring;
- comparar mbuf e sk_buff somente para entender custos;
- avaliar zero-copy por APIs Linux existentes.

#### Equivalentes Linux

- sockets Linux e `sk_buff`;
- sendfile/splice;
- kTLS em `net/tls`;
- io_uring;
- eventfd;
- getrandom;
- SysV/POSIX IPC;
- AF_XDP e io_uring zero-copy conforme o caso.

#### Veredito

**Benchmark, não porte.** `uipc_ktls.c` e `kern_sendfile.c` são os melhores objetos de comparação prática, mas Linux já possui implementações próprias integradas. `sys_eventfd.c` é outra API Linux implementada no FreeBSD e não deve retornar ao Linux.

### 6.11 TTY e console — 10 arquivos

Arquivos:

`kern_cons.c`, `subr_terminal.c`, `tty.c`, `tty_compat.c`, `tty_info.c`, `tty_inq.c`, `tty_outq.c`, `tty_pts.c`, `tty_tty.c`, `tty_ttydisc.c`.

#### Utilização possível

- comparar filas de entrada/saída;
- estudar console e pseudo-terminals;
- avaliar comportamento interativo em carga.

#### Veredito

**Não portar.** Linux TTY/PTY é ABI histórica sensível e já integrada ao userspace Ubuntu. Alterações não beneficiam o objetivo imediato de gaming/desktop.

### 6.12 Infraestrutura genérica — 41 arquivos

Arquivos:

`kern_alq.c`, `kern_environment.c`, `kern_hhook.c`, `kern_khelp.c`, `kern_linker.c`, `kern_mib.c`, `kern_module.c`, `kern_osd.c`, `kern_shutdown.c`, `kern_uuid.c`, `link_elf.c`, `link_elf_obj.c`, `subr_boot.c`, `subr_bufring.c`, `subr_compressor.c`, `subr_counter.c`, `subr_early.c`, `subr_efi_map.c`, `subr_epoch.c`, `subr_eventhandler.c`, `subr_fattime.c`, `subr_filter.c`, `subr_gtaskqueue.c`, `subr_hash.c`, `subr_hints.c`, `subr_kobj.c`, `subr_log.c`, `subr_mchain.c`, `subr_module.c`, `subr_param.c`, `subr_pidctrl.c`, `subr_power.c`, `subr_prf.c`, `subr_prng.c`, `subr_rangeset.c`, `subr_sbuf.c`, `subr_scanf.c`, `subr_stats.c`, `subr_taskqueue.c`, `subr_uio.c`, `subr_unit.c`.

#### Utilização possível

- `subr_pidctrl.c`: protótipo userspace de PID controller;
- `subr_filter.c`: comparar filtro temporal min/max com `win_minmax` Linux;
- `subr_stats.c`: estudar histogramas/t-digest e serialização;
- `subr_bufring.c`: comparar com kfifo/ptr_ring;
- `subr_epoch.c`: estudar padrões e comparar com RCU;
- `subr_eventhandler.c`: comparar com notifier chains;
- taskqueues: comparar com workqueues;
- rangeset: comparar com interval trees/Maple Tree;
- sbuf: comparar com seq_buf/string helpers.

#### Veredito

**Principal fonte de algoritmos isoláveis**, mas quase todos possuem equivalentes Linux. Prioridade de estudo:

1. `subr_pidctrl.c` em userspace;
2. `subr_filter.c` versus `lib/win_minmax.c`;
3. `subr_stats.c` versus eBPF/per-CPU histograms;
4. `subr_clockcalib.c` da família de tempo;
5. `kern_boottrace.c` da família de tracing.

Não portar linkers/módulos FreeBSD, epoch, taskqueue ou KOBJ para o Linux.

### 6.13 Legado e outros — 11 arquivos

Arquivos:

`kern_context.c`, `kern_descrip.c`, `kern_dump.c`, `kern_event.c`, `kern_sysctl.c`, `kern_umtx.c`, `kern_xxx.c`, `subr_dummy_vdso_tc.c`, `subr_msgbuf.c`, `subr_trap.c`, `syscalls.c`.

#### Utilização possível

- comparar kqueue (`kern_event.c`) com epoll/io_uring;
- comparar umtx com futex;
- comparar file descriptors e lifecycle;
- estudar crash dump e logs;
- mapear sysctl FreeBSD para sysctl/debugfs/sysfs Linux apenas quando necessário.

#### Veredito

**Referência e benchmark.** kqueue e umtx não podem substituir epoll/futex sem quebrar ABI Linux. Não criar camada de compatibilidade no kernel do MVP.

## 7. Ranking de candidatos reais

### Prioridade 1 — usar imediatamente como metodologia

| Fonte FreeBSD | Uso no Ubuntu | Método |
|---|---|---|
| `kern_boottrace.c` | localizar atrasos no boot/shutdown | ftrace, bootconfig, initcall_debug, systemd-analyze |
| `kern_fail.c` | validar recuperação | fault injection Linux/KUnit/VM |
| `subr_witness.c` | detectar ordem de locks | LOCKDEP/PROVE_LOCKING |
| `kern_kcov.c`, sanitizers | ampliar testes | KCOV, KASAN, KCSAN, UBSAN Linux |
| `kern_racct.c`, `kern_rctl.c` | definir limites de sessão/game | cgroup v2/systemd scopes |

### Prioridade 2 — experimentos comparativos

| Fonte FreeBSD | Experimento |
|---|---|
| `sched_ule.c` | ULE versus EEVDF/sched_ext em latência e throughput |
| `kern_sendfile.c` | sendfile/splice/io_uring em arquivos grandes |
| `uipc_ktls.c` | kTLS throughput, CPU e latência |
| `vfs_cache.c` | pathname/metadata benchmark |
| `subr_filter.c` | equivalência e custo versus `win_minmax` |
| `subr_stats.c` | histogramas/t-digest versus eBPF/per-CPU |

### Prioridade 3 — protótipos userspace

| Fonte FreeBSD | Condição |
|---|---|
| `subr_pidctrl.c` | somente com consumidor definido, por exemplo controle térmico experimental |
| `subr_clockcalib.c` | somente para comparar precisão de calibração |
| `subr_filter.c` | somente se `win_minmax` não atender |

### Não portar

- Jails/Capsicum completos;
- VFS/vnode;
- mbuf/socket stack;
- locks/turnstiles;
- ULE dentro da classe normal Linux;
- UMA/VMEM;
- Newbus;
- linker/módulos FreeBSD;
- syscall table FreeBSD;
- TTY;
- eventfd/timerfd/inotify FreeBSD;
- procdesc como nova ABI quando pidfd já existe.

## 8. Experimentos propostos

### Experimento A — Boottrace equivalente

1. manter kernel Ubuntu sem patches;
2. habilitar ftrace e initcall debug em VM;
3. capturar boot, runtime e shutdown;
4. produzir landmarks equivalentes aos eventos FreeBSD;
5. identificar os cinco maiores intervalos;
6. otimizar userspace/systemd antes do kernel;
7. repetir ao menos 20 vezes.

Benefício: alto, risco baixo, nenhuma cópia de código.

### Experimento B — Fault injection

1. criar kernel de teste com fault injection e KUnit;
2. escolher um componente Parcel por vez;
3. injetar falha de alocação, I/O e timeout;
4. verificar recuperação e logs;
5. nunca executar inicialmente em disco físico.

Benefício: melhora real de confiabilidade e auto-cura.

### Experimento C — Scheduler

1. medir EEVDF oficial;
2. capturar frame time, input-to-photon quando houver equipamento, compilação e consumo;
3. reproduzir somente uma heurística inspirada no ULE via `sched_ext`;
4. comparar contra baseline;
5. rejeitar se houver regressão ou ganho dentro do ruído.

Benefício potencial: médio; risco controlado se mantido fora do scheduler central.

### Experimento D — Rede e arquivos

1. FreeBSD e Ubuntu em VMs equivalentes;
2. testar sendfile/kTLS com mesmo hardware virtual, arquivo e cipher;
3. medir CPU, throughput, p95/p99 e memória;
4. testar APIs Linux existentes antes de qualquer patch;
5. estudar somente o gargalo comprovado.

### Experimento E — Algoritmos isolados

1. portar `pidctrl`, clock calibration ou filtro para userspace;
2. manter copyright/licença;
3. criar vetores determinísticos;
4. executar sanitizers;
5. comparar com equivalente Linux;
6. só propor patch se houver consumidor e vantagem objetiva.

## 9. Processo obrigatório para um porte real

1. clonar `https://git.FreeBSD.org/src.git` fora da árvore Linux;
2. selecionar release/tag e registrar commit completo;
3. localizar arquivo, header, testes e histórico relacionados;
4. registrar a licença exata;
5. localizar equivalente Linux atual;
6. formular hipótese mensurável;
7. implementar primeiro em branch isolado;
8. usar API Linux, sem camada de emulação FreeBSD genérica;
9. adicionar Kconfig com padrão `n`;
10. adicionar KUnit/selftests e documentação;
11. compilar com GCC e Clang quando aplicável;
12. executar sparse, Smatch, Coccinelle, sanitizers e lockdep;
13. testar em QEMU antes de hardware;
14. preservar kernel Ubuntu oficial no GRUB;
15. medir baseline e variante;
16. remover o patch se não houver ganho significativo e reproduzível.

## 10. Relação com o NitroCore atual

Os stubs atuais não devem receber código FreeBSD indiscriminadamente:

- `nitro_sched.c`: estudar ULE via `sched_ext`, não copiar `sched_ule.c`;
- `omnilock.c`: usar APIs Linux de memória; não traduzir `vm_page_wire` mecanicamente;
- `nitro_net.c`: usar XDP/libbpf Linux; não traduzir mbuf/epoch;
- `nitro_jail.c`: começar em userspace com namespaces/cgroups/Landlock;
- `nitro_cfi.c`: usar CFI oficial do Linux/toolchain;
- `nitro_verify.c`: usar IMA/fs-verity;
- `nitro_storage.c`: usar DMA/P2PDMA apenas com provider/consumer e hardware suportado;
- `nitro_audio.c`: usar PipeWire/RT policy e drivers existentes antes de alterar IRQ no kernel.

O FreeBSD deve melhorar a qualidade das perguntas e dos testes do NitroCore, não aumentar o volume de código sem integração.

## 11. Decisão final

### Pode ser utilizado agora

- conceitos de boottrace e fault injection;
- matriz de comparação de scheduler, sendfile, kTLS e VFS cache;
- políticas de limite de recursos inspiradas em RACCT/RCTL, implementadas com cgroup v2;
- threat model de Jails/Capsicum, implementado com mecanismos Linux existentes;
- algoritmos pequenos em protótipos userspace devidamente licenciados.

### Pode ser utilizado depois de experimento

- uma heurística ULE via `sched_ext`;
- PID controller ou filtro estatístico com consumidor real;
- otimizações específicas encontradas por benchmark comparativo.

### Não deve ser utilizado no kernel Resolute

- cópia direta de qualquer arquivo completo do recorte atual;
- frameworks FreeBSD de locks, VFS, VM, Newbus, mbuf, modules, syscalls, TTY, Jail ou Capsicum;
- APIs de compatibilidade Linux reimplementadas no FreeBSD, como eventfd, timerfd e inotify;
- código sem revisão de licença e commit de origem;
- qualquer mudança que não mantenha o kernel Ubuntu oficial como fallback.

**Veredito:** o recorte `sys/kern` é valioso como laboratório de engenharia comparativa. Ele não é uma coleção de módulos transplantáveis. O maior ganho para o Parcel Play OS virá de adotar ferramentas Linux já existentes e usar o FreeBSD para desenhar benchmarks, fault tests, políticas e hipóteses específicas.

