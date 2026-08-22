# Relatório de Aplicação dos Estudos FreeBSD 15 no Ubuntu Resolute

**Projeto:** Parcel Play OS

**Data da auditoria:** 18 de agosto de 2026

**Árvore Linux auditada:** `Kernels/ubuntu 26 resolute kernel/`

**Fonte conceitual:** `Kernels/FreeBSD 15/sys/kern/`

**Suíte experimental:** `studies/freebsd15_sys_kern/`

**Natureza deste documento:** análise técnica e plano de aplicação. Nenhuma
alteração foi aplicada ao kernel Ubuntu nesta etapa.

## 1\. Resumo executivo

É possível aproveitar no Parcel Play OS várias ideias observadas no `sys/kern`
do FreeBSD, mas a aplicação correta no Ubuntu não é copiar arquivos FreeBSD
para a árvore Linux. O caminho tecnicamente seguro é:

1.  corrigir e fixar a árvore Ubuntu Resolute usada como baseline;
2.  reproduzir os comportamentos desejados usando subsistemas Linux existentes;
3.  executar os estudos A–E primeiro sem patches;
4.  criar patches pequenos somente quando uma diferença mensurável permanecer;
5.  empacotar pelo mecanismo Ubuntu, preservando o kernel oficial como fallback;
6.  validar cada mudança em VM descartável antes de qualquer máquina física.

### Veredito principal


|Área inspirada no FreeBSD|Aplicação recomendada no Ubuntu                             |Precisa alterar o kernel agora?      |
|-------------------------|------------------------------------------------------------|-------------------------------------|
|Boottrace                |Bootconfig, tracefs, ftrace, initcall tracepoints e systemd |Não                                  |
|Fault injection          |Framework Linux existente em kernel de laboratório          |Apenas configuração de variante debug|
|Scheduler ULE            |Benchmark, tracing e depois `sched_ext` em baseline compatível|Não nesta árvore 6.8                 |
|`sendfile`               |`sendfile(2)`, splice e page cache Linux                    |Não                                  |
|kTLS                     |módulo `tls`, sockets TLS e selftests de rede               |Não inicialmente                     |
|Jails/VNET               |namespaces, cgroup v2, seccomp, Landlock e AppArmor         |Não; majoritariamente userspace      |
|Algoritmos pequenos      |userspace + KUnit antes de integração                       |Talvez, depois de evidência          |
|VFS/namecache            |medir dcache, RCU e pathname lookup Linux                   |Não inicialmente                     |
|Locks/RCU                |lockdep, RCU e sanitizers Linux                             |Não portar primitivas FreeBSD        |

O resultado dos estudos já executados não justifica substituir o scheduler
Linux, reimplementar `sendfile`, importar kTLS do FreeBSD ou criar um subsistema
Jail dentro do kernel. Ele justifica construir uma plataforma de medição e uma
variante de kernel de laboratório.

## 2\. Estado real da pasta chamada Ubuntu Resolute

O Ubuntu 26.04 LTS Resolute final usa oficialmente Linux 7.0. Essa identidade
foi confirmada pelo anúncio da Equipe de Kernel da Canonical e pelo changelog
do pacote `linux` no Launchpad. Consulte `
VERIFICACAO_KERNEL_UBUNTU_RESOLUTE_2026-08-18.md`.

### 2.1 Identidade encontrada

A pasta auditada possui:

- remote Git: 
  `https://git.launchpad.net/~ubuntu-kernel/ubuntu/+source/linux/+git/resolute`;
- branch local: `master`;
- commit: `74134bfb6b720ca18a73931662cbcc8170ef1bed`;
- data do commit: 9 de abril de 2024;
- assunto: `UBUNTU: \\\[Packaging] update dependencies for rtla`;
- repositório shallow: sim;
- somente `master` e `origin/master` disponíveis localmente;
- árvore de trabalho: limpa durante a inspeção.

Entretanto, o conteúdo não corresponde a um baseline atual de Ubuntu Resolute:

