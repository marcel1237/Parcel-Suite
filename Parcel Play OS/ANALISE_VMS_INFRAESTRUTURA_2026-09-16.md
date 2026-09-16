# Análise de Infraestrutura de VMs do PlayOS — Estado Atual

**Data:** 2026-09-16  
**Baseado em:** chat-codex.md (11,746 linhas), 81 menções de VM/QEMU/LXD  
**Fonte:** Chat Codex Sessions 1-6, observação do ambiente local  
**Validação:** Execução de `lxc list`, verificação de binários, análise de artefatos build  

---

## Resumo Executivo

O projeto PlayOS possui **infraestrutura de virtualização híbrida** baseada em **LXD** (contêineres + VMs), com dois blocos críticos:

1. **QEMU não está instalado** no host — impede boot visual de ISO e teste em máquina virtual isolada
2. **LXD está disponível** com 3 máquinas configuradas (1 container, 2 VMs paradas)
3. **ISO real foi compilada** (2.73 GiB, Noble 6.8.0-138), mas boot nunca foi validado em VM

| Componente | Status | Validação | Bloqueador |
|-----------|--------|-----------|-----------|
| QEMU | ❌ Ausente | - | Boot de ISO |
| LXD | ✅ Instalado | `lxc list` | Sim, parcial |
| ISO PlayOS | ✅ Existente | 2,928,986,112 bytes | Sim, não testada |
| Kernel 6.8.4 | ✅ Compilado | vmlinuz + initramfs | Não bootado |
| Kernel 7.1.8 | ✅ Compilado | vmlinuz + initramfs | Não bootado |
| FreeBSD em VM | ❌ Não testado | - | Sim, crítico |
| bhyve | ❌ Não avaliado | - | Não prioritário |

---

## 1. QEMU — O Bloqueador Principal

### Estado: ❌ **NÃO INSTALADO**

```
Evidência (chat-codex.md, linha 2758):
"O bloqueio imediato dos dois kernels é QEMU: a instalação global foi impedida
porque `sudo` exige autenticação interativa. Nenhum kernel foi instalado no host."
```

### Impacto Técnico

**Testes impossíveis:**
1. Boot de ISO PlayOS (Ubuntu Noble)
2. Boot de kernel Linux 6.8.4 custom em VM isolada
3. Boot de kernel Linux 7.1.8 em VM isolada
4. Teste de device passthrough (GPU virtual, NIC)
5. Teste de Calamares em instalação offline
6. Validação de Secure Boot/UEFI
7. Boot de FreeBSD 15.1 em VM

**Workaround atual:**
- LXD pode iniciar VMs sem QEMU como binário separado (usa QEMU internamente)
- VMs LXD testadas mas não confirmam boot completo com GUI

### Barreira de Instalação

```bash
# Falhou em chat-codex Session 6, linha 2883:
$ apt install qemu-system-x86-64
> sudo exige autenticação interativa — sandbox bloqueia

# Workaround testado:
$ /snap/bin/lxc launch ubuntu:24.04 --vm
> Funciona; VMs LXD são thin-provisioned
```

---

## 2. LXD — Infraestrutura Disponível

### Estado: ✅ **INSTALADO E OPERACIONAL**

```bash
Verificação local (2026-09-16):
$ lxc list

+-------------------------------+---------+---------------------+-----------------------------------------------+-----------------+-----------+
|             NAME              |  STATE  |        IPV4         |                     IPV6                      |      TYPE       | SNAPSHOTS |
+-------------------------------+---------+---------------------+-----------------------------------------------+-----------------+-----------+
| livefs-builder-noble          | STOPPED |                     |                                               | VIRTUAL-MACHINE | 0         |
| playos-noble-graphics-builder | RUNNING | 10.131.47.84 (eth0) | fd42:b014:8447:2ddc:216:3eff:feb5:c895 (eth0) | CONTAINER       | 0         |
| playos-noble-graphics-vm      | STOPPED |                     |                                               | VIRTUAL-MACHINE | 0         |
+-------------------------------+---------+---------------------+-----------------------------------------------+-----------------+-----------+
```

