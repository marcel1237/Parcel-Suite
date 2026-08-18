# Inventário completo do FreeBSD 15.1-RELEASE-p2 presente no projeto

**Data da análise:** 18 de agosto de 2026  
**Fonte:** `/home/marcel/Parcel Suite/Operating Systems/freebsd-15.1.0-p2`  
**Escopo:** árvore completa do sistema base, kernel, userland, boot, instalador,
release, ferramentas e testes.  
**Natureza:** análise estática. Presença no código não significa que o recurso
foi compilado, inicializado ou validado neste host.

## 1. Identidade e integridade da fonte

| Campo | Valor confirmado |
|---|---|
| Sistema | FreeBSD |
| Versão | 15.1-RELEASE-p2 |
| Tag | `release/15.1.0-p2` |
| Commit | `aadd58dddcbc78f4d5594827b46b5633552b15ce` |
| Remote | `https://git.FreeBSD.org/src.git` |
| Estado Git | limpo, detached HEAD |
| Clone | raso |
| Tamanho | aproximadamente 2,2 GiB |
| Arquivos totais | aproximadamente 108.960 |
| Arquivos em `sys/` | aproximadamente 33.186 |
| Arquivos de testes | aproximadamente 2.386 |

A tag e o commit são verificáveis localmente. O clone raso é suficiente para
inspecionar a revisão, mas não para análises históricas extensas ou rebase.

## 2. O que a árvore representa

Esta fonte contém o sistema base completo, não apenas o kernel:

- kernel e módulos em `sys/`;
- bibliotecas em `lib/`;
- comandos essenciais em `bin/` e `sbin/`;
- ferramentas administrativas em `usr.sbin/`;
- aplicações base em `usr.bin/`;
- loader e boot em `stand/`;
- instalador em `usr.sbin/bsdinstall/`;
- geração de releases, ISO e imagens em `release/`;
- código de terceiros importado em `contrib/`;
- testes ATF, Kyua, Python, KTest e regressão em `tests/`, `sys/tests/` e
  diretórios específicos.

Contagens aproximadas do userland:

| Diretório | Arquivos | Componentes diretos |
|---|---:|---:|
| `bin/` | 1.146 | 42 |
| `sbin/` | 1.280 | 84 |
| `usr.bin/` | 3.310 | 274 |
| `usr.sbin/` | 2.838 | 229 |
| `lib/` | 5.619 | 154 |
| `libexec/` | 572 | 35 |

## 3. Arquiteturas

Foram localizadas implementações de arquitetura para:

- amd64/x86;
- i386;
- arm;
- arm64;
- RISC-V;
- PowerPC.

Há seis descrições `syscalls.master` para ABIs/arquiteturas distintas. A árvore
contém aproximadamente 177 arquivos sob diretórios de configuração de kernel e
cerca de 470 diretórios de módulos no primeiro nível de `sys/modules`.

O foco mais completo para desktop/servidor do projeto é amd64. ARM64, RISC-V e
PowerPC possuem suporte relevante, mas não foram construídos nesta auditoria.

## 4. Kernel GENERIC amd64

O `GENERIC` amd64 contém, entre outros:

### Processamento e scheduler

- ULE;
- scheduler 4BSD;
- seleção do scheduler em boot;
- SMP;
- NUMA;
- preempção de threads do kernel;
- afinidade e políticas POSIX de prioridade;
- cpufreq;
- ACPI e SMBIOS.

O scheduler selecionado por padrão é ULE. A árvore expõe sysctls ULE para
quantum, balanceamento, afinidade, steal e preempção. Isso é tunabilidade, não
uma interface equivalente ao `sched_ext` Linux.

### Isolamento e recursos

- VIMAGE/VNET;
- Jails e descritores de Jail;
- RACCT;
- RCTL;
- Capsicum capability mode;
- Capsicum capabilities;
- TrustedBSD MAC Framework;
- auditoria de segurança.

No GENERIC, RACCT está compilado com `RACCT_DEFAULT_TO_DISABLED`; sua presença
não significa contabilização ativa sem configuração.

### Rede

- IPv4 e IPv6;
- multipath routing;
- FIB modular;
- netlink e route netlink;
- IPsec e infraestrutura de offload;
- TCP offload;
- TCP blackbox/event logging;
- TCP Fast Open;
- SCTP carregável;
- kTLS TX/RX e offload;
- BPF clássico;
- VLAN, bridges, tunnels e interfaces virtuais;
- PF;
- IPFW;
- IPFilter;
- ALTQ;
- Netgraph;
- netmap;
- Wi-Fi `net80211`;
- Bluetooth via Netgraph;
- NFS cliente e servidor;
- SMB de kernel legado em `netsmb`.

### Armazenamento e filesystems

- UFS/FFS;
- Soft Updates;
- ACL e quotas UFS;
- gjournal;
- OpenZFS integrado;
- ZFS no loader;
- GEOM e suas classes de RAID, label, mirror e criptografia;
- NVMe/NVD e CAM NVMe;
- AHCI, ATA e SCSI/CAM;
- iSCSI cliente e target userspace;
- NFS;
- tmpfs;
- CD9660;
- msdosfs;
- ext2fs;
- FUSE;
- p9fs;
- autofs;
- nullfs, unionfs e fdescfs;
- procfs;
- tarfs;
- UDF;
- SMBFS.