- `Makefile` declara Linux `6.8.4`;
- `debian.master/changelog` começa com `linux (6.8.0-30.30) noble`;
- o changelog é datado de abril de 2024;
- não há tag local útil porque o clone é raso e contém um único histórico
  enxertado.

### 2.2 Consequência

O nome da pasta e a URL do remote não bastam para provar que o conteúdo é
Resolute. Antes de desenvolver patches, deve existir um manifesto contendo:

- URL;
- branch;
- commit completo;
- versão produzida por `make kernelversion`;
- primeiro registro do changelog;
- data de obtenção;
- hash da configuração `amd64/generic`;
- hash dos patches Parcel aplicados.

Aplicar mudanças agora produziria patches sobre Noble 6.8 e poderia gerar
falsas alegações de compatibilidade com o Resolute Linux 7.0.

### 2.3 Estado de build

Foram encontrados aproximadamente 83.587 arquivos e 1,8 GiB. Há cerca de 94 GiB
livres no filesystem, mas a árvore ainda não está preparada:

- `.config`: ausente;
- `debian/build`: ausente;
- `debian/control`: ausente, portanto `dpkg-checkbuilddeps` ainda não consegue
  resolver a lista de dependências;
- GCC 15.2.0, GNU Make 4.4.1, `fakeroot` e `dpkg-buildpackage`: presentes;
- Clang: não localizado na inspeção.

Há ainda um bloqueio de caminho confirmado. A execução de `make -s kernelversion`
terminou com:

```text
Makefile:201: *** source directory cannot contain spaces or colons. Stop.
```
A árvore está sob caminhos que contêm espaços (`Parcel Suite`, `Parcel Play OS`
e `ubuntu 26 resolute kernel`). O Kbuild não aceita essa localização. O build
deve ocorrer em uma worktree ou clone cujo caminho completo não tenha espaços
nem dois-pontos, por exemplo `/home/marcel/kernel-work/ubuntu-resolute`. Um
symlink dentro de caminho limpo só deve ser usado depois de confirmar o caminho
físico visto pelo Make; uma worktree/clone dedicado é mais previsível.

O arquivo `debian/control` no empacotamento Ubuntu é gerado durante a
preparação; sua ausência não significa que a fonte esteja corrompida, mas
confirma que nenhum build foi preparado nesta cópia.

## 3\. Regra de portabilidade

### 3.1 O que não fazer

Não devem ser copiados diretamente arquivos como:

- `sched_ule.c`;
- `kern_sendfile.c`;
- `uipc_ktls.c`;
- `kern_jail.c`;
- `vfs_cache.c`;
- arquivos de mutex, sleepqueue, callout, UMA ou `mbuf`.

Esses componentes dependem das APIs internas do FreeBSD: `struct proc`, `thread`
, `vnode`, `mbuf`, UMA, VNET, SYSINIT, epoch e locks próprios. Elas não possuem
compatibilidade binária ou de fonte com Linux.

### 3.2 O que pode ser aproveitado

Podem ser aproveitados:

- hipóteses de desempenho;
- invariantes e políticas;
- formato de benchmarks;
- cenários de falha;
- algoritmos pequenos e independentes, após reimplementação e auditoria de
  licença;
- conceitos de isolamento traduzidos para APIs Linux.

### 3.3 Licenciamento

Todo trecho derivado deve receber análise individual. A auditoria anterior
encontrou licenças BSD-2-Clause, BSD-3-Clause, BSD-4-Clause, Beerware,
expressões combinadas e arquivos sem SPDX explícito. Mesmo quando a licença BSD
é compatível com GPL-2.0, avisos e atribuições devem ser preservados.

A opção preferida para algoritmos pequenos é uma implementação independente
baseada no comportamento documentado e em testes, evitando copiar a estrutura
interna FreeBSD.

## 4\. Arquitetura recomendada para o Parcel Play OS

