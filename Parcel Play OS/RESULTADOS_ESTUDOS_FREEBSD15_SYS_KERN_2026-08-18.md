# Resultados dos Estudos FreeBSD 15 `sys/kern` versus Ubuntu

**Data:** 18 de agosto de 2026  
**Suíte:** `studies/freebsd15_sys_kern/`  
**Host:** Ubuntu, kernel `7.0.0-29-generic`, x86_64  
**Objetivo:** executar os casos A–E definidos em `PORTABILIDADE_FREEBSD15_SYS_KERN_PARA_UBUNTU.md` sem modificar o kernel ativo ou armazenamento permanente.

## 1. Estado geral

| Caso | Execução possível | Resultado |
|---|---|---|
| A — Boottrace | Parcial | Coletor executado; systemd bus e tracefs bloqueados pelo sandbox |
| B — Fault injection | Prontidão somente | Configuração auditada; injeção real bloqueada fora de VM descartável |
| C — Scheduler | Sim, userspace | `SCHED_OTHER` e `SCHED_BATCH` medidos em cinco repetições |
| D — Rede/arquivos | Parcial | `read/write` versus `sendfile` medido; FreeBSD, rede externa e kTLS bloqueados |
| E — Algoritmos | Sim | PID, min/max e regressão incremental implementados e testados |

Nenhum caso alterou sysctl, tracefs, debugfs, GRUB, módulos, discos ou o scheduler global do sistema.

## 2. Estrutura criada

```text
studies/freebsd15_sys_kern/
├── Makefile
├── README.md
├── collect_boot_study.sh
├── check_fault_injection.sh
├── repeat_benchmarks.sh
├── run_all.sh
├── src/
│   ├── algorithms.c
│   ├── algorithms.h
│   ├── algorithm_tests.c
│   ├── io_bench.c
│   └── scheduler_bench.c
└── results/
    ├── algorithm-tests.txt
    ├── boot-study.txt
    ├── environment.txt
    ├── fault-injection-study.txt
    ├── io-study.txt
    ├── repeated-benchmarks.txt
    ├── scheduler-batch.txt
    └── scheduler-other.txt
```

Os binários são artefatos locais ignorados pelo Git. Fontes, scripts e resultados textuais permanecem auditáveis.

## 3. Build e validação básica

Comandos executados:

```sh
make clean
make all
make test
make run
./repeat_benchmarks.sh 5
```

Flags de compilação:

```text
-O2 -g -std=c11 -Wall -Wextra -Werror
```

Resultados:

- três binários compilados sem warnings;
- testes de algoritmos: `PASS`;
- suíte completa executada sem alterar o host;
- cinco repetições adicionais concluídas.

Também foi gerado um binário temporário com AddressSanitizer e UndefinedBehaviorSanitizer. A primeira execução falhou porque LeakSanitizer não funciona no ambiente supervisionado/ptrace. Com detecção de leaks desativada, ASan/UBSan executaram e os testes passaram. Isso não substitui Valgrind, fuzzing ou testes de kernel.

## 4. Caso A — Boottrace equivalente

### Objetivo

Reproduzir a metodologia de `kern_boottrace.c`: registrar landmarks de boot, runtime e shutdown e localizar os maiores intervalos.

### Resultado do host

- kernel: `7.0.0-29-generic`;
- tracefs montado em `/sys/kernel/tracing`;
- tracefs somente leitura;
- `available_events` não legível;
- `tracing_on` não gravável;
- `systemd-analyze` não conseguiu acessar o system bus no sandbox;
- logs de kernel não forneceram landmarks acessíveis no contexto atual.

### Veredito

O coletor e o formato de evidência estão prontos, mas tempos reais de boot não foram obtidos nesta sessão. A execução completa requer uma sessão com acesso ao system bus e tracefs, preferencialmente dentro da VM de teste da ISO.

Não é necessário portar `kern_boottrace.c`; ftrace, bootconfig, `initcall_debug` e `systemd-analyze` continuam sendo a solução correta.

## 5. Caso B — Fault injection

### Objetivo