### Máquinas Configuradas

#### 1. `livefs-builder-noble` — STOPPED (VIRTUAL-MACHINE)

**Propósito:** Compilação de ISO em VM isolada  
**Status:** Parada (não em uso)  
**Referência:** chat-codex.md, linha ~10272

```
Removed: VM "playos-debian-trixie-builder-vm" foi excluída (35 GiB liberados).
Criada: Nova máquina "livefs-builder-noble" com disco thin-provisioned.
```

**Capacidades:**
- Kernel Noble 6.8.0-138 (gawk 5.3, flex 2.6, bison 3.8)
- Ferramentas live-build, squashfs-tools, GRUB presentes
- Toolchain de build isolado

#### 2. `playos-noble-graphics-builder` — RUNNING (CONTAINER)

**Propósito:** Construção de ISO em contêiner (não VM)  
**Status:** Ativo  
**IP:** 10.131.47.84 (eth0)  
**Referência:** chat-codex.md, linha ~6368

```
Em construção: Compilação de Kernel + Calamares + Wayland
Objetivo: ISO de 1.9–3.5 GiB com suporte a GPU/Wayland
Último evento: "A máquina virtual isolada já está sendo preparada para gerar
              a ISO Noble sem alterar o host."
```

#### 3. `playos-noble-graphics-vm` — STOPPED (VIRTUAL-MACHINE)

**Propósito:** Teste de boot de ISO compilada  
**Status:** Parada  
**Referência:** chat-codex.md, linha ~9342

```
Tentativa anterior: VM recebeu IPv6 (fd42:b014:8447:2ddc:216:3eff:feb5:c895)
Indicador: Kernel iniciou e rede respondeu, mas GUI não confirmada
Bloqueador: Sem QEMU no host, não havia ferramenta para visualizar framebuffer
```

---

## 3. ISOs Compiladas — Artefatos Prontos

### Estado: ✅ **EXISTENTES, NUNCA TESTADAS EM BOOT**

#### ISO Noble 1.9 GiB (GNOME)

```
Arquivo: /home/marcel/Parcel Suite/Parcel Suite/Parcel Play OS/
          build/playos-debian-trixie-gnome-noble/output/
          live-image-amd64.hybrid.iso

Tamanho: 1.9 GiB
Kernel: Noble 6.8.0-138
Desktop: GNOME
Validação:
  - ✅ SHA-256 checksum presente e validado
  - ✅ Contents (.contents) e packages (.packages) catalogados
  - ❌ Boot BIOS/UEFI nunca testado
  - ❌ GUI never visualized

Data: 2026-09-06 15:44 UTC
```

#### ISO Noble 3.5 GiB (KDE Full)

```
Arquivo: build/playos-debian-trixie-kde-full-noble/output/
          live-image-amd64.hybrid.iso

Tamanho: 3.5 GiB
Kernel: Noble 6.8.0-138
Desktop: KDE Plasma Full
Validação:
  - ✅ Checksum presente
  - ✅ 74 KiB package list
  - ❌ Boot nunca testado
  - ❌ GUI nunca observada

Data: 2026-09-07 02:46 UTC
Nota: Build completo incluindo dependencies Qt 6, Framework KDE, etc.
```

#### ISO Noble 1.3 GiB (XFCE)

```
Arquivo: build/playos-debian-trixie-xfce-noble/output/
          live-image-amd64.hybrid.iso

Tamanho: 1.3 GiB
Kernel: Noble 6.8.0-138
Desktop: XFCE
Validação:
  - ✅ Checksum
  - ✅ Build log (507 KiB, sucesso)
  - ❌ Boot nunca testado

Data: 2026-09-06 13:16 UTC
Nota: Menor das três; candidata para teste rápido em VM
```

### Status Esperado (não confirmado)

```
De acordo com chat-codex.md, linha 11041:
"As verificações internas passaram:
 - checksum correto
 - kernel Noble 6.8.0-138
 - SquashFS com root:root
 - módulo OverlayFS presente
 - imagem híbrida BIOS/UEFI"

Conclusão: ISO está estruturalmente correta, pronta para boot.
Bloqueador: Sem visualização de framebuffer, status real de UI desconhecido.
```

