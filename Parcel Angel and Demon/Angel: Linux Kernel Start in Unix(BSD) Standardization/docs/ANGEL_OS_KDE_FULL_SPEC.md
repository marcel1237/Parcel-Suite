# Especificação de Arquitetura — Angel OS KDE-Full

**Versão**: `1.0.0`  
**Slogan**: *"The Linux unix-like"*  
**Sabor / Flavor**: `Angel OS KDE-Full`  
**Data**: `2026-09-26`  

---

## 1. Visão Geral do Angel OS KDE-Full

O **Angel OS KDE-Full** é uma distribuição com **base própria** construída ao redor do **Kernel Linux Vanilla 7.3**, projetada para entregar uma experiência desktop com o ambiente **KDE Plasma completo** (KDE Frameworks, KDE Gear, SDDM e KWin Wayland), suporte para jogos com o **OpenGameKit** e um **RootFS unificado** (`build/rootfs/`).

### Diagrama de Arquitetura Geral:

```text
                         ANGEL OS KDE-FULL
                                │
                    ┌───────────┴───────────┐
                    │      Angel OS ISO     │
                    └───────────┬───────────┘
                                │
                         Bootloader/EFI
                                │
                         Linux Vanilla 7.3
                                │
                            initramfs
                                │
                         ┌──────▼──────┐
                         │   systemd   │
                         └──────┬──────┘
                                │
                    ┌───────────▼───────────┐
                    │     ANGEL ROOTFS      │
                    │                       │
                    │ glibc                 │
                    │ GCC/runtime           │
                    │ Coreutils             │
                    │ util-linux            │
                    │ kmod                  │
                    │ udev                  │
                    │ NetworkManager        │
                    │                       │
                    │ Mesa                  │
                    │ Vulkan                │
                    │ DRM                   │
                    │ Wayland               │
                    │ XWayland              │
                    │ PipeWire              │
                    │                       │
                    │ Qt                    │
                    │ KDE Frameworks        │
                    │ KWin                  │
                    │ Plasma                │
                    │ KDE Applications      │
                    │ SDDM                  │
                    └───────────┬───────────┘
                                │
                         OpenGameKit
                                │
                         Angel OS Desktop
```

---

## 2. A Cadeia de Construção Sequencial (Scripts 01 a 13)

Cada componente do Angel OS instala seus arquivos diretamente no diretório `build/rootfs/`:

| Script | Etapa do Build | Componentes Principais Instalados no `build/rootfs/` |
|---|---|---|
| `scripts/01-toolchain.sh` | **01. Toolchain** | Binutils, GCC, Glibc, Linux Headers |
| `scripts/02-rootfs.sh` | **02. RootFS Base** | Layout FHS, BusyBox, Coreutils, util-linux, kmod, e2fsprogs |
| `scripts/03-systemd.sh` | **03. Init & Serviços** | systemd, udev, dbus, shadow/PAM |
| `scripts/04-kernel.sh` | **04. Kernel & Boot** | Linux Vanilla 7.3 (Seraphin), módulos, `initramfs` próprio |
| `scripts/05-mesa.sh` | **05. GPU & Entrada** | DRM, Mesa (OpenGL / Vulkan drivers), libinput |
| `scripts/06-wayland.sh` | **06. Display Server** | Wayland, Wayland-Protocols, XWayland |
| `scripts/07-pipewire.sh` | **07. Áudio & Rede** | ALSA, PipeWire, WirePlumber, NetworkManager, BlueZ |
| `scripts/08-qt.sh` | **08. Framework Qt** | Qt 6 Base, Qt Declarative, Qt Wayland |
| `scripts/09-kde-frameworks.sh` | **09. KDE Base** | KDE Frameworks 6 (Extra CMake Modules, KCoreAddons, etc.) |
| `scripts/10-kde-plasma.sh` | **10. Plasma Desktop** | KWin, KDE Plasma 6 Desktop, Breeze Theme |
| `scripts/11-kde-applications.sh` | **11. KDE Gear** | Dolphin, Konsole, Kate, Gwenview, Ark, Spectacle, KCalc |
| `scripts/12-sddm.sh` | **12. Display Manager** | SDDM + temas e perfis de sessão Angel OS |
| `scripts/13-iso.sh` | **13. Imagem Final** | Empacotamento em SquashFS + GRUB2 + ISO híbrida |

---

## 3. Meta Imediata: Angel OS Build System v0.1

Iniciamos com o **Angel OS Build System v0.1**, focado em obter um boot funcional no QEMU:

```text
Linux Vanilla 7.3
        +
BusyBox
        +
initramfs
        +
rootfs
        +
QEMU
```

Assim que a v0.1 inicializar até o shell interativo no QEMU, prosseguimos incrementalmente com as etapas de `systemd`, `Mesa/Wayland` e `Qt/KDE`.
