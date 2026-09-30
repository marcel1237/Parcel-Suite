# Especificação Técnica — Angel OS (Kernel 7.3 + Debian Trixie KDE-Full)

**Versão**: `1.0.0`  
**Estratégia**: *Modelo Híbrido Base Debian Trixie + Kernel Linux Vanilla 7.3 (Seraphin)*  
**Data**: `2026-09-26`  

---

## 1. Visão Geral da Arquitetura Híbrida

Para garantir estabilidade, acesso imediato a pacotes maduros e um ambiente desktop rico sem exigir a recompilação de milhões de linhas de código C++ (como Qt e KDE) do zero, o **Angel OS KDE-Full** adota a seguinte arquitetura:

- **Userspace & Pacotes**: **Debian 13 (Trixie)** fornecendo o ecossistema completo (`glibc`, `systemd`, `Mesa`, `Wayland`, `Qt 6`, `KDE Frameworks 6`, `KDE Plasma 6 Full`, `KDE Gear`, `SDDM`, `PipeWire`, `NetworkManager`) gerenciados pelo **`apt`**.
- **Núcleo & Identidade**: **Linux Vanilla 7.3 (Seraphin)** compilado e injetado pelo **Angel OS Build System** (`./angel-build`), acompanhado de bootloader GRUB2 customizado, temas exclusivos e o **OpenGameKit**.

---

## 2. O Pipeline de Construção (`angel-build`)

O orquestrador `./angel-build` executa as seguintes etapas para gerar a ISO:

1. **Bootstrap do Userspace**:
   - Utilização de `debootstrap` para baixar e estruturar o rootfs base do **Debian Trixie** em `build/rootfs/`.
2. **Configuração do APT**:
   - Configuração de `/etc/apt/sources.list` apontando para os espelhos oficiais do Debian Trixie (`main`, `contrib`, `non-free-firmware`).
3. **Instalação do KDE-Full & Systemd**:
   - Execução via `chroot` para instalar o ambiente gráfico completo:
     ```bash
     apt-get update && apt-get install -y \
         systemd udev network-manager pipewire wireplumber \
         sddm plasma-workspace kde-applications-meta
     ```
4. **Injeção do Kernel Vanilla 7.3 (Seraphin)**:
   - Remoção do kernel padrão do Debian e instalação do nosso Kernel 7.3 compilado (`vmlinuz-7.3-seraphin` e módulos em `/lib/modules/`).
5. **Branding e Customização**:
   - Aplicação de temas do Angel OS, configuração do hostname (`angelos`) e criação do usuário Live (`angel`).
6. **Empacotamento ISO**:
   - Compactação do rootfs em `filesystem.squashfs` (usando compressão `zstd`) e criação da ISO híbrida UEFI/BIOS via `xorriso`.

---

## 3. Configuração do APT no Angel OS

O sistema mantém o gerenciador de pacotes **`apt`** plenamente funcional:
- O usuário pode instalar qualquer software adicional dos repositórios oficiais do Debian Trixie (`apt install ...`).
- O Kernel 7.3 e as atualizações exclusivas do Angel OS são mantidos e priorizados pelo sistema.