Usar as ideias de `kern_fail.c` para comprovar recuperação diante de falha de alocação, I/O ou funções selecionadas.

### Resultado do host

Configurações detectadas:

```text
CONFIG_UBSAN=y
CONFIG_FUNCTION_ERROR_INJECTION=y
```

Nós indisponíveis:

- `/sys/kernel/debug/failslab`;
- `/sys/kernel/debug/fail_page_alloc`;
- `/sys/kernel/debug/fail_function`.

Debugfs está somente leitura. Nenhuma falha foi injetada.

### Veredito

O estudo de prontidão foi executado corretamente. A injeção real permanece bloqueada por segurança até existirem:

1. QEMU/KVM;
2. disco virtual descartável;
3. kernel de teste com opções necessárias;
4. alvo de falha específico;
5. condição de recuperação verificável;
6. snapshot ou recriação automatizada da VM.

Executar fault injection no host de desenvolvimento não é aceitável.

## 6. Caso C — Scheduler

### Método

O benchmark mede a latência entre sinalização de uma condition variable e execução da thread acordada, com 20.000 iterações por execução.

Foram comparadas políticas disponíveis sem privilégio:

- `SCHED_OTHER`;
- `SCHED_BATCH`.

Cinco repetições foram realizadas.

### Resultados agregados

| Política | Média das médias | Faixa da média | Média do p99 | Faixa do p99 |
|---|---:|---:|---:|---:|
| OTHER | 9,391 µs | 8,982–10,685 µs | 17,488 µs | 15,854–21,301 µs |
| BATCH | 9,102 µs | 8,919–9,358 µs | 16,441 µs | 15,854–17,321 µs |

Outliers máximos variaram de dezenas de microssegundos a alguns milissegundos. O ambiente desktop não foi isolado, não houve pinagem de CPU, controle térmico ou bloqueio de frequência.

### Interpretação

- As políticas ficaram próximas neste microbenchmark.
- A diferença observada não prova superioridade de BATCH.
- Os outliers mostram interferência do ambiente.
- O teste não representa frame time, input-to-photon, compilação ou consumo energético.
- Não há evidência para substituir EEVDF ou inserir ULE no kernel Ubuntu.

### Próximo passo correto

Executar EEVDF como baseline e uma heurística ULE somente via `sched_ext`, em VM/hardware controlado, usando workloads reais e pelo menos 30 repetições.

O kernel do host declara `CONFIG_SCHED_CLASS_EXT=y`, mas nenhum scheduler BPF foi carregado nesta auditoria porque isso alteraria o comportamento do sistema ativo.

## 7. Caso D — Rede e arquivos

### Método executado

Foi criado um arquivo temporário anônimo de 64 MiB em `/tmp`. Seu conteúdo foi transferido por um `socketpair(AF_UNIX, SOCK_STREAM)` usando:

1. loop `read` + `write` com buffer de 128 KiB;
2. `sendfile`.

Uma thread receptora drenou o socket e validou que todos os 67.108.864 bytes foram recebidos.

### Resultados de cinco repetições

| Método | Média | Mínimo | Máximo |
|---|---:|---:|---:|
| `read/write` | 2.225,51 MiB/s | 2.132,17 | 2.345,64 |
| `sendfile` | 4.922,52 MiB/s | 4.538,81 | 5.134,32 |

Razão entre as médias:

```text
sendfile / read-write = 2,212×
```

### Interpretação

O resultado confirma que reduzir cópias e transições pode beneficiar esse caminho local específico. Ele não demonstra:

- desempenho de rede física;
- zero-copy completo de disco para NIC/GPU;
- kTLS;
- io_uring;
- P2PDMA;
- comportamento do FreeBSD;
- desempenho de jogos.

O arquivo provavelmente foi servido pelo page cache depois da criação. `socketpair` não atravessa uma NIC. Portanto, os valores não devem ser usados em marketing ou dimensionamento.

### Bloqueios

- `iperf3` ausente;
- `fio` ausente;
- `/proc/net/tls_stat` ausente;
- FreeBSD não executável;
- QEMU/KVM ausentes.