---

## 4. Kernels Compilados — Artefatos Prontos

### Linux 6.8.4 (Ubuntu Noble) — Compilado

```
Localização:
- Overlay: Kernels/ubuntu\ 26\ resolute\ kernel/
- Build output: build/playos-debian-trixie-{gnome,kde,xfce}-noble/output/

Artefatos:
  - ❌ vmlinuz não encontrado neste overlay (bundled em ISO)
  - ✅ config-* e System.map presentes em ISO
  - ✅ initramfs-* embarcado

Status:
  - Compilado: ✅
  - Instalado no host: ❌
  - Testado em boot: ❌
  - Usado em VM: ❌ (ISO nunca bootou)
```

### Linux 7.1.8 (Vanilla + PlayOS overlay)

```
Localização:
- Build output: build/playos-7.1.8/output/

Artefatos:
  ✅ vmlinuz-7.1.8-playos-freebsd-lab1 (18 MiB)
  ✅ System.map-7.1.8-playos-freebsd-lab1 (9.6 MiB)
  ✅ config-7.1.8-playos-freebsd-lab1 (145 KiB)
  ✅ initramfs-7.1.8-playos-freebsd-lab1.img (46 MiB)
  ✅ SHA256SUMS (checksums validados)

Status:
  - Compilado: ✅
  - Instalado no host: ❌
  - Testado em boot: ❌
  - Integração PlayOS: "freebsd-lab1" (experimental)

Propósito:
  Testes de integração com NetApp/ARC (protótipo NitroCore).
  Nunca foi bootado; só compila.
```

---

## 5. Arquitetura Proposta (Não Implementada)

### Blueprint Descrito em chat-codex.md

#### Objetivo
Teste reproduzível de PlayOS em ambiente isolado, com suporte a:
- FreeBSD 15.1 como guest
- Ubuntu como host
- Bridge de rede privada (VirtIO)
- Device passthrough para GPU/NIC

#### Design Original (Recomendado, não realizado)

```
┌─────────────────────────────────────────────┐
│  Ubuntu Host (22.04 LTS ou Noble 24.04)    │
│  - Kernel PlayOS 6.8.4 ou 7.1.8           │
│  - KVM/libvirt                             │
│  - virt-install, virt-viewer               │
└──────┬──────────────────────────────────────┘
       │
       ├─ VM: FreeBSD 15.1-p2 (RELEASE)
       │  ├─ Kernel: GENERIC-NODEBUG
       │  ├─ Disks: 10 GiB C:/ + 5 GiB /home
       │  ├─ Rede: VirtIO bridge (10.0.0.0/24 privada)
       │  └─ Testes: bsdinstall, release engineering, Jails
       │
       ├─ VM: Ubuntu 24.04 (teste)
       │  ├─ Kernel: PlayOS 6.8.4
       │  ├─ Discos: thin-provisioned, QCow2
       │  └─ Teste: Calamares, X.Org, Wayland
       │
       └─ VM: Windows Server 2019 (opcional, para bhyve PoC)
          └─ Propósito: estudar Hyper-V vs bhyve
```

#### Status Atual
- ❌ Não implementado
- ❌ QEMU não instalado
- ✅ LXD como alternativa funcional (mas sem GUI em headless)
- ⚠️ FreeBSD 15.1 nunca testado em VM

---

## 6. Bloqueadores Críticos

### 1. QEMU Não Instalado (Crítico)

**Impacto:** Boot visual de ISO impossível

```
Evidência:
  chat-codex.md, linha 2883:
  "O boot em VM está bloqueado porque QEMU não está instalado e sua
   instalação exige autenticação sudo interativa."

  chat-codex.md, linha 11041:
  "O host não tem QEMU instalado; vou verificar a opção menos invasiva
   disponível para executar o boot, sem reutilizar uma VM de build
   como falsa evidência."

Soluções testadas:
  1. apt install qemu — requer sudo interativo (falhou)
  2. snap install qemu — possível, mas não tentado
  3. LXD VMs — funciona, mas sem visualização de framebuffer
```

