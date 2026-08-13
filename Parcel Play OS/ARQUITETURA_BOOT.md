# Arquitetura de Boot: O Menu do Decágono

Este documento detalha o funcionamento do processo de boot do **Parcel Play OS**, desde a inicialização do Live CD até a transição para o sistema instalado.

## 1. O Menu GRUB do Live CD

Para garantir que o usuário tenha controle total desde o primeiro segundo, o menu de boot do Live CD oferecerá todos os **10 Sabores do NitroCore**.

### Configuração de Menu:
- **Opção Padrão (Default)**: **NitroCore-Debian**.
    - *Razão*: É o kernel com maior compatibilidade de drivers e firmware, garantindo que o instalador inicie com sucesso em qualquer máquina.
- **Opções Alternativas**: O menu contará com entradas específicas para cada um dos outros 9 sabores (Arch, Fedora, openSUSE, Gentoo, FreeBSD, OpenBSD, NetBSD, CentOS, Oracle).

### O conceito de "Fat Initrd":
O Live CD utilizará um arquivo de inicialização ramificada (**Initrd**) único e robusto que contém os módulos de driver necessários para os 10 kernels, permitindo que qualquer um deles consiga montar o sistema de arquivos Live (EROFS/RAM).

## 2. Processo de Transição e Aceleração

O boot do Parcel Play OS é dividido em estágios de alta performance:

### Estágio 1: Kernel de Gênese
- Boot do sabor NitroCore escolhido no GRUB.

### Estágio 2: Dark Volt (Early UI)
- Em menos de 2 segundos, o serviço **Dark Volt** assume a tela via **EGLFS**.
- Apresenta a tela de login imediata enquanto o Systemd termina o boot "pesado".

### Estágio 3: Handoff (O "Salto")
- Após o login, o sistema pode usar `kexec` se necessário ou simplesmente transicionar para o compositor Wayland (Gnome ou KDE).

## 3. Segurança e Integridade (UKI)

O sistema utiliza **Unified Kernel Images (UKI)**:
- O Kernel, o Initrd e os parâmetros de boot são assinados digitalmente e unidos em um único arquivo `.efi`.
- Isso impede que o menu de boot seja alterado por softwares maliciosos (Rootkits de boot).

---
*Status: Arquitetura de Boot Validada.*