OpenZFS possui aproximadamente 2.355 arquivos de testes importados. Os comandos
ZFS estão sob `cddl/sbin/zfs` e `cddl/sbin/zpool`.

### Hardware e drivers

O GENERIC amd64 contém ampla cobertura de:

- PCI/PCIe, hotplug, SR-IOV e IOMMU;
- NVMe, SATA/AHCI, SAS, SCSI e RAID;
- Intel, AMD, Broadcom, Mellanox, Realtek e outros adaptadores de rede;
- virtio e drivers para hypervisors;
- USB 2/3, HID, armazenamento USB e entrada;
- áudio HDA e vários dispositivos de som legados;
- framebuffer EFI/VESA e console `vt`;
- UART e consoles seriais;
- RNG por hardware;
- OpenCrypto e AES-NI.

A árvore contém DRM2 legado e LinuxKPI. Drivers gráficos modernos externos ou
ports, como `drm-kmod`, não devem ser inferidos como integrados apenas pela
presença de LinuxKPI.

## 5. Virtualização e compatibilidade

### Virtualização

- bhyve;
- `vmm` para amd64, arm64 e RISC-V;
- bhyvectl;
- virtio;
- suporte Hyper-V;
- componentes Xen;
- userboot;
- imagens para Firecracker;
- VNET para virtualização de rede.

### Compatibilidade binária

- Linuxulator em amd64/i386/arm64;
- módulos `linux` e `linux64`;
- compatibilidade com binários FreeBSD de versões anteriores;
- ABI FreeBSD32 no amd64;
- LinuxKPI para adaptação de drivers e APIs selecionadas.

LinuxKPI não é uma camada completa para portar subsistemas centrais Linux.

## 6. Segurança

### Controles nativos

- Jails;
- VNET;
- Capsicum;
- MAC Framework;
- securelevel;
- auditoria;
- ACLs;
- credenciais e privilege checks;
- mitigação e documentação de vulnerabilidades;
- veriexec;
- dumps de kernel criptografados;
- suporte a assinatura/secure boot no loader e bibliotecas relacionadas;
- OpenCrypto.

### Políticas MAC encontradas

- Biba;
- MLS;
- LOMAC;
- BSD Extended;
- port ACL;
- partition;
- seeotheruids;
- ifoff;
- priority;
- veriexec;
- políticas específicas para serviços;
- módulos stub/test para desenvolvimento.

### Criptografia

OpenCrypto possui AES-CBC, AES-ICM, AES-XTS, AES-GCM/GMAC,
ChaCha20-Poly1305, Poly1305, SHA-1, SHA-2, RIPEMD-160, compressão e caminhos
software/hardware. kTLS integra OpenCrypto e offload de interface.

## 7. Concorrência, locks e memória

O kernel possui:

- mutexes, rwlocks, sx locks, spinlocks e sleepqueues;
- turnstiles;
- WITNESS para ordem de locks;
- INVARIANTS;
- epoch;
- SMR;
- atomics;
- UMA;
- callouts e taskqueues;
- per-CPU data;
- NUMA/memory domains;
- pctrie;
- VM e pager infrastructure;
- OOM e swap;
- superpages e suporte arquitetural de memória.

Epoch e SMR ocupam o espaço conceitual que frequentemente é atendido por RCU
no Linux. Não há motivo para adicionar uma segunda implementação RCU completa.

## 8. Diagnóstico, tracing e qualidade

### Observabilidade

- DTrace e probes SDT/KDTrace;
- HWPMC;
- KTR;
- ktrace;
- TSLOG;
- boottrace;
- TCP blackbox;
- netdump e netgdb;
- DDB/KDB;
- stack traces;
- kernel dumps com gzip/zstd;
- sysctls e counters por subsistema.

### Detecção de erros

- WITNESS;
- INVARIANTS;
- DIAGNOSTIC;
- DEBUG_VFS_LOCKS opcional;
- failpoints `fail(9)`/`KFAIL_POINT`;
- KASAN;
- KCSAN;
- KMSAN;
- KCOV;
- KTest no kernel;
- ATF/Kyua no userland.

Configurações dedicadas amd64 foram encontradas para GENERIC-DEBUG,
GENERIC-KASAN, GENERIC-KCSAN e GENERIC-KMSAN. Esses recursos são de teste e
possuem custos; não devem ser todos ativados no kernel de produção.

## 9. Testes existentes

A árvore inclui testes para:

- kernel e syscalls;
- VM;
- filesystems e VFS;
- ZFS;
- GEOM;
- CAM;
- Capsicum;
- MAC;
- audit;
- kqueue;
- AIO;
- networking IPv4/IPv6;
- PF, IPFW e IPFilter;
- Netgraph;
- IPsec;
- netlink;
- OpenCrypto;
- bhyve/vmm;
- sendfile;
- kTLS;
- KCOV;
- scheduler affinity;
- Jails.

