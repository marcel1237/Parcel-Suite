# PlayOS: Arquitetura Live CD com KIWI NG, Userspace Debian e Oracle UEK

## Identificação e Registro

- **ID:** `PLAYOS-KIWI-DEBIAN-ORACLE-UEK-001`
- **Tipo:** `decision` e `implementation-plan`
- **Estado:** aprovado como nova arquitetura e perfil declarativo implementado; runtime e boot da ISO pendentes
- **Confiança:** alta para a especificação KIWI NG e isolamento de pacotes DEB/RPM; runtime `unknown`
- **Data:** 2026-09-18
- **Motor de Build:** KIWI NG (`kiwi-ng` schema v7.4)
- **Userspace:** Debian 13 (`trixie`), fixado por codinome
- **Kernel:** Oracle Unbreakable Enterprise Kernel (UEK R7/R8 - Linux 5.15 / 6.6)
- **Desktop:** XFCE 4.20 / LightDM / Xorg (Debian Trixie)
- **Instalador:** nenhum (Live CD pura)

---

## 1. Contexto e Motivação

O **PlayOS** investiga arquiteturas modulares onde o **kernel** e o **userspace** possuem fronteiras declarativas bem definidas. Após consolidar perfis com `live-build` e kernels Ubuntu Noble sobre Debian, a presente arquitetura introduz o motor de geração de imagens **KIWI NG** (desenvolvido no ecossistema openSUSE/SUSE) para integrar o **Oracle Unbreakable Enterprise Kernel (UEK)** a um userspace estável **Debian 13 (Trixie)**.

### 1.1 Por que KIWI NG?
- **Declaratividade Pura:** Configuração via `config.xml` (schema 7.4) parametrizando perfis, repositórios, pacotes e bootloaders sem dependência de scripts imprevisíveis.
- **Suporte Multi-Distribuição Nativo:** Capaz de gerenciar pacotes `apt` para bootstraps Debian/Ubuntu, gerando imagens ISO híbridas BIOS/UEFI prontas para gravação direta (`dd`).
- **Hooks Estruturados:** Separação limpa entre pré-boot (`config.sh`), pré-arquivamento (`images.sh`) e overlays de arquivos (`root/`).

### 1.2 Por que Oracle Unbreakable Enterprise Kernel (UEK)?
- **Estabilidade Empresarial e Performance:** O Oracle UEK (UEK R7 baseado em Linux 5.15 LTS / UEK R8 baseado em Linux 6.6 LTS) traz otimizações para virtualização, I/O de disco, Btrfs, DTrace e workloads exigentes de memória.
- **Fronteira Limpa:** Os artefatos do kernel (magem `vmlinuz-*-uek` e árvore de módulos `/lib/modules/*-uek`) são extraídos dos pacotes RPM oficiais da Oracle, reempacotados em artefatos `.deb` locais (`oracle-kernel-uek-image` e `oracle-kernel-uek-modules`) e disponibilizados via repositório APT isolado do PlayOS.

---

## 2. Fronteira de Componentes e Repositórios

Para evitar corrupção de bibliotecas ou misturas de geradores de pacotes (APT vs DNF), o PlayOS estabelece a seguinte regra inviolável:

```text
Kernel, Módulos e Config:   Oracle UEK (extraído de RPMs oficiais e reempacotado em DEBs isolados)
Userspace Base (libc, systemd): Debian 13 (Trixie)
Desktop, Servidores Gráficos:  Debian 13 (Trixie)
Gerenciamento de Pacotes:       APT (usando exclusivamente espelhos Debian e o repositório local UEK)
```

Nenhum espelho da Oracle Linux ou RHEL é adicionado diretamente às fontes do APT do chroot Debian. Os RPMs do UEK são convertidos/empacotados localmente pela ferramenta `import_oracle_uek.sh` antes da execução do KIWI NG.

---

## 3. Fluxo e Pipeline da Live CD KIWI NG