```text
Ubuntu oficial fixado
        |
        +-- kernel oficial sem patches (fallback obrigatório)
        |
        +-- Parcel generic (produção)
        |     +-- apenas patches aprovados
        |     +-- configuração Ubuntu preservada
        |
        +-- Parcel lab (VM/testes)
              +-- fault injection
              +-- KASAN/KCSAN/KCOV quando necessário
              +-- tracing invasivo
              +-- símbolos e checks adicionais
```
Não se recomenda misturar opções destrutivas de diagnóstico no kernel de
produção. A variante `Parcel lab` deve ter nome de pacote e ABI próprios para
poder coexistir com o kernel Ubuntu oficial.

## 5\. Caso A — Aplicação de boottrace

### 5.1 Recursos já presentes

A árvore local contém:

- `kernel/trace/trace_boot.c`;
- `Documentation/trace/boottime-trace.rst`;
- `Documentation/admin-guide/bootconfig.rst`;
- tracepoints de initcall em `init/main.c`;
- `CONFIG_BOOT_CONFIG=y` na política Ubuntu;
- `CONFIG_FTRACE=y`;
- `CONFIG_DYNAMIC_FTRACE=y` para amd64;
- `CONFIG_TRACEPOINTS=y`;
- `CONFIG_KPROBES=y`;
- `CONFIG_DEBUG_FS=y`.

Logo, não é necessário portar `kern_boottrace.c` para obter a primeira
implementação.

### 5.2 Aplicação proposta

Criar no initramfs um arquivo bootconfig de laboratório com uma instância
dedicada, habilitando somente eventos necessários. Exemplo conceitual:

```text
ftrace.instance.parcel_boot {
    tracing_on = 1
    events.initcall.initcall_start.enable = 1
    events.initcall.initcall_finish.enable = 1
    events.sched.sched_process_exec.enable = 1
}
```
O bootconfig deve ser anexado ao initramfs por ferramenta suportada pelo
kernel, e o parâmetro `bootconfig` deve ser adicionado somente à entrada de
laboratório do GRUB.

### 5.3 Coleta

Coletar três camadas separadamente:

1.  firmware e loader, quando expostos pelo sistema;
2.  kernel, por initcall tracepoints e ftrace;
3.  userspace, por `systemd-analyze` e journal monotônico.

Métricas mínimas:

- tempo até montar root;
- duração de cada initcall;
- tempo até iniciar o display manager;
- tempo até sessão gráfica utilizável;
- p50, p95 e máximo de pelo menos 20 boots;
- variação entre boot frio e quente.

### 5.4 Critério para patch

Somente criar patch no kernel se o trace Linux não conseguir observar uma fase
relevante. Antes disso, preferir:

- novo tracepoint pequeno;
- eBPF/fentry;
- `initcall_debug`;
- instrumentação no initramfs ou systemd.

Não adicionar um segundo framework global de boottrace.

## 6\. Caso B — Fault injection

### 6.1 Estado encontrado

O código está presente em:

- `lib/fault-inject.c`;
- `kernel/fail_function.c`;
- `mm/failslab.c`;
- `mm/fail_page_alloc.c`;
- documentação em `Documentation/fault-injection/`.

A política Ubuntu atual mostra uma combinação importante:

- `CONFIG_FUNCTION_ERROR_INJECTION=y`;
- `CONFIG_FAULT_INJECTION=n`;
- KASAN, KCSAN e KCOV desabilitados no kernel genérico;
- UBSan habilitado em amd64;
- debugfs habilitado.

`FUNCTION_ERROR_INJECTION=y` sozinho não entrega todos os knobs de falha: o
framework geral está desabilitado na configuração de produção.

### 6.2 Aplicação proposta

Criar somente no flavour `parcel-lab` uma alteração de `
debian.master/config/annotations` habilitando, conforme dependências da versão
real:

```text
CONFIG_FAULT_INJECTION=y
CONFIG_FAULT_INJECTION_DEBUG_FS=y
CONFIG_FAILSLAB=y
CONFIG_FAIL_PAGE_ALLOC=y
CONFIG_FAIL_MAKE_REQUEST=y
```
KASAN, KCSAN e KCOV devem ser variantes ou jobs separados, pois aumentam custo,
memória ou latência. Não ativá-los automaticamente no kernel gamer.

