---  
You:  
O que falta para fazermos uma .iso?
Agent:  
> Thought  
> **Assessing ISO Creation**  
>   
> Okay, I'm currently assessing what's present in the project and what's needed to generate a bootable `.iso` image of Angel OS KDE-Full. Specifically, the Debian Trixie userspace and Linux kernel are under review to determine the missing components required for a functional `.iso` build. The goal is a fully bootable image.  
>   
>   
> **Pinpointing Key Missing Steps**  
>   
> I've got a clearer picture now. The core components for the ISO are in place, like the orchestrator (`angel-build`), modular scripts to build toolchain, rootfs and kernel, system and graphics components, KDE, initramfs, and scripts for ISO creation and configuration files. But I see that the real bootstrap execution, specifically `debootstrap`, is currently missing from the build scripts to create the Debian Trixie rootfs and get it fully populated.  
>   
>   
>   
Para gerarmos uma **Live ISO 100% funcional e bootável** do **Angel OS KDE-Full** (com Debian Trixie userspace + Kernel 7.3 + KDE Plasma + APT), precisamos executar ou implementar os seguintes 4 passos práticos no nosso Build System (`./angel-build`):

---

### 1. Executar o Bootstrap do Debian Trixie (`build-rootfs`)
Atualmente, a estrutura FHS é criada como um esqueleto vazio. Precisamos popular o diretório `build/rootfs/` com o sistema operacional base do Debian utilizando o comando `debootstrap`:
```bash
sudo debootstrap --arch=amd64 trixie build/rootfs/ https://deb.debian.org/debian/
```
Isso instala o userspace essencial do Debian (`glibc`, `coreutils`, `bash`, `apt`, `dpkg`) dentro de `build/rootfs/`.

---

### 2. Compilar e Injetar o Kernel Vanilla 7.3 (`build-kernel`)
Precisamos obter, configurar e compilar o código-fonte do Kernel Linux Vanilla 7.3 (`Seraphin`):
```bash
# Baixar fontes do kernel 7.3
wget https://cdn.kernel.org/pub/linux/kernel/v7.x/linux-7.3.tar.xz
tar -xf linux-7.3.tar.xz && cd linux-7.3

# Configurar e compilar
make defconfig
make -j$(nproc) bzImage modules

# Instalar kernel e módulos no rootfs do Debian
cp arch/x86/boot/bzImage ../build/kernel/vmlinuz-7.3-seraphin
make modules_install INSTALL_MOD_PATH=../build/rootfs/
```

---

### 3. Instalar o KDE Plasma Full e o Systemd via `chroot` (`build-kde`)
Com o rootfs do Debian populado e o `apt` configurado, entramos em `chroot` para instalar o ambiente gráfico completo, gerenciador de login e rede:
```bash
# Montar sistemas de arquivos virtuais
mount -t proc proc build/rootfs/proc
mount --bind /sys build/rootfs/sys
mount --bind /dev build/rootfs/dev

# Chroot e instalação via apt
chroot build/rootfs /bin/bash -c "
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y systemd-sysv network-manager pipewire wireplumber sddm plasma-workspace kde-applications-meta
"

# Desmontar
umount build/rootfs/dev build/rootfs/sys build/rootfs/proc
```

---

### 4. Gerar o Bootloader GRUB EFI Real (`build-iso`)
Para que a ISO inicialize via UEFI em máquinas reais ou no QEMU, precisamos gerar a imagem EFI do GRUB (`BOOTX64.EFI`) dentro de `build/iso/EFI/BOOT/`:
```bash
grub-mkstandalone \
    --format=x86_64-efi \
    --output=build/iso/EFI/BOOT/BOOTX64.EFI \
    --locales="" \
    --fonts="" \
    "boot/grub/grub.cfg=config/iso/grub.cfg"
```

---

### Como faremos isso no `./angel-build`?

Podemos atualizar os scripts individuais (`scripts/build-rootfs`, `scripts/build-kernel`, `scripts/build-kde`, `scripts/build-iso`) para executarem esses comandos reais quando invocados.

Deseja que eu implemente os comandos reais de `debootstrap`, `chroot` e `grub-mkstandalone` nos scripts do `./angel-build` para realizarmos a primeira compilação completa?
