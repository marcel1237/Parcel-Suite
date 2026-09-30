# Angel OS KDE-Full

> **Slogan**: *"The Linux unix-like"*  
> **Arquitetura**: *Kernel Linux Vanilla 7.3 (Seraphin) + Userspace Debian Trixie KDE-Full com APT*

---

## 👑 Visão do Projeto

O **Angel OS KDE-Full** adota o **Modelo Híbrido de Alta Eficiência**:
- **Userspace & Aplicações**: Fundamentado no ecossistema estável e completo do **Debian 13 (Trixie)** com **KDE Plasma 6 Full**, gerenciado via **`apt`**.
- **Núcleo & Identidade**: Utiliza o nosso **Kernel Linux Vanilla 7.3 (Seraphin)** compilado sob medida, bootloader GRUB2 customizado e ferramentas exclusivas como o **OpenGameKit**.

---

## 📦 Como o APT Funciona no Angel OS

O sistema mantém o gerenciador de pacotes **`apt`** nativamente operacional:
- Os repositórios oficiais apontam para os espelhos do **Debian Trixie** (`main`, `contrib`, `non-free-firmware`).
- O usuário pode instalar qualquer software do ecossistema Debian (`apt install ...`).
- O **Kernel 7.3** e as otimizações visuais/de desempenho do Angel OS são mantidas e priorizadas pelo sistema.

---

## 🏗️ O Orquestrador CLI `./angel-build`

O **Angel OS Build System** automatiza a criação da ISO híbrida através de comandos modulares:

```bash
./angel-build [subcomando]
```

### Comandos Principais:
- `./angel-build all` — Executa o bootstrap do Debian Trixie, injeção do Kernel 7.3, instalação do KDE-Full e geração da ISO.
- `./angel-build rootfs` — Cria a base Debian Trixie via `debootstrap`.
- `./angel-build kernel` — Compila e injeta o Kernel Linux Vanilla 7.3 (Seraphin).
- `./angel-build kde` — Instala o ecossistema KDE Plasma 6 Full e SDDM via `apt chroot`.
- `./angel-build iso` — Empacota o rootfs em SquashFS (`zstd`) e gera a ISO em `output/`.
- `./angel-build qemu` — Executa o teste de boot no QEMU/KVM.

---

## 🚀 Como Executar

1. **Verificar Pré-requisitos do Host**:
   ```bash
   ./angel-build --check
   ```

2. **Gerar a ISO do Angel OS KDE-Full**:
   ```bash
   ./angel-build all
   ```

3. **Testar no QEMU**:
   ```bash
   ./angel-build qemu
   ```