### Decisão

Continuar usando `sendfile`, splice, io_uring e kTLS oficiais do Linux antes de qualquer porte FreeBSD. O harness demonstrou uma metodologia, não necessidade de novo código de kernel.

## 8. Caso E — Algoritmos isolados

### Implementações

Foram criadas implementações independentes em userspace, GPL-2.0-only, para estudar ideias genéricas observadas em:

- `subr_pidctrl.c`;
- `subr_filter.c`;
- `subr_clockcalib.c`.

As implementações não usam headers ou APIs FreeBSD e não são portes de kernel.

### Testes

- PID produz saída positiva diante de erro positivo;
- resposta diminui quando o input se aproxima do setpoint;
- integral é limitada para evitar wind-up;
- mínimo/máximo retornam valores corretos;
- regressão incremental recupera inclinação 3,0 em 1.000 pontos;
- compilação sem warnings;
- testes normais: `PASS`;
- ASan/UBSan sem leak detection: `PASS`.

### Decisão por algoritmo

| Algoritmo | Resultado | Entrada no kernel? |
|---|---|---|
| PID | Correção básica demonstrada | Não; falta consumidor real |
| Min/max | Correção básica demonstrada | Não; Linux possui `win_minmax` |
| Regressão incremental | Correção básica demonstrada | Não; falta necessidade de calibração |

Os protótipos servem para comparar resultados futuros e não justificam criar novos helpers no kernel.

## 9. Recursos detectados no host

Presentes:

- GCC e Make;
- `perf`;
- `taskset` e `chrt`;
- OpenSSL;
- `bpftool`, `bpftrace` e `trace-cmd`;
- BPF, `SCHED_CLASS_EXT`, cgroups, namespaces, TLS e XDP configurados no kernel.

Ausentes ou inacessíveis:

- QEMU;
- `/dev/kvm`;
- FreeBSD inicializável;
- `iperf3`;
- `fio`;
- Gamescope;
- tracefs/debugfs graváveis;
- system bus acessível;
- estatísticas kTLS.

## 10. O que foi realmente concluído

### Concluído

- suíte reproduzível dos cinco casos;
- build com warnings como erro;
- testes dos algoritmos;
- benchmark de scheduler em userspace;
- benchmark `read/write` versus `sendfile`;
- coleta de evidências de boot e fault injection;
- cinco repetições e resultados brutos preservados;
- execução segura sem mudanças no kernel ativo.

### Parcial por bloqueio ambiental

- captura real de boottrace;
- fault injection real;
- scheduler `sched_ext`/ULE;
- teste FreeBSD versus Ubuntu;
- rede física, io_uring e kTLS;
- VFS cache comparativo.

## 11. Próxima infraestrutura necessária

Para completar os comparativos que dependem de kernel/OS:

1. instalar QEMU e OVMF;
2. disponibilizar `/dev/kvm` quando o host permitir;
3. obter uma ISO ou árvore FreeBSD completa e fixada;
4. criar duas VMs equivalentes;
5. instalar `fio` e `iperf3` em ambas;
6. construir kernel Ubuntu de teste com debug/fault injection;
7. executar os mesmos manifests de benchmark;
8. repetir em estado térmico e carga controlados;
9. armazenar versões, configurações e resultados brutos.

## 12. Conclusão

Todos os casos receberam implementação e execução compatível com a segurança e as capacidades desta sessão. Os resultados reforçam a conclusão anterior:

- ferramentas Linux existentes já permitem estudar as ideias FreeBSD;
- `sendfile` merece ser usado, não reimplementado;
- não existe evidência para um scheduler NitroCore/ULE;
- algoritmos isolados funcionam em userspace, mas não possuem justificativa para entrar no kernel;
- boottrace e fault injection exigem ambiente controlado;
- comparação FreeBSD–Ubuntu exige duas instalações executáveis, não apenas fontes.

Nenhum resultado autoriza afirmar ganhos de FPS, latência zero, superioridade geral ou equivalência com tecnologias FreeBSD.