### 6.3 Matriz de testes


|Falha          |Alvo                         |Resultado esperado                 |
|---------------|-----------------------------|-----------------------------------|
|slab           |módulo/serviço Parcel isolado|erro tratado, sem oops             |
|page allocation|caminho não crítico          |retorno de erro e recuperação      |
|block request  |disco virtual descartável    |erro de I/O propagado sem corrupção|
|function error |função marcada com allowlist |rollback consistente               |
|network loss   |namespace de rede            |reconnect com limite e backoff     |

Todos os testes devem ocorrer em QEMU com snapshot. Não usar fault injection no
host, no filesystem do desenvolvedor ou na ISO destinada a usuários.

### 6.4 Critério de aprovação

- nenhuma falha silenciosa;
- nenhum panic inesperado;
- nenhum warning novo em dmesg;
- filesystem passa em verificação após desligamento forçado de teste;
- teste repetível com seed registrada;
- configuração de produção permanece sem fault injection geral.

## 7\. Caso C — Scheduler

### 7.1 Limitação da árvore local

A árvore 6.8 local não contém `kernel/sched/ext.c` nem `CONFIG_SCHED_CLASS_EXT`.
Portanto, não há infraestrutura `sched_ext` nesta cópia para experimentar
políticas semelhantes ao ULE sem patch invasivo.

Essa é outra razão para obter um baseline Resolute verdadeiro antes da fase
scheduler.

### 7.2 Resultado já medido

Nos cinco ensaios userspace realizados:

- `SCHED_OTHER`: média das médias de 9,391 µs;
- `SCHED_BATCH`: média das médias de 9,102 µs;
- resultados próximos e com outliers do ambiente desktop;
- nenhuma evidência que justifique substituir o scheduler Linux.

### 7.3 Estratégia correta

Fase 1, sem patch:

- medir EEVDF/CFS do baseline real;
- usar `perf sched`, tracepoints `sched:*` e PSI;
- fixar afinidade, governor, temperatura e processos de fundo;
- medir frame pacing, input latency, compilação, I/O e consumo energético;
- testar `uclamp`, cgroup CPU e prioridades de serviços.

Fase 2, quando a árvore real suportar `sched_ext`:

- implementar uma política experimental eBPF inspirada em objetivos do ULE;
- nunca copiar runqueues ou locks FreeBSD;
- preservar fallback automático ao scheduler padrão;
- executar em VM e depois em máquina dedicada.

Fase 3, patch C somente se `sched_ext` for insuficiente e houver ganho
consistente.

### 7.4 Gate de desempenho

Um experimento scheduler só avança se, em pelo menos 30 repetições:

- reduzir p95/p99 de frame time ou latência do workload-alvo;
- não regredir throughput além do limite definido;
- não aumentar consumo/temperatura de forma desproporcional;
- não provocar starvation;
- passar lockdep, stress-ng, kselftests e ciclos suspend/resume.

## 8\. Caso D — Rede, arquivos, sendfile e kTLS

### 8.1 Recursos já presentes

A árvore contém:

- `do_sendfile()` e as syscalls em `fs/read_write.c`;
- infraestrutura splice;
- `net/tls/tls_main.c`;
- `CONFIG_TLS=m`;
- `CONFIG_TLS_DEVICE=y`;
- BPF, BPF syscall e tracepoints habilitados;
- selftests de rede.

Não é necessário portar `kern_sendfile.c` ou `uipc_ktls.c` para oferecer essas
funções.

### 8.2 Resultado já medido

Em `socketpair` local e arquivo temporário de 64 MiB:

- `read/write`: média 2.225,51 MiB/s;
- `sendfile`: média 4.922,52 MiB/s;
- razão observada: 2,212×.

Esse resultado prova somente que o caminho local testado merece ser mantido no
conjunto de benchmarks. Ele não prova ganho em NIC física, kTLS, FreeBSD,
DirectStorage ou workload de jogo.

