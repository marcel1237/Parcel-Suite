# Análise Linux 7.1.8 → FreeBSD 15.1-p2

## Objetivo

Identificar recursos do Linux 7.1.8 que possam melhorar o FreeBSD sem quebrar
sua arquitetura, ABI, licença ou modelo de manutenção. “Melhor” significa
resolver uma lacuna mensurável, não acumular subsistemas duplicados.

## Bases analisadas

### Linux

- versão declarada 7.1.8;
- árvore local sem origem Git verificável;
- `sched_ext`, NTSYNC, bootconfig/ftrace, fault injection, kTLS, Landlock,
  KASAN/KCSAN/KCOV e infraestrutura BPF presentes.

### FreeBSD

- FreeBSD 15.1-RELEASE-p2;
- tag `release/15.1.0-p2`;
- commit `aadd58dddcbc78f4d5594827b46b5633552b15ce`;
- remote oficial;
- fonte completa, incluindo world, kernel, loader, release e testes;
- checkout raso e detached, mas limpo e exatamente na tag.

## Regra de licença

O kernel Linux é predominantemente GPL-2.0. Código de seus subsistemas não
deve ser copiado para o kernel FreeBSD. São permitidos como entrada:

- documentação pública de comportamento;
- requisitos e invariantes;
- resultados de benchmarks;
- casos de teste escritos de forma independente;
- formatos de ABI que sejam documentados e juridicamente revisados;
- ideias gerais não protegidas como expressão de código.

Toda implementação FreeBSD deve ser nativa, preferencialmente BSD-2-Clause, e
passar por revisão de proveniência.

## Concorrência e memória

Linux usa RCU em larga escala. FreeBSD já oferece epoch e SMR, além de atomics,
uma variedade de locks e WITNESS. Não faz sentido importar RCU como uma camada
paralela.

O trabalho útil é comparar:

- latência de leitores;
- custo de grace periods;
- pressão de callbacks;
- comportamento em CPU hotplug;
- detecção de uso incorreto;
- documentação de padrões epoch/SMR.

Qualquer melhoria deve entrar nas APIs epoch/SMR existentes.

## Scheduler

Linux 7.1.8 possui EEVDF e `sched_ext`. FreeBSD possui ULE, 4BSD e um selector
de schedulers em `sched_shim.c`.

O aspecto interessante de `sched_ext` não é seu código BPF, mas:

- políticas experimentais descarregáveis;
- fallback seguro quando a política falha;
- iteração sem alterar o scheduler principal;
- testes de starvation, hotplug e limites.

Uma eventual solução FreeBSD deve ser muito menor e nativa. Antes disso, usar
os sysctls ULE, KTR, DTrace, HWPMC e benchmarks controlados. Não expor ponteiros
ou runqueues internos a módulos não confiáveis.

## Pressão de recursos

Linux PSI oferece sinais agregados de contenção de CPU, memória e I/O. FreeBSD
possui `vm.stats`, scheduler stats, RACCT/RCTL, GEOM e contadores por subsistema,
mas uma ABI consolidada semelhante pode ser uma lacuna real.

Próximo estudo recomendado:

1. inventariar todos os contadores existentes;
2. definir consumidores — desktop, orchestrator, OOM policy;
3. criar coletor userspace antes de ABI kernel;
4. medir overhead e correlação com latência;
5. somente então propor eventos/counters novos.

## Isolamento e segurança

Linux combina namespaces, cgroup, seccomp, Landlock e LSMs. FreeBSD já possui
Jails/VNET, RACCT/RCTL, Capsicum e MAC Framework. O ganho está em melhorar
composição, ferramentas e testes, não em portar namespaces Linux.

Para imagem imutável, comparar IMA/fs-verity com:

- MAC/veriexec;
- ZFS boot environments;
- assinatura de pacotes/base;
- securelevel e políticas de loader;
- auditoria.

O threat model deve decidir a solução.

## NTSYNC

Linux 7.1.8 contém driver NTSYNC para primitivas Windows NT. FreeBSD não possui
equivalente direto identificado. Esse é um candidato relevante para gaming,
mas não é um patch pequeno.

Uma implementação limpa requer:

- especificação independente de ABI e sem cópia GPL;
- integração com poll/kqueue;
- objetos wait-all/wait-any corretos e sem deadlock;
- limites RACCT e isolamento por jail;
- compatibilidade 32/64 bits;
- testes Wine/Proton e stress concorrente;
- auditoria de lifetime, handles e races.

Até isso existir, não declarar NTSYNC implementado no FreeBSD.

## I/O assíncrono

Linux possui io_uring; FreeBSD possui kqueue, POSIX AIO, sendfile e
`socket_splice`. A comparação deve ser por workload e sem assumir superioridade
universal.

Investigar:

- submissão e conclusão em lote;
- cópias e pinagem de páginas;
- cancelamento;
- segurança de buffers registrados;
- filesystem e rede;
- custo de syscalls;
- integração com capsicum/jails.

Uma nova ABI só é justificável se kqueue/AIO não puderem atender o caso.

## Sendfile e kTLS

FreeBSD já possui implementações maduras e testes ATF, inclusive injeção de
falhas de I/O e teste kTLS. O Linux serve como baseline comparativo para:

- TLS TX/RX;
- offload software e NIC;
- retransmissões;
- NUMA e afinidade dos workers;
- page cache frio/quente;
- sendfile sobre diferentes filesystems;
- CPU por byte e p99 de latência.

Não portar `sk_buff`, page-frag ou workqueues Linux.

## Fault injection e sanitizers

FreeBSD já possui `fail(9)`/`KFAIL_POINT`, KASAN, KCSAN, KMSAN e KCOV. O ganho
imediato é ampliar os testes e padronizar perfis de laboratório.

O patch `PARCEL-LAB` combina:

- GENERIC-DEBUG;
- WITNESS e INVARIANTS herdados;
- TSLOG;
- cobertura genérica;
- KCOV.

KASAN, KCSAN e KMSAN permanecem variantes separadas porque não devem ser
empilhados indiscriminadamente.

## Tracing

Linux tem ftrace, perf, tracepoints e BPF. FreeBSD possui DTrace/SDT, HWPMC,
KTR, TSLOG, boottrace e netlink. O método recomendado é mapear eventos ausentes,
adicionar probes SDT pequenos e evitar um segundo framework global.

## LinuxKPI

LinuxKPI é apropriado para compatibilidade de drivers, sobretudo gráficos e
wireless. Não deve ser usado como justificativa para importar scheduler, VFS,
RCU, cgroup ou outras estruturas internas Linux. Quanto maior o subsistema,
maior o custo de manter semântica incompatível.

## Roadmap

### Fase 0 — baseline

- clone/worktree sem espaços;
- confirmar tag e hash;
- buildworld/buildkernel sem patches;
- boot GENERIC em VM;
- executar Kyua relevante.

### Fase 1 — série segura atual

- manual de regras;
- config PARCEL-LAB;
- ATF de capacidades;
- build e boot em VM.

### Fase 2 — medição

- scheduler ULE/4BSD;
- sendfile/kTLS;
- epoch/SMR;
- pressão de recursos;
- desktop/gaming.

### Fase 3 — primeiro patch funcional

Escolher apenas uma lacuna comprovada. Preferência: tracepoint SDT, contador de
pressão ou teste de falha, antes de nova ABI.

### Fase 4 — pesquisas grandes

- NTSYNC clean-room;
- pressão agregada tipo PSI;
- scheduler experimental com fallback;
- evolução de AIO.

## Critérios de rejeição

Rejeitar qualquer mudança que:

- copie código GPL para o kernel FreeBSD;
- duplique mecanismo nativo sem ganho;
- quebre ABI ou módulos sem plano;
- exija desabilitar segurança;
- não tenha teste e rollback;
- só melhore uma execução isolada;
- cause panic, witness warning, sanitizer report ou corrupção;
- não preserve GENERIC como fallback.

## Conclusão

FreeBSD 15.1 já contém muitos dos pontos fortes que seriam procurados no Linux.
As maiores oportunidades são uma metodologia mais sistemática de testes,
telemetria de pressão agregada, experimentação segura de scheduler e, para
gaming, uma investigação clean-room de NTSYNC. O patchset inicial constrói o
laboratório e os gates necessários sem comprometer a licença ou a estabilidade.
