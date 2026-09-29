# Transcrição Completa da Sessão: Correção e Evolução do Live-Build Debian Trixie + Kernel Vanilla 7.3

## 1. Contexto Inicial
O objetivo da sessão foi criar, depurar e estabilizar o perfil de construção da Live ISO do **PlayOS** baseada no **Debian 13 (Trixie)** com o ambiente gráfico **KDE Full** e a injeção do **Linux Kernel Vanilla 7.3-rc3/rc4** (utilizando pacotes `.deb` locais armazenados em `playos-resolute-k73/kernel/`).

---

## 2. Iterações de Build e Descobertas Técnicas

### 2.1. O Problema de Espaços no Caminho (`live-build`)
- **Problema**: O `live-build` abortou com `E: Cannot build live image from a directory containing spaces` ao tentar rodar a partir de caminhos contendo espaços (`Parcel Suite/...`).
- **Resolução**: Sincronização e execução do perfil de build em um diretório desprovido de espaços no host (`/home/marcel/playos-debian-trixie-kde-full-vanilla-7.3/`).

### 2.2. Contaminação por Configurações Globais do Host Ubuntu
- **Problema**: O `live-build` assumia o modo Ubuntu e tentava buscar a suíte legada `precise`.
- **Resolução**: Travamento explícito do modo e da distribuição via `config/bootstrap` e parâmetros de CLI (`LB_MODE=debian LB_DISTRIBUTION=trixie`).

### 2.3. Erro 404 no Repositório de Segurança (`security.debian.org`)
- **Problema**: O caminho antigo `trixie/updates` retornava 404.
- **Resolução**: Patch aplicado no script do sistema do `live-build` (`/usr/lib/live/build/lb_chroot_archives`) para traduzir para `trixie-security`, combinado com arquivos de arquivo em `config/archives/`.

### 2.4. Ausência da Ferramenta GPG no Chroot de Bootstrap (`env: 'gpg': No such file or directory`)
- **Problema**: O estágio de indexação de pacotes locais (`config/packages.chroot/`) tentava assinar o repositório mas o executável `gpg` não estava presente no chroot mínimo.
- **Resolução**: Inclusão de `gpg` via parâmetro `--bootstrap-include "gpg ca-certificates"` no `config/bootstrap`.

### 2.5. Falha de Chave GPG Não Interativa (`Inappropriate ioctl for device`)
- **Problema**: O GnuPG tentava interagir com o terminal para gerar chaves de forma interativa.
- **Resolução**: Patch em `/usr/lib/live/build/lb_chroot_archives` para ignorar a assinatura GPG de pacotes locais (`if false`), dispensando a geração interativa de chaves.

### 2.6. Erro de Flavour do Debian Installer (`E: debian-installer flavour none not supported`)
- **Problema**: O argumento `--debian-installer none` em `auto/config` era interpretado como um flavour inválido.
- **Resolução**: Remoção da linha do `auto/config`, deixando `LB_DEBIAN_INSTALLER="false"` nativamente em `config/binary`.

### 2.7. Conflito de Carregador de Boot (`grub-legacy` / `stage2_eltorito` / Conflito entre `grub-pc` e `grub-efi-amd64`)
- **Problema**: A opção `--bootloader grub` acionava o obsoleto `grub-legacy`, enquanto a listagem simultânea de pacotes UEFI e BIOS na `package-list` causava conflitos no APT.
- **Resolução**: Remoção de `--bootloader grub` do `auto/config` (permitindo que o `live-build` utilize o `LB_BOOTLOADER="syslinux"` padrão com suporte híbrido UEFI + BIOS) e limpeza dos pacotes de GRUB conflitantes do chroot.

---

## 3. Estado Atual e Próximos Passos
- Todas as barreiras de bootstrap, chroot, GPG, segurança e bootloader foram superadas.
- A **Tentativa 15** encontra-se em execução estável, progredindo da instalação de pacotes para a montagem final da imagem binária e da ISO.
