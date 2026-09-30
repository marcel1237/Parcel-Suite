# Mapeamento de Componentes Upstream — Angel OS

**Filosofia**: *"Build System próprio + Componentes Upstream"*  
**Repositório Angel OS**: `github.com/marcel1237/angel-os` (Contém receitas, scripts, perfis e orquestrador, sem forks monolíticos).

---

## 1. Tabela Oficial de Repositórios Upstream

| Componente | Repositório Principal Upstream | Papel no Angel OS |
|---|---|---|
| **Linux 7.3** | `https://cdn.kernel.org/pub/linux/kernel/v7.x/linux-7.3.tar.xz` | Kernel Vanilla (Seraphin) |
| **Binutils** | `https://sourceware.org/git/binutils-gdb.git` | Linker e Assembler |
| **GCC** | `https://gcc.gnu.org/git/gcc.git` | Compilador C/C++ |
| **glibc** | `https://sourceware.org/git/glibc.git` | Biblioteca C do Sistema |
| **Linux headers** | `kernel.org` | Headers do Kernel para o Userspace |
| **BusyBox** | `https://git.busybox.net/busybox` | Base inicial de utilitários do RootFS |
| **systemd** | `https://github.com/systemd/systemd` | Init, udev e gerenciamento de serviços |
| **coreutils** | GNU | Utilitários de manipulação básica |
| **util-linux** | `kernel.org` | Mount, fdisk, lsblk, etc. |
| **GRUB** | GNU Savannah | Bootloader UEFI/BIOS |
| **Mesa** | `https://gitlab.freedesktop.org/mesa/mesa` | Pilha OpenGL e drivers Vulkan |
| **Wayland** | `https://gitlab.freedesktop.org/wayland/wayland` | Protocolo de exibição gráfico |
| **XWayland** | `https://gitlab.freedesktop.org/wayland/xserver` | Compatibilidade com aplicativos X11 |
| **PipeWire** | `https://gitlab.freedesktop.org/pipewire/pipewire` | Servidor de áudio e vídeo |
| **WirePlumber** | `https://gitlab.freedesktop.org/pipewire/wireplumber` | Gestão de sessões do PipeWire |
| **NetworkManager** | `https://gitlab.freedesktop.org/NetworkManager/NetworkManager` | Gerenciamento de redes |
| **Qt 6** | `https://code.qt.io/qt/qt6.git` | Toolkit gráfico de base |
| **KDE Frameworks** | `https://invent.kde.org/frameworks/*` | Bibliotecas modulares KDE |
| **KWin** | `https://invent.kde.org/plasma/kwin` | Window Manager e Compositor Wayland |
| **Plasma** | `https://invent.kde.org/plasma/*` | Ambiente Desktop KDE Plasma |
| **KDE Applications** | `https://invent.kde.org/utilities/*`, `games/*`, etc. | KDE Gear (Dolphin, Konsole, Kate, etc.) |
| **SDDM** | `https://github.com/sddm/sddm` | Display Manager e tela de login |
| **xorriso** | GNU / Libburnia | Geração da imagem ISO híbrida |
| **SquashFS** | `kernel.org` / SquashFS-tools | Filesystem comprimido (`zstd`) |

---

## 2. Organização da Pasta `sources/` no Build System

Os fontes baixados do upstream são segregados em subdiretórios limpos:

```text
sources/
├── toolchain/
│   ├── binutils/
│   ├── gcc/
│   └── glibc/
├── kernel/
│   └── linux-7.3/
├── base/
│   ├── busybox/
│   ├── coreutils/
│   ├── util-linux/
│   └── systemd/
├── graphics/
│   ├── mesa/
│   ├── wayland/
│   └── xwayland/
├── audio/
│   ├── pipewire/
│   └── wireplumber/
├── network/
│   └── networkmanager/
└── kde/
    ├── qt/
    ├── frameworks/
    ├── kwin/
    ├── plasma/
    ├── applications/
    └── sddm/
```

---

## 3. Ordem de Bootstrap da Cadeia

Para compilar e gerar o Angel OS KDE-Full com estabilidade, a ordem de inicialização do bootstrap é:

1. **Bootstrap Core**: Linux 7.3 + Binutils + GCC + glibc + BusyBox.
2. **Infraestrutura**: systemd + udev + coreutils + util-linux.
3. **Hardware & Gráficos**: DRM + Mesa (Vulkan/OpenGL) + Wayland.
4. **Áudio & Rede**: PipeWire + WirePlumber + NetworkManager.
5. **Desktop**: Qt 6 → KDE Frameworks 6 → KWin → Plasma 6 → KDE Gear → SDDM.
6. **Empacotamento**: SquashFS (`zstd`) + GRUB2 EFI + `xorriso` → `output/Angel-OS-KDE-Full.iso`.
