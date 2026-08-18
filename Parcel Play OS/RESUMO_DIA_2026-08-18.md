# Resumo do trabalho realizado em 18 de agosto de 2026

## Visão geral

O trabalho de hoje transformou a pesquisa FreeBSD/Linux do Parcel Play OS em
uma base técnica rastreável. Foram auditadas árvores de kernel, executados cinco
estudos, produzidos relatórios de portabilidade e criados três kits de patches
reversíveis:

1. FreeBSD 15 → Ubuntu Resolute;
2. FreeBSD 15 → Linux vanilla 7.1.8;
3. Linux 7.1.8 → FreeBSD 15.1-p2.

Nenhum kernel foi substituído, instalado ou inicializado. Os patches foram
mantidos fora das árvores-alvo e validados estaticamente e, quando possível, em
cópias temporárias.

## Ranking de importância

A nota mede importância estratégica para o projeto, não porcentagem de
conclusão.

| Rank | Entrega | Importância | Maturidade atual |
|---:|---|---:|---|
| 1 | Confirmação de que Resolute oficial é Linux 7.0 e a cópia local é Noble 6.8 | 10/10 | confirmado |
| 2 | Política de portabilidade sem cópia direta FreeBSD/Linux | 10/10 | adotada e documentada |
| 3 | Patchset FreeBSD → Ubuntu Resolute | 10/10 | série inicial validada, aplicação final pendente |
| 4 | Auditoria completa do FreeBSD 15.1-p2 | 9/10 | inventário estático concluído |
| 5 | Patchset Linux 7.1.8 → FreeBSD 15.1-p2 | 9/10 | série inicial validada, build FreeBSD pendente |
| 6 | Patchset FreeBSD → Linux vanilla 7.1.8 | 9/10 | série inicial validada, build/boot pendentes |
| 7 | Cinco estudos FreeBSD `sys/kern` | 9/10 | executados dentro dos limites do host |
| 8 | Identificação de `sched_ext` e NTSYNC no Linux 7.1.8 | 9/10 | código confirmado |
| 9 | Arquitetura `generic` + `lab` + fallback oficial | 9/10 | proposta consolidada |
| 10 | Inventário das alterações e auditoria de direção do projeto | 8/10 | análise concluída |
| 11 | Correção conceitual da estratégia de Live CD/instalador | 8/10 | decisão documentada |
| 12 | Correção dos links e transparência de kernels | 7/10 | documentação atualizada |
| 13 | Comparação OpenBSD/FreeBSD e recomendação de base | 7/10 | análise estratégica |
| 14 | Registro central em `PROGRESSO.md` | 7/10 | atualizado continuamente |

## 1. Nova auditoria geral do projeto — 8/10

O projeto foi revisto após várias alterações. Foram inventariados documentos,
scripts, protótipos NitroCore, módulos do instalador, fontes importadas e
dependências.

Principais conclusões:

- a visão Ubuntu + desktop + gaming continua válida;
- o escopo estava se expandindo demais para kernel próprio, múltiplos BSDs,
  navegadores, storage P2P e muitos gestores de pacotes;
- NitroCore ainda é um protótipo não integrado ao build principal;
- vários scripts simulam sucesso sem produzir o artefato declarado;
- recursos planejados não devem ser descritos como implementados;
- a prioridade deve ser uma ISO Ubuntu reproduzível com instalador funcional.

Documentos relacionados:

- `ANALISE_ALTERACOES_2026-08-18.md`;
- `AUDITORIA_COMPLETA_DIRECAO_2026-08-18.md`.

## 2. Auditoria do FreeBSD 15 `sys/kern` para Ubuntu — 10/10

Foram classificados os 248 arquivos do recorte inicial `FreeBSD 15/sys/kern`.
A análise cobriu scheduler, processos, locks, memória, VFS, rede, IPC, Jails,
Capsicum, tracing, DMA e algoritmos auxiliares.

Conclusão decisiva:

- nenhum arquivo completo deve ser copiado diretamente para Linux;
- as APIs internas FreeBSD são incompatíveis com Linux;
- o FreeBSD deve fornecer hipóteses, políticas, benchmarks e casos de teste;
- implementações devem usar RCU, lockdep, cgroups, namespaces, Landlock,
  seccomp, Maple Tree, kTLS e outras APIs Linux existentes;
- qualquer algoritmo pequeno exige implementação independente e auditoria de
  licença.

Documento: `PORTABILIDADE_FREEBSD15_SYS_KERN_PARA_UBUNTU.md`.

## 3. Execução dos cinco casos de estudo — 9/10

Foi criada a suíte reproduzível `studies/freebsd15_sys_kern/`.

### A — Boottrace

- coletor implementado e executado;
- tracefs e systemd bus estavam limitados pelo sandbox;
- nenhum tempo completo de boot foi confirmado.