Maiores grupos encontrados incluem aproximadamente:

- 1.506 arquivos em `tests/sys/cddl`;
- 110 em netpfil;
- 101 em GEOM;
- 96 em kernel;
- 63 em filesystems;
- 62 em IPv6;
- 48 em rede;
- 35 em Capsicum.

Presença dos testes não equivale a execução. Nenhum teste FreeBSD foi rodado no
host Linux desta auditoria.

## 10. Boot e loader

A árvore `stand/` contém:

- loader EFI;
- boot1 e gptboot;
- loader Lua;
- loader Forth/FICL;
- boot BIOS/i386;
- PXE;
- U-Boot;
- OpenFirmware;
- kboot;
- userboot;
- suporte ZFS e GELI no loader;
- FDT;
- fontes e console;
- USB/storage no ambiente de boot.

Isso permite criar mídias BIOS/UEFI e imagens para diferentes arquiteturas.

## 11. Instalador e Live/Release

O código completo do `bsdinstall` está presente:

- frontend e fluxo principal;
- extração e download de distribuições;
- editor/assistente de partições;
- EFI, x86 e PowerPC;
- instalação roteirizada;
- configuração de boot;
- rede IPv4/IPv6 e Wi-Fi;
- hardening;
- serviços;
- usuários e senha root;
- firmware;
- instalação em Jail;
- ZFS boot;
- pkgbase.

A infraestrutura `release/` contém:

- criação de ISO e memstick para amd64/i386/arm64/RISC-V/PowerPC;
- imagens Azure, EC2, GCE, OCI, OpenStack e Vagrant;
- imagem Firecracker;
- cloud-init;
- geração de manifestos;
- staging pkgbase;
- configuração de DVD/repositórios;
- scripts de release reproduzíveis.

Portanto, existe código real para instalador e mídia Live/instalação. Isso não
significa que uma ISO Parcel personalizada já tenha sido produzida.

## 12. Userland e administração

Foram encontrados componentes reais para:

- rc.d, `service` e `sysrc`;
- usuários/grupos com `pw`;
- cron e newsyslog;
- daemon supervisionado básico;
- jail e jls;
- rctl em `usr.bin/rctl`;
- pkg bootstrap em `usr.sbin/pkg`;
- freebsd-update;
- bhyve;
- ctld e iscsid;
- bsdinstall;
- ferramentas ZFS;
- PF/IPFW;
- ferramentas de rede, storage e diagnóstico.

O toolchain importado inclui LLVM, Clang, LLD, LLDB, compiler-rt e OpenMP. Não
foi localizada uma integração Rust equivalente à existente no kernel Linux.

## 13. O que o FreeBSD não possui como equivalente direto confirmado

Na árvore analisada não foi identificado equivalente direto e completo para:

- Linux `sched_ext` com políticas BPF carregáveis;
- NTSYNC para Wine/Proton;
- PSI consolidado com semântica Linux;
- io_uring;
- Landlock;
- seccomp-BPF;
- cgroup v2;
- eBPF como plataforma geral de tracing/scheduler;
- IMA e fs-verity com a mesma ABI/modelo;
- kernel Rust integrado ao build.

Isso não implica que o FreeBSD seja incapaz de atender os mesmos objetivos.
Muitos são cobertos por composições diferentes: Jails/RCTL/Capsicum/MAC,
kqueue/AIO, DTrace/HWPMC e veriexec/ZFS.

## 14. Estado de validação

### Confirmado

- identidade Git/tag/commit;
- presença e estrutura dos subsistemas;
- opções no GENERIC;
- configurações de diagnóstico;
- código do bsdinstall e release;
- testes e ferramentas presentes;
- patches do kit passam em verificação estática.

### Não confirmado por execução

- buildworld;
- buildkernel;
- boot;
- carregamento de módulos;
- funcionamento em hardware;
- bsdinstall completo;
- geração de ISO;
- bhyve;
- rede, Wi-Fi ou GPU;
- sendfile/kTLS;
- sanitizers;
- ATF/Kyua;
- performance.

O host de trabalho é Linux e não possui `bmake`, `config(8)` FreeBSD, Kyua,
ATF ou mandoc. A fonte externa permaneceu sem modificações.

## 15. Conclusão

O FreeBSD presente é um sistema operacional completo e maduro, não um recorte
de kernel. Ele já oferece scheduler ULE, Jails/VNET, Capsicum, RACCT/RCTL,
OpenZFS, bhyve, PF/IPFW, sendfile/kTLS, DTrace, failpoints, sanitizers, loader,
bsdinstall e produção de ISO/cloud images.

As melhores oportunidades vindas do Linux 7.1.8 não são cópias de subsistemas.
São melhorias nativas e mensuráveis em telemetria de pressão, experimentação de
scheduler, compatibilidade NTSYNC para gaming, I/O assíncrono e integridade do
sistema. O patchset criado estabelece documentação, kernel de laboratório e
testes antes dessas mudanças de maior risco.
