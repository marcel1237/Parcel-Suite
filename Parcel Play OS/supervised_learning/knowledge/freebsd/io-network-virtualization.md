# FreeBSD: I/O, rede, armazenamento e virtualização

ID: `KB-FBSD-IO`

- tipo: `fact`
- confiança: `high`
- estado: `current`
- verificado em: `2026-08-19`
- fontes: `SRC-FBSD-INVENTORY`, `SRC-FBSD-STUDIES`, `SRC-FBSD-SOURCE`

## Rede e I/O

FreeBSD contém sendfile, kTLS, TCP/IP, IPv6, IPsec, SCTP, BPF, Netgraph, PF e
IPFW. O projeto já executou estudos de rede/arquivos e concluiu que a comparação
correta é por comportamento e benchmark, não por transplantar `mbuf`, socket ou
VNET ao Linux.

AF_XDP, io_uring e kTLS Linux são mecanismos Linux próprios. Podem cumprir metas
semelhantes, mas não são portes das implementações FreeBSD.

## Armazenamento

FreeBSD integra OpenZFS, UFS/FFS, GEOM, CAM, NVMe, AHCI, iSCSI e NFS. ARC/dbuf
possuem controles próprios de cache; page cache/memcg Linux têm outra semântica.
Qualquer política de “manter ativos de jogos quentes” precisa de pressão de
memória, limites, fairness e benchmark antes de implementação no kernel.

## Virtualização e compatibilidade

Foram localizados bhyve/vmm, VirtIO, suporte Xen/Hyper-V e Linuxulator. Para
compatibilidade máxima, o projeto propõe roteamento em camadas: pacote FreeBSD
nativo, Linuxulator em jail quando compatível, Wine, VM bhyve e streaming como
último fallback. Linuxulator compartilha o kernel FreeBSD e não executa recursos
que dependam de um kernel Linux real.

## Estado experimental

A presença desses subsistemas foi inventariada, mas GPU, áudio, suspend/resume,
passthrough e aplicações reais ainda exigem boot e teste. Não prometer
compatibilidade universal.
