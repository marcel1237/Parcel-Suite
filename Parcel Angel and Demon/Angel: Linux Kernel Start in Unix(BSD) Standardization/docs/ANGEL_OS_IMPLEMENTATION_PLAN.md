# Plano de Implementação — Geração da ISO Angel OS KDE-Full

**Versão**: `1.0.0`  
**Objetivo**: Implementar o pipeline real de construção da Live ISO utilizando `debootstrap`, `chroot`, Kernel Vanilla 7.3, KDE Plasma Full e `grub-mkstandalone`.  
**Data**: `2026-09-26`  

---

## 1. Etapas de Implementação no Build System (`./angel-build`)

### Etapa 1: `build-rootfs` (Bootstrap Debian Trixie)
- Utiliza o comando `debootstrap` para baixar o userspace oficial do Debian Trixie em `build/rootfs/`.
- Configura o `/etc/apt/sources.list` com os repositórios `main`, `contrib` e `non-free-firmware`.

### Etapa 2: `build-kernel` (Kernel Vanilla 7.3 - Seraphin)
- Configura e compila o Kernel Linux Vanilla 7.3 a partir de `sources/kernel/linux-7.3/` (ou instala o kernel gerado).
- Posiciona `vmlinuz-7.3-seraphin` em `build/kernel/` e copia para `build/iso/boot/`.

### Etapa 3: `build-kde` (Instalação via Chroot)
- Monta os sistemas de arquivos virtuais (`/proc`, `/sys`, `/dev`) no `build/rootfs/`.
- Executa `chroot` para atualizar o APT e instalar o ecossistema completo:
  ```bash
  apt-get update && apt-get install -y \
      systemd-sysv network-manager pipewire wireplumber \
      sddm plasma-workspace kde-applications-meta
  ```
- Desmonta os sistemas virtuais com segurança.

### Etapa 4: `build-iso` (GRUB EFI e xorriso)
- Gera o binário EFI do GRUB (`BOOTX64.EFI`) utilizando `grub-mkstandalone`.
- Compacta o `build/rootfs/` em `filesystem.squashfs` usando compressão `zstd`.
- Executa o `xorriso` para gerar a imagem ISO híbrida final em `output/Angel-OS-KDE-Full.iso`.
