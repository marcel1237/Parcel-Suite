# Integração de `sys/kern` do FreeBSD no Ubuntu

**Data:** 18 de agosto de 2026  
**Origem analisada:** `Kernels/FreeBSD 15/sys/kern/`  
**Alvo pretendido:** Ubuntu 26.04 Resolute, Linux 7.0 oficial  
**Alvo local disponível:** cópia Noble Linux 6.8.4, inadequada para validação
final.

## 1. Resposta direta

Não é possível adicionar o diretório `sys/kern` ao Ubuntu como se fosse um
módulo ou um conjunto de objetos Kbuild. Ele é parte central do kernel FreeBSD,
não uma biblioteca portátil. A integração viável possui três formas:

1. traduzir conceitos FreeBSD para subsistemas Linux já existentes;
2. reimplementar pequenas lacunas como patches Linux independentes;
3. executar o FreeBSD real no “FreeBSD Core” do PlayOS quando a semântica BSD
   completa for necessária.

Copiar `sys/kern/*.c` para o Linux produziria um terceiro kernel incompleto,
sem ABI coerente, e exigiria reimplementar grande parte do restante do FreeBSD.

## 2. Evidência no código

Foram encontrados 248 arquivos no primeiro nível de `sys/kern`. As inclusões
mais recorrentes foram:

| Cabeçalho FreeBSD | Arquivos que o incluem |
|---|---:|
| `sys/param.h` | 210 |
| `sys/systm.h` | 206 |
| `sys/kernel.h` | 187 |
| `sys/proc.h` | 155 |
| `sys/lock.h` | 154 |
| `sys/sysctl.h` | 142 |
| `sys/mutex.h` | 137 |
| `sys/malloc.h` | 132 |
| `vm/vm.h` | 65 |
| `sys/vnode.h` | 62 |
| `vm/uma.h` | 41 |
| `security/mac/mac_framework.h` | 40 |

Esses nomes podem lembrar conceitos Linux, mas não possuem layout, contrato ou
semântica intercambiável. Exemplos de dependências:

- `struct proc` e `struct thread` não são `task_struct`;
- `vnode` não é `inode`/`dentry`;
- `mbuf` não é `sk_buff`;
- UMA não é SLUB/SLAB;
- epoch/SMR não são a API RCU do Linux;
- SYSINIT não é initcall;
- VNET não é network namespace;
- FreeBSD MAC Framework não é LSM;
- sleepqueues, turnstiles e locks obedecem contratos internos distintos.

Contagem indicativa de referências a estruturas e primitivas BSD em arquivos
críticos:

| Arquivo | Referências indicativas |
|---|---:|
| `kern_jail.c` | 193 |
| `subr_epoch.c` | 187 |
| `sched_ule.c` | 117 |
| `uipc_ktls.c` | 90 |
| `kern_sendfile.c` | 31 |

Os poucos arquivos sem inclusão BSD direta detectada são principalmente fontes
geradas ou wrappers (`syscalls.c`, `systrace_args.c`, `imgact_elf32.c` e
`imgact_elf64.c`); eles dependem de inclusão textual, geração e contexto externo
e também não são bibliotecas autônomas.

## 3. Mapeamento correto

| `sys/kern` FreeBSD | Ubuntu/Linux | Ação PlayOS |
|---|---|---|
| `init_main.c`, SYSINIT | initcalls, initramfs, systemd | medir e usar fluxo Linux |
| `kern_boottrace.c`, TSLOG/KTR | bootconfig, ftrace, tracepoints | configurar, não portar |
| `kern_fail.c` | fault injection Linux | flavour de laboratório |
| `sched_ule.c` | scheduler Linux/EEVDF, `sched_ext` | política experimental, não cópia |
| `kern_jail*.c` | namespaces, cgroup v2, LSM | Play Sandbox em userspace |
| `kern_racct.c`, `kern_rctl.c` | cgroup v2, PSI, rlimits | daemon/políticas Linux |
| Capsicum | seccomp, Landlock, LSM, capabilities | traduzir perfis |
| `kern_sendfile.c` | `sendfile`, splice, page cache | benchmark; manter Linux |
| `uipc_ktls.c` | `net/tls` kTLS | testar implementação Linux |
| `uipc_mbuf*.c` | `sk_buff`, page pool | não portar buffers |
| `subr_epoch.c`, `subr_smr.c` | RCU/SRCU | usar RCU Linux |
| mutex/sx/rwlock/turnstile | mutex, rwsem, spinlock, PI | usar primitivas Linux |
| `vfs_cache.c` | dcache/path lookup/RCU-walk | medir antes de patch |
| `vfs_aio.c` | AIO/io_uring | usar API Linux |
| `sys_eventfd.c`, `sys_timerfd.c` | eventfd/timerfd nativos | nenhuma duplicação |
| `sys_getrandom.c` | getrandom/CRNG Linux | nenhuma duplicação |
| kqueue/event | epoll/io_uring | adaptação no userspace |
| DTrace/HWPMC | perf/ftrace/eBPF | API comum de telemetria |
| Jail/VNET completos | FreeBSD Core em KVM | executar FreeBSD real |

A árvore Linux local já contém `kernel/sched`, `kernel/bpf`, `kernel/trace`,
`lib/fault-inject.c`, `security/landlock`, `io_uring` e `net/tls`. Duplicar esses
subsistemas com versões FreeBSD aumentaria superfície de ataque e manutenção.

## 4. Arquitetura de integração

```text
FreeBSD sys/kern
       │
       ├── comportamento/invariantes ──► testes comparativos
       │                                  │
       │                                  ▼
       ├── equivalente Linux ──────────► configuração/userspace
       │
       ├── lacuna mensurável ──────────► patch Linux pequeno e nativo
       │
       └── semântica BSD integral ─────► FreeBSD Core (KVM)
```