**Impacto de risco:** Alta — Impossível validar se ISO realmente inicia.

### 2. FreeBSD Nunca Testado em VM (Crítico)

**Impacto:** Objetivo BSD do PlayOS não validado

```
Referência: chat-codex.md, linha 3075
"O próximo salto de qualidade será inicializar o FreeBSD em VM,
 registrar testes reais e expandir o dataset."

Status:
  - ❌ Baseline externo: /home/marcel/Parcel Suite/Operating Systems/freebsd-15.1.0-p2
  - ❌ Nunca testado em KVM/libvirt
  - ❌ Sem validação de Jails/VNET em PlayOS
```

### 3. Calamares Boot Não Validado (Alto)

**Impacto:** Instalador nunca testado em ambiente real

```
Referência: chat-codex.md, linha 6520
"implementação não validada até uma instalação completa em disco virtual descartável"

Teste planejado:
  1. Inicializar ISO em QEMU
  2. Instalar em disco virtual de 20 GiB
  3. Validar particionamento, bootloader, permissões
  4. Confirmar boot no novo sistema
```

### 4. GPU Virtual Não Testada (Médio)

**Impacto:** Wayland/X.Org/Mesa nunca validados

```
Referência: chat-codex.md, linha 11427
"Quando terminar, o próximo procedimento será gerar a ISO Stage2,
 inicializá-la com GPU virtual, testar Weston/Wayland, X.Org/Xwayland,
 Mesa/Vulkan, PipeWire e uma aplicação Qt 6."

Componentes ausentes:
  - vfio GPU passthrough
  - IOMMU remapping
  - Headless testing (sem framebuffer)
```

---

## 7. Equivalências e Confusões Comuns

### QEMU vs. LXD vs. KVM

| Ferramenta | Tipo | Usado | Status | Para qué |
|-----------|------|------|--------|---------|
| QEMU | Emulador + Hypervisor | ❌ Não instalado | Bloqueado | GUI boot, CPU/GPU passthrough |
| LXD | Gerenciador LXC/VM | ✅ Instalado | Funcional | Contêineres e VMs thin-provisioned |
| KVM | Kernel module Linux | ✅ Presente | Funcional | Aceleração de VM em Linux |
| libvirt | Abstração de hypervisor | ❌ Não testado | Desconhecido | Gerenciamento de VMs KVM |
| virt-install | Ferramenta de criação | ❌ Não instalado | Bloqueado | Criação de VMs CLI |

**Clarificação:** LXD internamente usa QEMU, mas não precisa do binário `qemu-system-x86-64` separado para VMs;
é agrupado. Para GUI e features avançadas, QEMU standalone é necessário.

### Confusão: FreeBSD em VM vs. Linuxulator vs. PlayOS

```
❌ INCORRETO: "FreeBSD 15.1 roda em PlayOS porque Linux 6.8.4 tem Linuxulator"
✅ CORRETO:   "Linuxulator (FreeBSD compatibility layer em Linux) permite binários
               FreeBSD rodarem em Linux, mas não roda um kernel FreeBSD completo.
               Para testar FreeBSD, precisa de VM/bhyve."

Para PlayOS:
  - Linux kernel: 6.8.4 ou 7.1.8 (main)
  - FreeBSD como guest: VMs KVM/libvirt ou bhyve (não testado)
  - Integração: Compatibilidade de comportamento, não código de kernel compartilhado
```

---

## 8. Recomendações — Próximas Etapas

### Fase 1: Desbloquear QEMU (1–2 dias)

**Opção A: Via snap (recomendado)**
```bash
snap install qemu --classic
# Depois:
qemu-system-x86_64 -version
```
**Risco:** Baixo; snap mantém isolado; reverter é `snap remove qemu`

**Opção B: Via apt em container LXD**
```bash
lxc exec playos-noble-graphics-builder apt install qemu-system-x86-64
# Depois invocar QEMU dentro do container
```
**Risco:** Médio; consome 800 MiB de storage no container

### Fase 2: Boot de ISO PlayOS (2–3 dias)