### 8.3 Aplicação userspace imediata

Para servidores ou serviços Parcel que transfiram arquivos para sockets:

- preferir `sendfile(2)` quando origem/destino forem compatíveis;
- manter fallback robusto para `copy_file_range`, splice ou `read/write`;
- tratar short writes, `EINTR`, `EAGAIN` e limites de tamanho;
- medir antes de tornar a escolha automática;
- não chamar isso de DirectStorage.

### 8.4 Plano kTLS

1.  carregar o módulo `tls` apenas no ambiente de teste;
2.  executar selftests TLS da árvore correspondente;
3.  validar TLS TX e RX separadamente;
4.  comparar userspace TLS, kTLS software e offload de NIC quando disponível;
5.  registrar CPU/byte, throughput, latência, retransmissões e consumo;
6.  testar com arquivos reais, múltiplas conexões e pressão de memória.

Qualquer patch deve se concentrar em tracepoints ou correções demonstráveis.
Não duplicar a pilha TLS FreeBSD.

### 8.5 VFS e namecache

O estudo de `vfs_cache.c` deve ser traduzido para hipóteses sobre dcache, inode
cache, RCU-walk e pathname lookup do Linux. Instrumentar com tracepoints, perf
e BPF. Alterar `fs/namei.c` ou dcache somente depois de reproduzir uma regressão
e provar sua causa.

## 9\. Caso E — Algoritmos isolados

### 9.1 Estado do protótipo

A suíte userspace implementou de forma independente:

- controle PID;
- min/max;
- regressão incremental.

Os testes passaram com compilação estrita e ASan/UBSan, com leak detection
desativada devido à supervisão do ambiente.

### 9.2 Caminho para o kernel

Antes de colocar qualquer algoritmo na árvore Linux:

1.  definir um consumidor real;
2.  especificar unidades, limites e overflow;
3.  remover ponto flutuante — código kernel não pode depender de FPU comum;
4.  usar tipos fixos e helpers Linux;
5.  criar testes KUnit com vetores determinísticos;
6.  executar análise estática e sanitizers;
7.  comparar com helpers já existentes em `include/linux` e `lib/`;
8.  provar que a inclusão reduz duplicação ou melhora resultado real.

### 9.3 Destinos possíveis

- se o algoritmo serve somente ao daemon de tuning: permanecer em userspace;
- se serve a um único driver: ficar local ao driver;
- se possui múltiplos consumidores comprovados: considerar helper em `lib/`;
- se é apenas experimento: permanecer em `studies/`.

O PID é mais provável de permanecer em userspace. Min/max já existem amplamente
no kernel. Regressão incremental só deve entrar se um consumidor kernel não
puder delegar a decisão ao userspace.

## 10\. Jails, Capsicum e VNET como modelo de segurança

Esses conceitos devem orientar o threat model, não ser portados literalmente.


|Conceito FreeBSD   |Composição Ubuntu/Linux                        |
|-------------------|-----------------------------------------------|
|Jail               |user, mount, PID, IPC, UTS e network namespaces|
|VNET               |network namespace, veth, bridge/nftables       |
|limites de recursos|cgroup v2                                      |
|Capsicum           |seccomp + Landlock + capabilities + AppArmor   |
|filesystem restrito|mount namespace, idmapped mounts, Landlock     |
|auditoria          |audit, journald, IMA quando aplicável          |

A aplicação pertence inicialmente a systemd, OCI/Podman e políticas de
segurança do root filesystem, sem patch de kernel.

## 11\. Pontos de integração na árvore Ubuntu

### 11.1 Fonte Linux

Alterações funcionais, caso aprovadas, devem tocar o menor subsistema possível:

- tracing: `kernel/trace/` e `include/trace/events/`;
- scheduler: somente via `sched_ext` primeiro; patch em `kernel/sched/` é último
  recurso;
- fault injection: preferir configuração, não código;
- rede TLS: `net/tls/` somente para correção comprovada;
- VFS: não alterar até existir perfil reproduzível;
- algoritmos: KUnit junto ao consumidor ou helper justificado.

