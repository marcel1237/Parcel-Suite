# Roadmap do kernel PlayOS Noble + FreeBSD

## Fase 1 — identidade, medição e fallback

- manter branch e sufixo próprios;
- preparar worktree em caminho sem espaços;
- gerar configuração a partir do Ubuntu generic;
- integrar bootconfig e selftests;
- compilar e empacotar sem otimizações;
- iniciar em VM mantendo kernel Ubuntu oficial.

## Fase 2 — recursos existentes no Linux

- namespaces, cgroup v2, seccomp, Landlock e AppArmor;
- kTLS e sendfile/splice;
- ftrace, tracepoints, perf, PSI e BPF restrito;
- fault injection somente no lab;
- KASAN/KCSAN/KCOV em builds separados.

Resultado esperado: benefícios funcionais inspirados no FreeBSD sem patch de
subsistema.

## Fase 3 — Play Sandbox

- perfil declarativo inspirado em Jails/VNET/RCTL/Capsicum;
- backend Linux com namespaces, cgroup v2, seccomp e LSM;
- limites de CPU, memória, PIDs, I/O e rede;
- testes de escape, exaustão e visibilidade;
- backend FreeBSD Core usando Jail/VNET/RCTL para equivalência funcional.

## Fase 4 — desempenho de dados

- comparar sendfile, splice e kTLS Linux com FreeBSD;
- workloads frio/quente e objetos pequenos/grandes;
- NIC com/sem offload;
- medir throughput, CPU, p50/p95/p99 e memória;
- criar patch Linux somente para causa demonstrada.

## Fase 5 — scheduler

Linux 6.8 local não possui `sched_ext`. Portanto:

- medir scheduler Linux padrão contra ULE em máquinas separadas;
- testar cgroup, uclamp, prioridades e afinidade primeiro;
- instrumentar latência e starvation;
- não copiar `sched_ule.c`;
- avaliar backport de `sched_ext` apenas como projeto independente de alto risco,
  ou migrar o experimento para kernel Linux posterior.

## Fase 6 — algoritmos pequenos

- selecionar somente algoritmo com consumidor real;
- revisar licença e dependências;
- preferir implementação clean-room;
- adicionar KUnit, fuzzing e benchmark;
- rejeitar duplicação de hash/lista/alocador já existente no Linux.

## Fase 7 — qualificação

- builds reproduzíveis amd64;
- pacote coexistente com Ubuntu;
- Secure Boot/assinatura;
- 100 boots em VM;
- suspend/resume e carga;
- testes de segurança;
- matriz AMD/Intel/NVIDIA;
- rollback comprovado.