```text
[ RPMs Oracle UEK ]
      │ (rpm2cpio & dpkg-deb)
      ▼
[ Repositório APT Local UEK ] ──┐
                                │
[ Espelhos Debian Trixie ] ─────┼──► [ KIWI NG Engine ]
                                │         │
[ kiwi-build/config.xml ] ──────┘         │ (bootstrap apt + dracut)
                                          ▼
                                 [ Chroot Debian + UEK ]
                                          │
                                          │ (config.sh: systemd + dracut initramfs)
                                          ▼
                                 [ Raiz SquashFS + OverlayFS ]
                                          │
                                          │ (isolinux / GRUB2 hybrid)
                                          ▼
                                 [ PlayOS Live ISO Híbrida ]
```

---

## 4. Estrutura de Arquivos Implementada

O perfil declarativo e as ferramentas de automação foram criados em `kiwi-build/playos-debian-oracle-uek-live/`:

```text
kiwi-build/playos-debian-oracle-uek-live/
├── config.xml                      # Descrição XML declarativa KIWI NG (schema 7.4)
├── config.sh                       # Hook de pós-instalação (systemd, dracut UEK, limpeza)
├── images.sh                       # Hook pré-arquivamento (limpeza de temporários)
├── root/                           # Overlay de configuração do sistema
│   └── etc/
│       └── dracut.conf.d/
│           └── playos-uek.conf     # Módulos dracut para Live OverlayFS e SquashFS
└── tools/
    ├── import_oracle_uek.sh        # Download, extração e empacotamento DEB do Oracle UEK
    └── build.sh                    # Executor do build KIWI NG (nativo ou Podman/Docker)
```

---

## 5. Receita Operacional do KIWI NG (`config.xml`)

O manifesto `config.xml` declara:
- **Profiles:** `XFCE-Minimal` (com pilha gráfica X11/XFCE) e `Console-Core` (modo servidor/consolas).
- **Repositórios:**
  - `debian-trixie`: `http://deb.debian.org/debian` (`main contrib non-free-firmware`).
  - `playos-oracle-uek`: `dir:///var/cache/playos-uek-repo` (pacotes `.deb` do kernel UEK).
- **Pacotes Essenciais:** `base-files`, `systemd`, `live-boot`, `live-config`, `dracut`, `dracut-live`, `squashfs-tools`, `oracle-kernel-uek-image`, `oracle-kernel-uek-modules`, `firmware-linux-free`, `network-manager`.

---

## 6. Procedimento de Construção

### Passo 1: Importar e Empacotar o Kernel Oracle UEK
```sh
cd kiwi-build/playos-debian-oracle-uek-live/tools
./import_oracle_uek.sh
```
O script verifica/baixa os RPMs do UEK (`kernel-uek`, `kernel-uek-core`, `kernel-uek-modules`), extrai o binário `vmlinuz-*-uek` e a pasta de módulos, gera os pacotes `oracle-kernel-uek-image` e `oracle-kernel-uek-modules`, e indexa o repositório APT em `/var/cache/playos-uek-repo`.

### Passo 2: Executar o Build KIWI NG
```sh
./build.sh
```
O executor utiliza `kiwi-ng` local ou invoca o contêiner oficial `registry.opensuse.org/opensuse/kiwi:latest` via Podman/Docker, produzindo a ISO Live final em `output/`.

---

## 7. Matriz de Validação e Gates

| Gate | Descrição | Estado Atual |
|---|---|---|
| **Gate 1** | Especificação declarativa KIWI NG (`config.xml`, `config.sh`, `images.sh`) | `implementation` (concluído) |
| **Gate 2** | Ferramenta de importação e empacotamento DEB do Oracle UEK | `implementation` (concluído) |
| **Gate 3** | Indexação do repositório local APT do UEK | `implementation` (concluído) |
| **Gate 4** | Compilação da ISO via `kiwi-ng system build` | `proposal` / `pending-execution` |
| **Gate 5** | Boot BIOS/UEFI em QEMU/hardware com kernel UEK inicializando userspace Debian | `unknown` |

---

## 8. Conclusão e Próximos Passos

A arquitetura KIWI NG para o PlayOS estabelece um modelo reprodutível e declarativo para combinar o **Oracle Unbreakable Enterprise Kernel** com o **userspace Debian 13**. O próximo passo é executar o download dos RPMs do UEK no ambiente isolado de build e compilar a primeira ISO do perfil.