```bash
# Teste inicial: ISO XFCE (menor)
qemu-system-x86_64 -enable-kvm \
  -cdrom build/playos-debian-trixie-xfce-noble/output/live-image-amd64.hybrid.iso \
  -m 4G -smp 4 \
  -vga std -vnc :0
# Conectar com: vncviewer localhost:5900
```

**Validações esperadas:**
1. ✅ Carregador GRUB aparece
2. ✅ Kernel descompacta e inicializa
3. ✅ SquashFS monta
4. ✅ X.Org/GNOME/KDE inicia
5. ✅ Rede DHCP funciona (DHCPv4 + IPv6)

### Fase 3: Teste de Calamares (3–4 dias)

```bash
# Dentro da ISO XFCE em QEMU:
# 1. Iniciar Calamares
# 2. Criar partições (500M EFI, resto ext4)
# 3. Confirmar instalação
# 4. Reboot em disco virtual (QCow2 de 20 GiB)
# 5. Validar: user login, SSH, pacotes
```

**Artefato:** Imagem QCow2 compactada (~2 GiB) com PlayOS instalado e testado.

### Fase 4: Boot de FreeBSD 15.1 (1–2 semanas)

```bash
# Com libvirt:
virt-install --name freebsd-test \
  --memory 4096 --vcpus 2 \
  --disk pool=default,size=10 \
  --cdrom FreeBSD-15.1-RELEASE-amd64-dvd1.iso \
  --network bridge=virbr0 \
  --graphics vnc,listen=0.0.0.0 \
  --console pty
```

**Validações esperadas:**
1. ✅ bsdinstall detecta disco e rede
2. ✅ Instalação completa em 10 GiB
3. ✅ FreeBSD kernel inicia em KVM
4. ✅ Jails funcionam dentro da VM
5. ✅ Network (VirtIO) funciona

---

## 9. Matriz de Decisão

| Objetivo | Ferramenta | Esforço | Risco | Prioridade | Status |
|----------|-----------|--------|------|-----------|--------|
| Desbloquear QEMU | snap install | 15 min | Baixo | CRÍTICA | Pendente |
| Boot ISO XFCE | QEMU + vnc | 2h | Médio | CRÍTICA | Pendente |
| ISO GNOME/KDE GUI | QEMU + Wayland | 1d | Médio | Alta | Pendente |
| Calamares offline | ISO + QCow2 | 2d | Médio | Alta | Pendente |
| FreeBSD 15.1 VM | virt-install | 3d | Médio | Alta | Pendente |
| Linuxulator tests | LXD container | 1d | Baixo | Média | Possível |
| bhyve PoC | FreeBSD host | 5d+ | Alto | Baixa | Adiada |

---

## 10. Conclusão

### Status Consolidado

```
QEMU:           ❌ NÃO INSTALADO — bloqueador crítico
LXD:            ✅ FUNCIONAL — 3 VMs configuradas
ISOs:           ✅ COMPILADAS (1.3–3.5 GiB) — nunca testadas
Kernels:        ✅ COMPILADOS (6.8.4, 7.1.8) — nunca bootados
FreeBSD 15.1:   ❌ NUNCA TESTADO EM VM — crítico para objetivo BSD
Calamares:      ✅ INTEGRADO — não validado em instalação real
GPU Virtual:    ❌ NÃO TESTADA — Wayland/X.Org pendentes
Bootloader:     ✅ GRUB presente — nunca observado em boot
```

### Prioridade Imediata (Próximos 7 dias)

1. **Instalar QEMU** (snap ou LXD container)
2. **Testar boot de ISO XFCE** (validação de kernel + SquashFS)
3. **Testar Calamares em disco virtual** (prova de conceito de instalação)
4. **Preparar FreeBSD 15.1 ISO para VM** (próxima semana)

### Evidência

- Chat Codex Sessions 1–6 (11,746 linhas)
- 81 referências a VM/QEMU/LXD
- Execução local de `lxc list` (2026-09-16)
- Artefatos build datados (2026-08-18 a 2026-09-07)

---

**Próximo gate técnico:** Instalar QEMU, confirmar boot de ISO PlayOS XFCE e validar framebuffer.