### 11.2 Configuração Ubuntu

As políticas ficam em `debian.master/config/annotations`. Não editar apenas uma `
.config` gerada, pois ela não é a fonte de verdade do pacote Ubuntu.

Toda mudança deve especificar por arquitetura e flavour:

- `generic`: opções seguras para produção;
- `parcel-lab`: diagnóstico e fault injection;
- outras arquiteturas: manter `n` ou política explícita até serem testadas.

### 11.3 Empacotamento

O pacote deve:

- usar nome e ABI Parcel distintos;
- coexistir com `linux-generic` oficial;
- instalar imagem, módulos, headers e debug symbols coerentes;
- preservar hooks de initramfs e Secure Boot;
- nunca remover automaticamente o último kernel oficial funcional.

### 11.4 Patches

Manter uma série linear pequena, por exemplo:

```text
0001-parcel-config-lab-flavour.patch
0002-parcel-tracepoint-missing-phase.patch
0003-parcel-kunit-algorithm.patch
```
Cada commit deve conter:

- problema mensurável;
- baseline e hardware;
- resultado antes/depois;
- riscos;
- testes executados;
- origem/licença;
- instrução de reversão.

## 12\. Pipeline de obtenção, build e teste

### Marco 0 — Corrigir a identidade

Em uma operação deliberada com rede:

```bash
git fetch --unshallow origin
git fetch origin --tags
git log -1 --format='%H %ad %s' origin/master
```
Antes de substituir a árvore atual, criar nova worktree ou clone e comparar o
changelog. Não fazer merge cego de 2024 para o estado atual.

O destino do novo clone/worktree precisa ter caminho integral sem espaços ou
dois-pontos. A árvore atual pode continuar como fonte de auditoria, mas não é
um diretório de build Linux válido.

### Marco 1 — Baseline sem patches

1.  fixar commit oficial;
2.  gerar arquivos do empacotamento conforme as regras da versão;
3.  verificar dependências;
4.  construir `amd64/generic` sem mudanças;
5.  instalar somente em VM;
6.  executar boot, kselftests e benchmarks A–E;
7.  guardar pacotes, config, logs e hashes.

O comando exato de build deve vir do `debian/rules` da revisão finalmente
fixada. Para a família Ubuntu kernel, os alvos normalmente passam por
limpeza/preparação e binários do flavour, mas não se deve congelar comandos da
árvore Noble como procedimento Resolute antes da atualização.

### Marco 2 — Instrumentação sem patch

- bootconfig/ftrace;
- perf e BPF;
- selftests de rede/scheduler/Landlock;
- cgroup v2 e namespaces;
- benchmarks repetidos da suíte;
- logs de kernel e systemd.

### Marco 3 — Kernel Parcel Lab

- criar flavour separado;
- habilitar fault injection;
- opcionalmente criar builds separados com KASAN/KCSAN/KCOV;
- testar somente em snapshot QEMU;
- confirmar que o kernel generic não herdou essas opções.

### Marco 4 — Primeiro patch funcional

Escolher apenas uma lacuna comprovada. A melhor primeira contribuição não é
scheduler ou VFS; deve ser um tracepoint, teste KUnit ou correção pequena com
risco baixo.

### Marco 5 — Produção

Promover somente após:

- build reproduzível em ambiente limpo;
- boot UEFI e BIOS quando suportados;
- Secure Boot e assinatura verificados;
- instalação/remoção do pacote testadas;
- suspend/resume, áudio, GPU, rede e storage testados;
- regressão de jogos e desktop dentro dos limites;
- kernel Ubuntu oficial selecionável no GRUB.

## 13\. Matriz de validação


