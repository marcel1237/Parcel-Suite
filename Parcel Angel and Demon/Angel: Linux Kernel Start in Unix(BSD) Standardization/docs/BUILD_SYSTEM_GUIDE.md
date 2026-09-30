# Guia do Sistema de Construção — Angel OS Build System

**Versão**: `0.1.0`  
**Data**: `2026-09-26`  

---

## 1. Conceito do RootFS Unificado

No **Angel OS KDE-Full**, não tentamos compilar todo o sistema em um único comando opaco. Adotamos uma **cadeia de construção em camadas** (*layered build chain*), onde cada script compila e instala seus binários, bibliotecas e dados diretamente dentro de um único diretório de sistema raiz:

```text
build/rootfs/
```

### Estrutura do RootFS Unificado (`build/rootfs/`):

```text
build/rootfs/
├── bin/
├── boot/
├── dev/
├── etc/
├── home/
├── lib/ -> usr/lib
├── lib64/ -> usr/lib
├── proc/
├── root/
├── run/
├── sbin/ -> usr/sbin
├── sys/
├── tmp/
├── usr/
│   ├── bin/
│   ├── include/
│   ├── lib/
│   ├── sbin/
│   └── share/
└── var/
```

---

## 2. Estrutura do Repositório do Build System

```text
Angel OS/
│
├── sources/               # Downloads e tarballs do código-fonte upstream
├── packages/              # Receitas de compilação e manifestos de versão
│
├── build/                 # Espaço de compilação e artefatos
│   ├── toolchain/         # Compiladores e bibliotecas base (GCC, Binutils, Glibc)
│   ├── rootfs/            # O Root Filesystem único do Angel OS
│   ├── kernel/            # Kernel Linux Vanilla 7.3 compilado e initramfs
│   └── iso/               # Diretório de geração da mídia ISO final
│
├── scripts/               # Scripts numerados sequenciais da cadeia de build
│   ├── 01-toolchain.sh    # Binutils, GCC, Glibc, Linux Headers
│   ├── 02-rootfs.sh       # BusyBox, Coreutils, FHS layout, util-linux, kmod
│   ├── 03-systemd.sh      # systemd, udev, dbus
│   ├── 04-kernel.sh       # Compilação do Linux Vanilla 7.3 + initramfs
│   ├── 05-mesa.sh         # DRM, Mesa (OpenGL / Vulkan), libinput
│   ├── 06-wayland.sh      # Wayland, Wayland-Protocols, XWayland
│   ├── 07-pipewire.sh     # ALSA, PipeWire, WirePlumber
│   ├── 08-qt.sh           # Qt 6
│   ├── 09-kde-frameworks.sh # KDE Frameworks 6
│   ├── 10-kde-plasma.sh   # KWin, KDE Plasma 6 Desktop
│   ├── 11-kde-applications.sh # Aplicativos KDE Gear
│   ├── 12-sddm.sh         # SDDM Display Manager + temas Angel OS
│   ├── 13-iso.sh          # Geração da ISO final Angel-OS-KDE-Full.iso
│   └── run_qemu.sh        # Script de execução rápida para teste em QEMU
│
└── config/                # Arquivos de configuração de boot, kernel e systemd
```

---

## 3. Fluxo de Execução Incremental

A vantagem desta arquitetura é que cada etapa é **verificável e isolada**:

```bash
# 1. Preparar Toolchain
./scripts/01-toolchain.sh

# 2. Construir RootFS básico
./scripts/02-rootfs.sh

# 3. Compilar Kernel Vanilla 7.3 e initramfs
./scripts/04-kernel.sh

# 4. Testar boot inicial no QEMU (v0.1)
./scripts/run_qemu.sh
```

Após confirmar que o **Angel OS v0.1** inicializa até o shell interativo no QEMU, prossegue-se incrementalmente para os scripts `03-systemd.sh`, `05-mesa.sh`, `06-wayland.sh`, `08-qt.sh`, `10-kde-plasma.sh` e `13-iso.sh`.
