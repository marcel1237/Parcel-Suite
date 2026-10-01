O pipeline de construção do **Angel OS KDE-Full** foi executado com sucesso e a **Live ISO oficial foi gerada**!

---

## 🏆 Resultado da Compilação e Geração da ISO

1. **Bootstrap Concluído**: O `debootstrap` baixou e estruturou o userspace do **Debian 13 (Trixie)** no diretório unificado `build/rootfs/`.
2. **KDE Plasma Full Instalado**: O script de chroot executou a instalação via `apt-get install` de todo o ecossistema do **KDE Plasma 6**, **SDDM**, **PipeWire**, **NetworkManager** e utilitários (ocupando ~5.4 GB descompactados no RootFS).
3. **Compressão SquashFS**: O RootFS unificado foi compactado via `mksquashfs` com algoritmo **zstd**, gerando um `filesystem.squashfs` otimizado de **2.8 GB**.
4. **Empacotamento ISO Híbrida**: O `xorriso` unificou o bootloader GRUB EFI, o Kernel e o SquashFS na imagem final:
   ```text
   output/Angel-OS-KDE-Full.iso (2.8 GB)
   ```

---

## 🚀 Como testar a ISO gerada

Você pode testar o boot da ISO recém-criada diretamente no QEMU/KVM sem precisar gravar um pendrive:

```bash
./angel-build qemu
```

Ou diretamente via QEMU:

```bash
qemu-system-x86_64 -enable-kvm -m 4096 -smp 4 -cdrom output/Angel-OS-KDE-Full.iso -boot d -vga virtio
```
