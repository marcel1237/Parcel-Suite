# Roadmap de conhecimento BSD

## Prioridade 10 — FreeBSD executável e reproduzível

- construir baseline FreeBSD 15.1-p2 sem patches;
- inicializar em QEMU/KVM;
- registrar loader, kernel, rootfs, rede e console;
- executar ATF/Kyua selecionado;
- validar Jails, VNET, RCTL, Capsicum, PF, ZFS e bhyve;
- preservar comandos, logs, hashes e configuração.

## Prioridade 9 — Dossiês de `sys/kern`

Criar entradas por família com símbolos, linhas, dependências, invariantes,
locks, testes upstream, equivalente Linux e decisão PlayOS. Ordem:

1. boot/SYSINIT;
2. Jails/prison/VNET;
3. scheduler/locks/SMP;
4. sendfile/kTLS/sockets;
5. RACCT/RCTL;
6. VFS;
7. tracing/failpoints;
8. Newbus/devices.

## Prioridade 8 — Comparação experimental

- boottrace FreeBSD versus Linux;
- sendfile e kTLS;
- scheduler sob carga interativa;
- pressão de memória/ARC/page cache;
- isolamento e custo de containers/Jails;
- filesystem e armazenamento;
- tracing e diagnóstico.

Cada benchmark precisa de hardware, versões, configuração, aquecimento,
repetições, dispersão, logs e hipótese refutável.

## Prioridade 7 — Família BSD

- adicionar fontes completas OpenBSD e NetBSD;
- verificar versões/commits;
- estudar PF, pledge/unveil, mitigations, rump kernels e portabilidade;
- comparar sem transformar slogans de projeto em resultados medidos.

## Prioridade 6 — Dataset

- expandir de 44 para 250 exemplos;
- manter splits sem paráfrases duplicadas;
- incluir perguntas por símbolo, arquitetura, licença e falhas;
- criar respostas negativas com recusa correta;
- adicionar avaliação semântica e citação obrigatória.

## Gate de conclusão

A base BSD atinge maturidade operacional quando uma IA consegue responder pelo
menos 90% do conjunto de validação com fonte correta, estado correto e nenhuma
invenção, além de produzir um plano de experimento reproduzível para o restante.
