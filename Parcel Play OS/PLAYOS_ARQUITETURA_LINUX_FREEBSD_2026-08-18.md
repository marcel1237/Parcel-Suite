# Arquitetura do PlayOS: Linux e FreeBSD

**Data:** 18 de agosto de 2026  
**Decisão:** PlayOS será uma família de produtos com núcleo Linux no Desktop
Gaming e uma edição FreeBSD separada. Não será criado um kernel híbrido.

## 1. Objetivo do produto

PlayOS deve entregar:

- jogos Linux e Windows com boa compatibilidade;
- desktop moderno em AMD, Intel e NVIDIA;
- aplicativos Android e containers Linux;
- armazenamento seguro, snapshots e rollback;
- isolamento forte para serviços e aplicações;
- Live ISO e instalação recuperável;
- desenvolvimento aberto, reproduzível e auditável.

O objetivo não exige escrever um kernel novo. Um kernel próprio agora aumentaria
drasticamente o esforço em drivers, segurança, suspend/resume, redes, USB, GPU,
filesystems e compatibilidade. O diferencial deve ficar inicialmente na
integração, nas políticas, no desktop, na loja e nas ferramentas PlayOS.

## 2. Bases auditadas

### Linux

- Ubuntu 26.04 LTS Resolute oficial: Linux 7.0;
- cópia local chamada Resolute: Noble Linux 6.8.4, inválida como baseline;
- árvore vanilla local: Linux 7.1.8, aproximadamente 93 mil arquivos, mas sem
  origem Git própria verificável;
- recursos relevantes encontrados: DRM, namespaces, cgroup v2, seccomp,
  Landlock, io_uring, eBPF, `sched_ext`, NTSYNC, kTLS e extensa infraestrutura
  de drivers e testes.

### FreeBSD

- FreeBSD 15.1-RELEASE-p2;
- tag `release/15.1.0-p2`, commit
  `aadd58dddcbc78f4d5594827b46b5633552b15ce`;
- fonte completa e verificável: kernel, base, loader, release, instalador e
  testes;
- recursos relevantes: ULE, OpenZFS, Jails/VNET, RACCT/RCTL, Capsicum, MAC,
  bhyve, DTrace, sendfile/kTLS, Linuxulator, pkgbase e bsdinstall.

## 3. Comparação orientada ao PlayOS

| Critério | Linux | FreeBSD | Decisão PlayOS |
|---|---|---|---|
| jogos/Steam/Proton | ecossistema principal | possível, mas parcial | Linux no Gaming |
| Android/Waydroid | suporte de kernel conhecido | requer VM Linux | Linux no Gaming |
| GPU e hardware de consumo | cobertura mais ampla | varia por dispositivo | Linux padrão |
| NVIDIA/proprietários | integração ampla por distribuição | suporte próprio, com diferenças | qualificar separadamente |
| containers Linux | namespaces/cgroup | Linuxulator não é kernel Linux | Linux ou bhyve |
| isolamento nativo | namespaces/LSMs/cgroup | Jails/VNET/Capsicum/MAC | usar o nativo de cada edição |
| ZFS e rollback | OpenZFS externo à árvore Linux | integração de primeira classe | modelo FreeBSD inspira ambos |
| virtualização | KVM/QEMU | bhyve | backend nativo por edição |
| observabilidade | ftrace/eBPF/perf | DTrace/HWPMC/KTR | adaptador comum |
| sistema base integrado | distribuição agrega projetos | kernel e base integrados | vantagem operacional FreeBSD |
| catálogo desktop | maior | menor, porém relevante | Linux no desktop principal |
| licença do kernel | GPL-2.0 | predominantemente BSD | código não será copiado entre kernels |

## 4. Arquitetura aprovada

```text
                         PLAYOS
                            │
          ┌─────────────────┴─────────────────┐
          │                                   │
 PlayOS Gaming/Desktop                 PlayOS BSD/Server
 Ubuntu Resolute Linux 7.0             FreeBSD 15.1
          │                                   │
 Steam/Proton/Waydroid                 ZFS/Jails/VNET/Capsicum
 KVM/containers Linux                  bhyve/Linuxulator/Wine
          └─────────────────┬─────────────────┘
                            │
                 Serviços comuns PlayOS
       UI, catálogo, políticas, telemetria e formatos de dados
```

