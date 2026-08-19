# FreeBSD 15.1: identidade e capacidades

ID: `KB-FBSD-IDENTITY`

- tipo: `fact`
- confiança: `high`
- estado: `current`
- verificado em: `2026-08-19`
- fontes: `SRC-FBSD-SOURCE`, `SRC-FBSD-INVENTORY`

## Baseline

A fonte completa usada pelo projeto é FreeBSD 15.1-RELEASE-p2. O inventário do
projeto registra a tag `release/15.1.0-p2` e o commit
`aadd58dddcbc78f4d5594827b46b5633552b15ce`. A árvore externa completa é a fonte
primária; a cópia `Kernels/FreeBSD 15` é parcial e não deve substituí-la.

## Capacidades confirmadas por presença no código

- schedulers ULE e 4BSD, SMP e NUMA;
- Jails/VIMAGE e controles RACCT/RCTL;
- Capsicum, MAC Framework, auditoria e credenciais BSD;
- epoch/SMR, UMA, mutexes adaptativos e primitives SMP;
- sendfile, kTLS, sockets, TCP/IP, IPsec, PF, IPFW e Netgraph;
- OpenZFS, UFS/FFS, GEOM, CAM, NVMe, AHCI, iSCSI e NFS;
- bhyve/vmm, VirtIO, Xen, Hyper-V e Linuxulator;
- loader, release tooling, bsdinstall e infraestrutura de testes.

Presença no código não significa que tudo foi executado no hardware local. O
inventário separa “confirmado estruturalmente” de “confirmado por execução”.

## Dimensão registrada

O inventário anterior contou aproximadamente 2,2 GiB, 108.960 arquivos totais,
33.186 em `sys/`, 470 diretórios de módulos e 2.386 arquivos de testes. Esses
números pertencem à medição registrada; devem ser refeitos após atualização da
fonte.

## Uso correto pela IA

Responder sobre mecanismos existentes pode usar esta entrada. Responder sobre
desempenho, suporte a um hardware específico ou prontidão do PlayOS exige teste
ou fonte adicional. Não inferir compatibilidade apenas pela presença do driver.