|Camada      |Testes obrigatórios                                         |
|------------|------------------------------------------------------------|
|Fonte       |`git diff --check`, checkpatch, sparse/Smatch quando aplicável|
|Unidade     |KUnit e suíte userspace                                     |
|Kernel      |kselftest por subsistema, LKDTM somente em VM               |
|Concorrência|lockdep, KCSAN em build dedicado                            |
|Memória     |KASAN/UBSan em build dedicado                               |
|Boot        |20+ ciclos, panic timeout, serial console, rollback         |
|Scheduler   |perf sched, frame-time p95/p99, PSI, energia                |
|Rede        |net selftests, iperf3, packet loss, kTLS TX/RX              |
|I/O         |fio, sendfile, splice, page cache frio/quente               |
|Segurança   |namespaces, seccomp, Landlock, AppArmor, lockdown           |
|Desktop     |GNOME/KDE, Gamescope opcional, GPU AMD/Intel/NVIDIA         |
|Pacote      |instalar, atualizar, remover e recuperar pelo fallback      |

## 14\. Critérios de interrupção e reversão

Rejeitar ou reverter a mudança se ocorrer:

- panic, oops, lockup ou corrupção;
- regressão estatisticamente relevante sem benefício maior;
- aumento de superfície de ataque sem mitigação;
- dependência de `mitigations=off`;
- necessidade de desabilitar Secure Boot para uso comum;
- patch que duplica funcionalidade Linux existente;
- código FreeBSD sem licença comprovada;
- impossibilidade de manter kernel Ubuntu oficial como fallback;
- resultado que só aparece em uma execução ou sem controle de ambiente.

## 15\. Ordem recomendada de aplicação

1.  obter e fixar o Resolute verdadeiro;
2.  construir e inicializar o Ubuntu baseline sem patches;
3.  integrar boottrace por bootconfig/ftrace;
4.  executar scheduler e I/O com controle experimental;
5.  criar flavour `parcel-lab` para fault injection;
6.  aplicar isolamento estilo Jail em userspace;
7.  avaliar kTLS com selftests e NIC real;
8.  converter somente algoritmos com consumidor real para KUnit/kernel;
9.  experimentar scheduler via `sched_ext` se disponível;
10. considerar patches internos apenas após evidência.

## 16\. Alterações efetivamente realizadas nesta etapa

### Análise executada

- identidade Git, branch, commit, remote e shallow clone;
- versão do `Makefile` e changelog Ubuntu;
- presença de configuração, build e ferramentas;
- teste de entrada do Kbuild, que confirmou a rejeição do caminho com espaços;
- políticas relevantes em `debian.master/config/annotations`;
- presença dos subsistemas de tracing, fault injection, sendfile, TLS, BPF e
  segurança;
- disponibilidade de selftests e documentação local;
- correspondência dos cinco estudos com a árvore Ubuntu.

### Implementação real

- somente este relatório e o registro em `PROGRESSO.md`;
- nenhum arquivo dentro de `Kernels/ubuntu 26 resolute kernel/` foi modificado;
- nenhum kernel foi compilado, instalado ou inicializado;
- a tentativa não compilatória de consultar `kernelversion` foi interrompida
  pelo Kbuild antes de gerar artefatos;
- nenhuma configuração do host foi alterada;
- nenhum teste destrutivo foi executado.

## 17\. Conclusão

O Ubuntu oferece equivalentes maduros para a maior parte das ideias úteis do 
`sys/kern` FreeBSD. A direção correta é explorar esses equivalentes e usar o
FreeBSD como referência de desenho e comparação. O principal bloqueio imediato
não é técnico no kernel: é a identidade incorreta/desatualizada da árvore
chamada Resolute.

Depois de corrigir o baseline, boottrace, sendfile, kTLS, isolamento e
observabilidade podem começar sem patches. Fault injection deve ficar em
flavour de laboratório. Scheduler ULE deve ser estudado por métricas e, se a
versão real oferecer `sched_ext`, por política experimental reversível.
Algoritmos pequenos só devem entrar no kernel quando tiverem consumidor, testes
KUnit e ganho comprovado.

Essa sequência mantém o projeto na direção de um sistema operacional
sustentável: base Ubuntu rastreável, patches mínimos, pacote reversível, kernel
oficial de fallback e evidência antes de integração.