### 4.1 PlayOS Gaming/Desktop

Produto prioritário e primeira ISO pública:

- baseline: Ubuntu 26.04 LTS Resolute, Linux 7.0 oficial;
- kernel Ubuntu oficial como padrão e recuperação;
- kernel vanilla/NitroCore somente depois de build e testes equivalentes;
- KDE Plasma como experiência principal; GNOME como sessão suportada;
- Steam, Proton, Wine, Gamescope, PipeWire, Waydroid e containers;
- ext4 como opção simples; ZFS ou outro layout com rollback somente após
  validação completa do instalador;
- Secure Boot e assinatura mantidos no fluxo de produção.

### 4.2 PlayOS BSD/Server

Produto separado, inicialmente experimental:

- baseline: FreeBSD 15.1-RELEASE-p2;
- kernel GENERIC preservado como fallback;
- ZFS boot environments, Jails/VNET, Capsicum, MAC e bhyve;
- KDE/Wayland ou Xorg após qualificação de GPU;
- Linuxulator/Linux jail para binários Linux de userspace;
- bhyve para cargas que exigem kernel Linux ou Windows;
- `bsdinstall` permanece o backend de instalação;
- frontend PlayOS pode coletar opções e exibir progresso, sem reimplementar
  prematuramente particionamento e loader.

## 5. Componentes compartilhados

O compartilhamento deve acontecer acima do kernel:

| Componente | Contrato comum | Backend Linux | Backend FreeBSD |
|---|---|---|---|
| Play Software Center | catálogo e estado JSON | APT/Flatpak/containers | pkg/Ports/Linux jail |
| Play Sessions | seleção de sessão | systemd/display manager | rc.d/display manager |
| Play Sandbox | perfil declarativo | namespaces/cgroup/LSM | Jail/RCTL/Capsicum/MAC |
| Play VM | ciclo de vida de VM | KVM/QEMU | bhyve |
| Play Telemetry | eventos e métricas | perf/ftrace/eBPF | DTrace/HWPMC/KTR |
| Play Update | transação e rollback | pacotes/imagem | pkgbase/pkg + BE/ZFS |
| Play Installer UI | modelo de instalação | Subiquity/backend Ubuntu | bsdinstall/backend FreeBSD |

Interfaces comuns devem usar formatos versionados e chamadas userspace. Não
devem expor `struct task_struct`, `struct proc`, `vnode`, `mbuf`, locks ou outra
API interna de kernel.

## 6. Compatibilidade de aplicações

### No PlayOS Linux

1. pacote Ubuntu/DEB;
2. Flatpak;
3. AppImage quando auditado;
4. container/Distrobox;
5. Wine/Proton;
6. Waydroid;
7. VM como fallback.

### No PlayOS FreeBSD

1. pkg/Ports nativo;
2. Linuxulator em Linux jail;
3. Wine nativo;
4. bhyve Linux/Windows;
5. streaming remoto.

A loja deve informar qual backend será utilizado. “Rodar” não é sinônimo de
“rodar nativamente”. Anti-cheat, DRM comercial e drivers fechados dependem do
fornecedor e não podem receber garantia universal.

## 7. Estratégia de kernel

### Produção

- Linux: kernel Ubuntu Resolute Linux 7.0 assinado;
- FreeBSD: GENERIC da release com atualizações oficiais;
- nenhum patch experimental habilitado por padrão.

### Laboratório

- Linux vanilla 7.1.8 local somente após recuperar proveniência e commit;
- `patch-FreeBSD-Kernel-7.1.8/` e `patch-FreeBSD-Ubuntu/` para estudos;
- `patch-linux7.1.8-FreeBSD/` aplicado apenas a worktree FreeBSD descartável;
- kernels `PARCEL-LAB` separados, nunca substituindo recuperação.

### Política de aceitação de patch

Todo patch precisa de problema reproduzível, licença/proveniência, benchmark,
teste automatizado, fallback, build nas arquiteturas suportadas e boot em VM.
O código GPL do Linux não será copiado para o FreeBSD. Ideias serão
reimplementadas de forma independente e compatível com a arquitetura BSD.