### Camada A — sem patch

Prioridade máxima. Boottrace, fault injection, sendfile, kTLS, isolamento e
telemetria já possuem mecanismos Linux. Criar configuração, ferramentas,
benchmarks e políticas PlayOS.

### Camada B — patch Linux nativo

Somente quando um teste comprovar lacuna. O patch deve usar APIs Linux, ter
escopo pequeno, KUnit/selftests, configuração opt-in, fallback e benchmark.
Exemplos aceitáveis incluem tracepoint ausente ou contador necessário. Um novo
scheduler, nova VFS ou segunda pilha TLS não são primeiros patches aceitáveis.

### Camada C — FreeBSD Core

Para Jails/VNET, ULE, Capsicum/MAC, ZFS BSD, DTrace ou pilha FreeBSD completa,
executar FreeBSD 15.1 no subsistema KVM já desenhado para o PlayOS. Serviços são
expostos ao Ubuntu por API e rede VirtIO; código de kernel não cruza a fronteira.

## 5. Scheduler ULE

`sched_ule.c` não pode ser convertido por substituição de tipos. Ele depende de
runqueues, topologia, locks, prioridades, threads, timers e accounting FreeBSD.

Plano correto:

1. definir workloads de jogo, compilação e desktop;
2. medir Linux padrão e ULE em sistemas separados;
3. extrair somente a política que explica diferença reproduzível;
4. experimentar a política por `sched_ext` no Linux 7.0/7.x quando disponível
   e habilitado no baseline Ubuntu;
5. manter fallback automático para o scheduler Linux;
6. nunca copiar runqueues ou locks do ULE.

## 6. Jails e segurança

Uma Jail não pode ser criada dentro do kernel Linux importando `kern_jail.c`.
O PlayOS deve oferecer um perfil declarativo comum:

```text
Play Sandbox profile
├── backend Linux: namespaces + cgroup + seccomp + Landlock/AppArmor
└── backend FreeBSD Core: Jail + VNET + RCTL + Capsicum/MAC
```

O contrato pode compartilhar JSON/YAML, testes e experiência de usuário. A
implementação permanece nativa de cada kernel.

## 7. Rede, sendfile e kTLS

O caminho de dados FreeBSD usa `mbuf`, sockets e VNET próprios. Linux usa
`sk_buff`, sockets, page cache e netdevice APIs próprias. Portar
`kern_sendfile.c` ou `uipc_ktls.c` exigiria substituir toda a infraestrutura ao
redor.

O trabalho útil é executar o mesmo benchmark nos dois sistemas:

- arquivo frio/quente;
- HTTP/TLS e tamanho de objeto;
- CPU, throughput, p50/p95/p99;
- cópias e page faults;
- NIC com e sem offload;
- memória sob pressão.

Se Linux perder, localizar a causa e corrigir o subsistema Linux específico.

## 8. Algoritmos potencialmente reutilizáveis

Arquivos como `subr_hash.c`, `subr_blist.c`, compressores ou estruturas pequenas
podem conter algoritmos separáveis, mas não devem ser copiados automaticamente.
Para cada candidato:

1. comprovar consumidor no PlayOS;
2. identificar todas as dependências;
3. revisar SPDX, avisos e histórico;
4. comparar com implementação Linux existente;
5. preferir implementação independente baseada em especificação/testes;
6. executar KUnit, fuzzing e benchmark;
7. manter atribuições exigidas se houver derivação.

## 9. Licenciamento

`sys/kern` contém BSD-2-Clause, BSD-3-Clause, BSD-4-Clause e outros históricos.
Licença permissiva não significa integração automática. Cada arquivo precisa de
revisão individual, preservação de avisos e avaliação da licença final do objeto
ligado ao kernel GPL-2.0. Código Linux GPL não pode voltar ao FreeBSD como BSD.

Clean-room reduz risco de dependência estrutural e de proveniência, mas não
substitui revisão jurídica quando o projeto distribuir binários e fontes.

## 10. Processo de aplicação

Para cada caso de estudo:

1. escrever requisito observável;
2. criar teste idêntico Linux/FreeBSD;
3. coletar baseline em versões fixadas;
4. procurar mecanismo Linux existente;
5. resolver primeiro por configuração/userspace;
6. escrever patch mínimo somente se necessário;
7. validar `git apply --check`, build e KUnit/selftests;
8. iniciar em VM com kernel oficial como fallback;
9. executar regressão, carga e segurança;
10. promover para produção apenas com benefício comprovado.

## 11. Estado dos patchsets existentes

`patch-FreeBSD-Ubuntu/` já segue parcialmente essa regra: documentação,
bootconfig e selftests. Os patches passaram apenas contra a cópia Noble 6.8
local e ainda não estão validados no Ubuntu Resolute Linux 7.0 oficial.

Antes de ampliar a série:

- obter árvore Resolute 7.0 verificável em caminho sem espaços;
- repetir todos os checks;
- revisar recursos já presentes no 7.0;
- compilar, empacotar e iniciar em VM;
- manter alterações destrutivas somente no flavour de laboratório.

## 12. Veredito

Não colocar fisicamente `sys/kern` dentro da árvore Ubuntu. Colocar suas ideias
no PlayOS por tradução de comportamento, testes comparativos e patches Linux
pequenos. Quando o objetivo exigir o FreeBSD verdadeiro, encaminhá-lo ao
FreeBSD Core virtualizado.

Essa solução entrega benefícios do FreeBSD sem transformar o kernel Ubuntu em
um fork impossível de atualizar. A unidade do PlayOS deve existir nas APIs e na
experiência userspace; os kernels permanecem responsáveis por suas próprias
estruturas internas.