### B — Fault injection

- configuração do host auditada;
- UBSan e function error injection detectados;
- injeção real corretamente bloqueada fora de VM descartável.

### C — Scheduler

- cinco repetições compararam `SCHED_OTHER` e `SCHED_BATCH`;
- resultados ficaram próximos;
- não surgiu evidência para substituir o scheduler Linux pelo ULE.

### D — Rede e arquivos

- `read/write`: média de 2.225,51 MiB/s;
- `sendfile`: média de 4.922,52 MiB/s;
- razão observada: 2,212×;
- resultado limitado a socketpair local e page cache.

### E — Algoritmos isolados

- PID, min/max e regressão incremental implementados em userspace;
- testes normais passaram;
- ASan/UBSan passaram com leak detection desativada pelo ambiente supervisionado.

Documento: `RESULTADOS_ESTUDOS_FREEBSD15_SYS_KERN_2026-08-18.md`.

## 4. Análise de aplicação no Ubuntu Resolute — 10/10

Foi confrontada a pesquisa FreeBSD com a árvore localizada em
`Kernels/ubuntu 26 resolute kernel/`.

Descobertas críticas:

- remote aponta para o repositório Resolute;
- conteúdo local está no commit raso `74134bfb6b720ca18a73931662cbcc8170ef1bed`;
- `Makefile` declara Linux 6.8.4;
- changelog declara Noble 6.8.0-30.30 de abril de 2024;
- a árvore não pode ser tratada como Resolute atual;
- fontes oficiais confirmam que o Resolute final usa Linux 7.0;
- Kbuild rejeita o caminho atual porque contém espaços;
- `.config`, `debian/build` e `debian/control` gerado estão ausentes.

Também foram mapeados bootconfig/ftrace, fault injection, scheduler, sendfile,
kTLS, Jails/Capsicum e pontos de integração no empacotamento Ubuntu.

Documento: `APLICACAO_FREEBSD15_NO_UBUNTU_RESOLUTE_2026-08-18.md`.

## 5. Patchset FreeBSD → Ubuntu Resolute — 10/10

Foi criado `patch-FreeBSD-Ubuntu/` com:

- manifesto e série;
- patch de documentação;
- patch de boottrace opt-in;
- patch de selftests de sendfile/capacidades;
- fragmento `parcel-lab.config` fora da série automática;
- scripts de identificação, validação, aplicação e reversão;
- bloqueios contra árvore suja, clone raso, caminho inválido e changelog não
  Resolute;
- hashes SHA-256 e relatório de validação.

Validações:

- três patches passaram em `git apply --check --whitespace=error-all`;
- aplicação em cópia temporária passou;
- selftest sendfile compilou e passou;
- parser bootconfig passou;
- 55 testes oficiais bootconfig passaram.

A aplicação final continua pendente até existir um Resolute verdadeiro em
caminho sem espaços.

## 6. Patchset FreeBSD → Linux vanilla 7.1.8 — 9/10

Foi criado `patch-FreeBSD-Kernel-7.1.8/`.

A árvore 7.1.8 contém recursos ausentes na árvore Ubuntu 6.8 auditada:

- `sched_ext`;
- selftests `sched_ext`;
- NTSYNC oficial;
- bootconfig;
- fault injection;
- kTLS;
- Landlock;
- BPF e sanitizers modernos.

Decisões:

- estudar ULE por política eBPF `sched_ext`;
- não portar runqueues e locks FreeBSD;
- não reimplementar NTSYNC;
- manter fault injection e sanitizers em configuração lab;
- manter algoritmos em userspace até existir consumidor kernel.

Validações:

- três patches passaram em checagem estrita;
- aplicação temporária passou;
- selftest sendfile passou;
- bootconfig: 75 testes passaram;
- perfil Parcel foi analisado corretamente.

A fonte local 7.1.8 não possui Git próprio, `.config`, tag ou origem verificável
e está em caminho com espaços.

## 7. Localização e auditoria do FreeBSD completo — 9/10

Foi analisada a árvore:

`/home/marcel/Parcel Suite/Operating Systems/freebsd-15.1.0-p2`

Ela é uma árvore completa e verificável:

- aproximadamente 2,2 GiB;
- aproximadamente 108.960 arquivos;
- aproximadamente 33.186 arquivos em `sys/`;
- aproximadamente 470 grupos de módulos;
- aproximadamente 2.386 arquivos de testes;
- código do kernel, userland, loader, bsdinstall e release.

Foram confirmados:

- ULE/4BSD;
- Jails/VNET;
- Capsicum;
- RACCT/RCTL;
- MAC Framework;
- epoch/SMR;
- sendfile/kTLS;
- OpenZFS;
- PF/IPFW;
- bhyve;
- Linuxulator/LinuxKPI;
- DTrace/HWPMC/TSLOG/boottrace;
- failpoints;
- KASAN/KCSAN/KMSAN/KCOV;
- geração de ISO, memstick e imagens cloud.

Documento: `patch-linux7.1.8-FreeBSD/INVENTARIO_FREEBSD_15.1_P2.md`.

## 8. Patchset invertido Linux 7.1.8 → FreeBSD — 9/10

Foi criado `patch-linux7.1.8-FreeBSD/`.

A série contém:

1. manual BSD-2-Clause de adoção segura de conceitos Linux;
2. configuração amd64 `PARCEL-LAB`;
3. testes ATF de baseline.

O `PARCEL-LAB` herda GENERIC-DEBUG e acrescenta:

- TSLOG;
- TSLOGSIZE;
- COVERAGE;
- KCOV;
- WITNESS e INVARIANTS herdados.

O patchset não copia código GPL. Foram documentadas como pesquisas futuras:

- PSI nativo;
- NTSYNC clean-room;
- scheduler experimental com fallback;
- io_uring versus kqueue/AIO;
- tracing SDT/DTrace;
- integridade com MAC/veriexec.

Validações:

- identidade/tag/commit FreeBSD confirmados;
- patches passaram em checagem estrita;
- aplicação temporária passou;
- teste ATF passou em sintaxe;
- hashes confirmados;
- árvore FreeBSD externa permaneceu limpa.

Buildworld, buildkernel, Kyua, ATF e boot ainda exigem host/VM FreeBSD.

## 9. Live CD, bsdinstall e instaladores — 8/10

Foi confirmado que a árvore completa FreeBSD possui:

- código real do bsdinstall;
- particionamento, EFI e ZFS boot;
- rede IPv4/IPv6 e Wi-Fi;
- hardening e serviços;
- instalação roteirizada;
- criação de ISO e memstick;
- imagens Azure, EC2, GCE, OCI, OpenStack, Vagrant e Firecracker.

Direção recomendada:

- FreeBSD: usar e estender bsdinstall/release;
- Ubuntu: usar Subiquity/Ubuntu Desktop Installer;
- Calamares: possível como integração externa, mas exige backend FreeBSD real;
- Anaconda: não recomendado para o MVP FreeBSD/Ubuntu do projeto.

## 10. Transparência dos kernels — 7/10

O documento `TRANSPARENCIA_KERNEL.md` foi reorganizado com:

- links diretos;
- URLs clonáveis;
- branches/tags;
- distinção entre árvore, empacotamento e patchset;
- origem Ubuntu/FreeBSD/OpenBSD/NetBSD;
- exigência de commit completo e data de auditoria.

## 11. Arquitetura final recomendada — 9/10

```text
kernel oficial de fallback
        |
        +-- Parcel generic
        |     somente patches aprovados e medidos
        |
        +-- Parcel lab
              tracing invasivo
              fault injection
              coverage/sanitizers por variante
              execução somente em VM inicialmente
```

Princípios consolidados:

- baseline oficial fixado;
- caminho de build sem espaços;
- um commit por patch;
- série pequena e reversível;
- nenhum patch sem teste;
- nenhuma alegação além da evidência;
- kernel oficial sempre disponível;
- licença auditada por arquivo/trecho;
- FreeBSD e Linux tratados como arquiteturas diferentes.

## 12. Estado ao final do dia

### Concluído

- auditorias estáticas;
- inventários;
- matriz de portabilidade;
- cinco estudos locais;
- três patchsets estruturados;
- scripts de validação/aplicação/reversão;
- patches iniciais;
- testes temporários;
- documentação e hashes.

### Parcial

- boottrace completo;
- fault injection real;
- benchmarks de rede física/kTLS;
- comparação scheduler controlada;
- Live ISO personalizada;
- integração do instalador.

### Pendente

- obter Ubuntu Resolute verdadeiro;
- obter Linux 7.1.8 oficial com Git/tag;
- mover worktrees de build para caminhos sem espaços;
- disponibilizar QEMU/KVM e VMs;
- build e boot dos kernels;
- buildworld/buildkernel FreeBSD;
- execução Kyua/ATF;
- Secure Boot e assinatura;
- empacotamento e instalação;
- benchmarks em hardware.

## Conclusão

O avanço mais importante do dia foi trocar uma estratégia de “misturar
kernels” por uma engenharia baseada em tradução conceitual, patches mínimos,
licença, testes e rollback. A pesquisa agora possui três caminhos independentes
e verificáveis, mas ainda não existe kernel Parcel compilado ou validado em
boot. O próximo marco deve ser infraestrutura: fontes oficiais em caminhos
válidos, VM, baseline sem patches e somente depois aplicação das séries.