## 8. Boot, Live e instalação

O MVP não deve começar com uma ISO de onze kernels. A sequência correta é:

1. ISO PlayOS Linux isolada e reproduzível;
2. mídia PlayOS FreeBSD isolada e reproduzível;
3. testes completos de instalação e recuperação de cada uma;
4. somente então, mídia agregadora que faça chainload das imagens independentes.

Linux usa seu próprio kernel, initramfs, Casper/Dracut e instalador Ubuntu.
FreeBSD usa loader, kernel, world, release e bsdinstall próprios. Eles não
compartilham rootfs, módulos nem drivers.

## 9. Branding e migração do nome

“PlayOS” deve ser a marca do produto. Nomes técnicos existentes podem continuar
temporariamente como codinomes internos:

- Parcel Play OS → PlayOS;
- NitroCore → PlayOS Kernel Lab, até existir um kernel qualificável;
- Nitro-Jail → Play Sandbox;
- Parcel Software Center → Play Software Center.

A renomeação deve ser feita depois de inventário de arquivos, identificadores,
pacotes, domínios e marcas. Não executar substituição global, pois “Parcel” pode
aparecer em APIs, caminhos e histórico que exigem migração compatível.

## 10. Roadmap

### Marco 1 — especificação e baseline

- congelar requisitos do PlayOS;
- obter árvore Resolute Linux 7.0 correta;
- validar ISO Ubuntu e FreeBSD oficiais em VM;
- criar matriz real de hardware e aplicações.

### Marco 2 — PlayOS Linux MVP

- branding mínimo;
- KDE principal e GNOME alternativo;
- instalador oficial preservado;
- Steam/Proton, áudio e drivers testados;
- atualização, rollback e recuperação.

### Marco 3 — PlayOS FreeBSD Technology Preview

- Live gráfica;
- ZFS boot environment;
- Play Software Center usando pkg;
- Linux jail e Wine;
- bhyve como fallback;
- relatório por hardware.

### Marco 4 — serviços comuns

- catálogo de aplicações e roteamento por backend;
- API de sandbox;
- telemetria comparável;
- CI para imagens e testes de boot.

### Marco 5 — otimização comprovada

- aplicar somente patches com ganho mensurado;
- qualificar kernel experimental;
- avaliar mídia agregadora e novas arquiteturas.

## 11. Critérios para primeira versão pública

- build reproduzível a partir de revisão fixada;
- checksum e manifesto de todos os artefatos;
- boot BIOS/UEFI e Secure Boot conforme a edição;
- instalação e desinstalação em disco virtual vazio;
- fallback de kernel e rollback do sistema;
- rede, áudio, GPU, suspend/resume e atualização testados;
- licenças e fontes publicadas;
- nenhuma função experimental anunciada como concluída.

## 12. Veredito

O PlayOS deve nascer como integração de sistemas maduros, não como kernel novo.
Linux é a escolha correta para a edição Gaming/Desktop devido a hardware,
Steam/Proton, Android e catálogo. FreeBSD é a escolha correta para uma edição
de storage, isolamento e infraestrutura, além de laboratório de tecnologias.

Essa estrutura mantém identidade única no userspace e na experiência, mas
respeita que Linux e FreeBSD são sistemas diferentes. É o caminho de menor
risco para entregar algo utilizável e, ao mesmo tempo, criar tecnologia própria
de forma gradual e verificável.

## Fontes oficiais principais

- [Ubuntu Resolute com Linux 7.0](https://discourse.ubuntu.com/t/26-04-lts-resolute-raccoon-shipping-with-the-final-7-0-linux-kernel/80838)
- [Documentação do kernel Linux sobre interfaces](https://docs.kernel.org/process/stable-api-nonsense.html)
- [FreeBSD 15.1-RELEASE](https://www.freebsd.org/releases/15.1R/)
- [Jails e Linux jails](https://docs.freebsd.org/en/books/handbook/jails/)
- [ZFS no FreeBSD](https://docs.freebsd.org/en/books/handbook/zfs/)
- [Virtualização bhyve](https://docs.freebsd.org/en/books/handbook/virtualization/)
- [Compatibilidade Linux no FreeBSD](https://docs.freebsd.org/en/books/handbook/linuxemu/)
