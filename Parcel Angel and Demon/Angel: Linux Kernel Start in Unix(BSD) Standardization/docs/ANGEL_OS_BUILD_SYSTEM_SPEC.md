# Especificação Técnica — Angel OS Build System

**Versão**: `0.1.0`  
**Filosofia**: *"Build System próprio + Componentes Upstream"*  
**Orquestrador Mestre**: `./angel-build`  
**Data**: `2026-09-26`  

---

## 1. Princípios de Engenharia

O **Angel OS Build System** abandona a dependência do `live-build` do Debian para evitar acoplamento a decisões internas de terceiros e problemas de bootloader. Adota-se o modelo **Build próprio com componentes upstream maduros**:

- **Kernel**: kernel.org (Vanilla 7.3 - Seraphin)
- **Toolchain**: GCC + Binutils + Glibc
- **Init & Serviços**: systemd + udev + dbus
- **Sistema de Arquivos**: SquashFS (`mksquashfs` com compressão `zstd`)
- **Bootloader**: GRUB2 (EFI / BIOS)
- **Empacotador de Mídia**: `xorriso`
- **Pilha Gráfica**: DRM + Mesa + Vulkan + Wayland + XWayland + KWin
- **Interface Desktop**: Qt 6 + KDE Frameworks 6 + KDE Plasma 6 Full + SDDM

---

## 2. A ISO como Formato de Distribuição

A imagem ISO não é o núcleo do Angel OS, mas sim o **formato final de empacotamento e distribuição**:

```text
Angel OS RootFS (build/rootfs/)
      │
      ├── /bin
      ├── /etc
      ├── /usr
      ├── /lib
      ├── /var
      └── KDE Plasma Full
           │
           ▼
     mksquashfs -comp zstd
           │
           ▼
   build/iso/angel/filesystem.squashfs
           │
           ├── Linux Vanilla 7.3 (boot/vmlinuz-7.3-seraphin)
           ├── initramfs (boot/initramfs.img)
           ├── GRUB EFI (EFI/BOOT/BOOTX64.EFI)
           └── boot/grub/grub.cfg
                    │
                    ▼
     xorriso (mkisofs -volid "ANGEL_OS")
                    │
                    ▼
      output/Angel-OS-KDE-Full.iso
```

---

## 3. O Orquestrador CLI `./angel-build`

A compilação e orquestração são executadas pelo utilitário `./angel-build`:

```bash
./angel-build [subcomando]
```

### Subcomandos Disponíveis:

- `./angel-build all`: Executa toda a cadeia de construção em sequência.
- `./angel-build toolchain`: Prepara o ambiente da toolchain base.
- `./angel-build rootfs`: Inicializa a estrutura FHS em `build/rootfs/`.
- `./angel-build kernel`: Compila e instala o Kernel Vanilla 7.3.
- `./angel-build system`: Instala systemd, udev, dbus e utilitários base.
- `./angel-build graphics`: Instala DRM, Mesa, Vulkan e Wayland.
- `./angel-build kde`: Instala Qt 6, KDE Frameworks, Plasma 6 e SDDM.
- `./angel-build initramfs`: Gera o initramfs próprio do Angel OS.
- `./angel-build iso`: Compacta o `build/rootfs/` em SquashFS (`zstd`) e gera a ISO híbrida em `output/`.
- `./angel-build qemu`: Executa o teste de boot no QEMU/KVM (suporta OVMF / UEFI).
- `./angel-build --check`: Audita as ferramentas essenciais do host.

---

## 4. Teste em QEMU/KVM sem gravação física

A ISO gerada em `output/Angel-OS-KDE-Full.iso` pode ser imediatamente testada em máquina virtual sem necessidade de gravação em pendrive:

```bash
./angel-build qemu
```

Ou diretamente via QEMU:

```bash
qemu-system-x86_64 -enable-kvm -m 4096 -smp 4 -cdrom output/Angel-OS-KDE-Full.iso -boot d -vga virtio
```
